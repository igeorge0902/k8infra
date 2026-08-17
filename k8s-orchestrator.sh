#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="cinemas"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST="${SCRIPT_DIR}/quarkus-backend.yaml"

TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-300}"
ENDPOINT_RETRIES="${ENDPOINT_RETRIES:-3}"
ENDPOINT_TIMEOUT_SECONDS="${ENDPOINT_TIMEOUT_SECONDS:-15}"
ENDPOINT_NO_PROXY="${ENDPOINT_NO_PROXY:-localhost,127.0.0.1,milo.crabdance.com}"

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

info() {
  printf "[INFO] %s\n" "$*"
}

pass() {
  printf "[PASS] %s\n" "$*"
}

warn() {
  printf "[WARN] %s\n" "$*"
}

fail() {
  printf "[FAIL] %s\n" "$*" >&2
  printf "[INFO] Next action: run 'k8infra/k8s-orchestrator.sh help' and execute the referenced manual fallback steps in k8infra/README-k8s-local.md\n" >&2
  exit 1
}

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------

usage() {
  cat <<'EOF'
Usage:
  k8infra/k8s-orchestrator.sh up [--seed]
  k8infra/k8s-orchestrator.sh up [--seed] status
  k8infra/k8s-orchestrator.sh status
  k8infra/k8s-orchestrator.sh restart <service> [--build]
  k8infra/k8s-orchestrator.sh down
  k8infra/k8s-orchestrator.sh off
  k8infra/k8s-orchestrator.sh help

Services:
  Application:
    dalogin
    mbook
    mbooks
    simple-service-webapp

  Infrastructure:
    mysql
    zookeeper
    kafka
    apache

  Observability:
    loki
    tempo
    prometheus
    grafana

Notes:
  - up applies k8infra/quarkus-backend.yaml.
  - up waits for infrastructure, observability and application deployments.
  - up ... status runs startup followed by an immediate status snapshot.
  - up --seed also imports mysql_8/login.sql and mysql_8/book.sql.
  - down scales all deployments in namespace cinemas to 0.
  - PVCs are preserved by down.
  - off performs down, then stops minikube and colima.
  - restart performs a rolling restart.
  - restart <service> --build performs Maven package + image build/load
    for Quarkus application services only.
EOF
}

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

ensure_manifest_exists() {
  [[ -f "${MANIFEST}" ]] || fail "Manifest file not found: ${MANIFEST}"
}

# ---------------------------------------------------------------------------
# Runtime / cluster
# ---------------------------------------------------------------------------

ensure_runtime() {
  require_cmd kubectl
  require_cmd minikube
  require_cmd curl

  if command -v colima >/dev/null 2>&1; then
    if ! colima status 2>/dev/null | grep -qi "running"; then
      info "Starting colima with defaults from README-k8s-local.md"
      colima start --cpu 4 --memory 4 --disk 20 >/dev/null
      pass "colima started"
    else
      pass "colima is running"
    fi
  else
    info "colima not installed; assuming another Docker runtime is available"
  fi

  if ! minikube status --format '{{.Host}}' 2>/dev/null | grep -qi "running"; then
    info "Starting minikube with docker driver"
    minikube start \
      --driver=docker \
      --cpus=4 \
      --memory=3900 >/dev/null

    pass "minikube started"
  else
    pass "minikube is running"
  fi

  info "Ensuring ingress addon is enabled"
  minikube addons enable ingress >/dev/null
  pass "ingress addon enabled"
}

patch_ingress_lb_if_needed() {
  local svc_type

  svc_type="$(
    kubectl -n ingress-nginx \
      get svc ingress-nginx-controller \
      -o jsonpath='{.spec.type}' 2>/dev/null || true
  )"

  if [[ "${svc_type}" == "NodePort" ]]; then
    info "Patching ingress-nginx-controller service to LoadBalancer"

    kubectl -n ingress-nginx patch svc ingress-nginx-controller \
      -p '{"spec":{"type":"LoadBalancer"}}' >/dev/null

    pass "ingress-nginx-controller patched to LoadBalancer"
  fi
}

# ---------------------------------------------------------------------------
# Kubernetes helpers
# ---------------------------------------------------------------------------

deployment_exists() {
  local deployment="$1"

  kubectl -n "${NAMESPACE}" get deployment "${deployment}" \
    >/dev/null 2>&1
}

wait_rollout() {
  local deployment="$1"

  if ! deployment_exists "${deployment}"; then
    fail "deployment/${deployment} does not exist in namespace ${NAMESPACE}"
  fi

  info "Waiting for deployment/${deployment}"

  if kubectl -n "${NAMESPACE}" rollout status \
      "deployment/${deployment}" \
      --timeout="${TIMEOUT_SECONDS}s" >/dev/null; then

    pass "deployment/${deployment} is ready"
  else
    warn "deployment/${deployment} failed readiness"

    info "Recent pod state:"
    kubectl -n "${NAMESPACE}" get pods \
      -l "app=${deployment}" \
      -o wide || true

    info "Recent events:"
    kubectl -n "${NAMESPACE}" get events \
      --sort-by=.lastTimestamp | tail -20 || true

    info "Recent logs from deployment/${deployment}:"
    kubectl -n "${NAMESPACE}" logs \
      "deployment/${deployment}" \
      --tail=50 \
      --all-containers=true || true

    fail "deployment/${deployment} did not become ready"
  fi
}

restart_deployment() {
  local deployment="$1"

  deployment_exists "${deployment}" ||
    fail "deployment/${deployment} does not exist"

  info "Rolling restart deployment/${deployment}"

  kubectl -n "${NAMESPACE}" rollout restart \
    "deployment/${deployment}" >/dev/null

  wait_rollout "${deployment}"
}

# ---------------------------------------------------------------------------
# Endpoint checks
# ---------------------------------------------------------------------------

check_endpoint() {
  local url="$1"
  local attempt
  local http_code

  for attempt in $(seq 1 "${ENDPOINT_RETRIES}"); do
    if http_code="$(
      curl \
        -skL \
        --noproxy "${ENDPOINT_NO_PROXY}" \
        --connect-timeout 5 \
        --max-time "${ENDPOINT_TIMEOUT_SECONDS}" \
        -o /dev/null \
        -w '%{http_code}' \
        "${url}" 2>/dev/null
    )"; then

      if [[ "${http_code}" != "000" ]]; then
        pass "Reachable: ${url} (HTTP ${http_code})"
        return
      fi
    fi

    warn "Endpoint probe attempt ${attempt}/${ENDPOINT_RETRIES} failed for ${url}"
    sleep 1
  done

  fail "Endpoint check failed: ${url}. Verify proxy bypass and minikube/ingress status."
}

# ---------------------------------------------------------------------------
# MySQL seed
# ---------------------------------------------------------------------------

seed_mysql() {
  local login_sql="${REPO_ROOT}/mysql_8/login.sql"
  local book_sql="${REPO_ROOT}/mysql_8/book.sql"

  [[ -f "${login_sql}" ]] ||
    fail "Missing SQL seed file: ${login_sql}"

  [[ -f "${book_sql}" ]] ||
    fail "Missing SQL seed file: ${book_sql}"

  info "Seeding mysql with mysql_8/login.sql"

  kubectl -n "${NAMESPACE}" exec -i deploy/mysql -- \
    mysql -uroot -prootpw < "${login_sql}"

  info "Seeding mysql with mysql_8/book.sql"

  kubectl -n "${NAMESPACE}" exec -i deploy/mysql -- \
    mysql -uroot -prootpw < "${book_sql}"

  pass "MySQL seed completed"
}

# ---------------------------------------------------------------------------
# Pictures seed
# ---------------------------------------------------------------------------

populate_pictures() {
  local pictures_dir="${REPO_ROOT}/pictures"
  local pod

  [[ -d "${pictures_dir}" ]] || fail "Pictures directory not found: ${pictures_dir}"

  pod="$(kubectl -n "${NAMESPACE}" get pod \
    -l app=simple-service-webapp \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"

  [[ -n "${pod}" ]] || fail "No simple-service-webapp pod found"

  info "Populating pictures PVC from ${pictures_dir}"
  kubectl -n "${NAMESPACE}" cp \
    "${pictures_dir}/." \
    "${pod}:/pictures/"

  pass "Pictures copied to ${pod}:/pictures/"
}

# ---------------------------------------------------------------------------
# Service/image helpers
# ---------------------------------------------------------------------------

service_src_dir() {
  case "$1" in
    dalogin)
      echo "dalogin-quarkus"
      ;;
    mbook)
      echo "mbook-quarkus"
      ;;
    mbooks)
      echo "mbooks-quarkus"
      ;;
    simple-service-webapp)
      echo "simple-service-webapp-quarkus"
      ;;
    *)
      return 1
      ;;
  esac
}

service_image() {
  case "$1" in
    dalogin)
      echo "dalogin-quarkus:local"
      ;;
    mbook)
      echo "mbook-quarkus:local"
      ;;
    mbooks)
      echo "mbooks-quarkus:local"
      ;;
    simple-service-webapp)
      echo "simple-service-webapp-quarkus:local"
      ;;
    *)
      return 1
      ;;
  esac
}

build_and_load_service() {
  local service="$1"
  local src_dir
  local image

  src_dir="$(service_src_dir "${service}")" ||
    fail "Unsupported service for restart --build: ${service}"

  image="$(service_image "${service}")"

  info "Packaging ${src_dir}"

  (
    cd "${REPO_ROOT}/${src_dir}"
    ./mvnw package -DskipTests
  )

  if command -v docker >/dev/null 2>&1; then
    info "Building image inside minikube Docker daemon: ${image}"

    eval "$(minikube docker-env)"

    docker build \
      -t "${image}" \
      "${REPO_ROOT}/${src_dir}"

    eval "$(minikube docker-env --unset)"

    pass "Image built inside minikube Docker daemon"
    return
  fi

  if command -v podman >/dev/null 2>&1; then
    info "Building image with podman: ${image}"

    podman build \
      -t "${image}" \
      "${REPO_ROOT}/${src_dir}"

    podman save "localhost/${image}" |
      minikube image load --daemon=false -

    pass "Image built with podman and loaded into minikube"
    return
  fi

  fail "Neither docker nor podman is available for restart --build"
}

# ---------------------------------------------------------------------------
# Startup order
# ---------------------------------------------------------------------------

cmd_up() {
  local do_seed="false"

  if [[ "${1:-}" == "--seed" ]]; then
    do_seed="true"
  elif [[ -n "${1:-}" ]]; then
    fail "Unsupported argument for up: ${1}. Allowed: --seed"
  fi

  # -------------------------------------------------------------------------
  # Step 1: Runtime
  # -------------------------------------------------------------------------

  info "Step 1/6: runtime and cluster checks"

  ensure_manifest_exists
  ensure_runtime
  patch_ingress_lb_if_needed

  # -------------------------------------------------------------------------
  # Step 2: Apply manifests
  # -------------------------------------------------------------------------

  info "Step 2/6: applying Kubernetes manifest"

  kubectl apply -f "${MANIFEST}" >/dev/null

  pass "Manifest applied: ${MANIFEST}"

  # -------------------------------------------------------------------------
  # Step 3: Core infrastructure
  # -------------------------------------------------------------------------

  info "Step 3/6: infrastructure rollout checks"

  wait_rollout mysql
  wait_rollout zookeeper
  wait_rollout kafka
  wait_rollout apache

  # -------------------------------------------------------------------------
  # Step 4: Observability
  # -------------------------------------------------------------------------

  info "Step 4/6: observability rollout checks"

  wait_rollout loki
  wait_rollout tempo
  wait_rollout prometheus
  wait_rollout grafana

  # -------------------------------------------------------------------------
  # Step 5: Applications
  # -------------------------------------------------------------------------

  info "Step 5/6: application rollout checks"

  wait_rollout dalogin
  wait_rollout mbook
  wait_rollout mbooks
  wait_rollout simple-service-webapp

  # -------------------------------------------------------------------------
  # Step 6: Optional seed + endpoints
  # -------------------------------------------------------------------------

  info "Step 6/6: seed and endpoint checks"

  if [[ "${do_seed}" == "true" ]]; then
    seed_mysql
    populate_pictures
  else
    info "Seed skipped"
    info "Use 'up --seed' to import MySQL seed data and populate the pictures PVC"
  fi

  check_endpoint \
    "https://milo.crabdance.com/login/"

  check_endpoint \
    "https://milo.crabdance.com/mbooks-1/rest/book/locations"

  check_endpoint \
    "https://milo.crabdance.com/simple-service-webapp/webapi/myresource"

  pass "Startup orchestration finished"
}

# ---------------------------------------------------------------------------
# Status
# ---------------------------------------------------------------------------

cmd_status() {
  info "=== Namespace resources ==="

  kubectl -n "${NAMESPACE}" \
    get deploy,pods,svc,ingress \
    -o wide

  echo

  info "=== PersistentVolumeClaims ==="

  kubectl -n "${NAMESPACE}" \
    get pvc

  echo

  info "=== Deployment status ==="

  local deployments=(
    mysql
    zookeeper
    kafka
    apache
    loki
    tempo
    prometheus
    grafana
    dalogin
    mbook
    mbooks
    simple-service-webapp
  )

  local dep

  for dep in "${deployments[@]}"; do
    if deployment_exists "${dep}"; then
      if kubectl -n "${NAMESPACE}" rollout status \
          "deployment/${dep}" \
          --timeout=5s >/dev/null 2>&1; then

        pass "deployment/${dep} ready"
      else
        warn "deployment/${dep} NOT ready"
      fi
    else
      warn "deployment/${dep} does not exist"
    fi
  done

  echo

  info "=== Endpoint checks ==="

  local endpoints=(
    "https://milo.crabdance.com/login/"
    "https://milo.crabdance.com/mbooks-1/rest/book/locations"
    "https://milo.crabdance.com/simple-service-webapp/webapi/myresource"
    "https://milo.crabdance.com/grafana/api/health"
  )

  local url

  for url in "${endpoints[@]}"; do
    if curl \
        -skL \
        --noproxy "${ENDPOINT_NO_PROXY}" \
        --connect-timeout 5 \
        --max-time "${ENDPOINT_TIMEOUT_SECONDS}" \
        "${url}" >/dev/null 2>&1; then

      pass "Reachable: ${url}"
    else
      warn "Unreachable: ${url}"
    fi
  done

  echo

  info "=== Loki / Promtail ==="

  if deployment_exists loki; then
    if kubectl -n "${NAMESPACE}" \
        get pods \
        -l app=loki \
        -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.phase}{"\n"}{end}' \
        2>/dev/null; then
      :
    fi
  fi

  if deployment_exists mbook; then
    info "mbook Promtail:"
    kubectl -n "${NAMESPACE}" logs \
      deployment/mbook \
      -c promtail \
      --tail=5 2>/dev/null || true
  fi

  if deployment_exists mbooks; then
    info "mbooks Promtail:"
    kubectl -n "${NAMESPACE}" logs \
      deployment/mbooks \
      -c promtail \
      --tail=5 2>/dev/null || true
  fi

  echo

  info "=== Minikube ==="

  minikube status || true
}

# ---------------------------------------------------------------------------
# Restart
# ---------------------------------------------------------------------------

cmd_restart() {
  local service="${1:-}"
  local build="${2:-}"
  local extra="${3:-}"

  [[ -n "${service}" ]] ||
    fail "restart requires a service"

  [[ -z "${extra}" ]] ||
    fail "Too many arguments for restart: ${service} ${build} ${extra}"

  if [[ -n "${build}" && "${build}" != "--build" ]]; then
    fail "Unsupported restart option: ${build}. Allowed: --build"
  fi

  local buildable="false"

  if service_src_dir "${service}" >/dev/null 2>&1; then
    buildable="true"
  fi

  if [[ "${build}" == "--build" ]]; then
    [[ "${buildable}" == "true" ]] ||
      fail "--build is only supported for Quarkus application services"

    build_and_load_service "${service}"
  else
    info "Skipping build/load"
  fi

  restart_deployment "${service}"

  pass "Restart completed for ${service}"
}

# ---------------------------------------------------------------------------
# Down
# ---------------------------------------------------------------------------

cmd_down() {
  info "Scaling all deployments in namespace ${NAMESPACE} to 0"
  info "PVCs will be preserved"

  local dep

  while IFS= read -r dep; do
    kubectl -n "${NAMESPACE}" scale \
      "${dep}" \
      --replicas=0 >/dev/null

    pass "Scaled ${dep} to 0"
  done < <(
    kubectl -n "${NAMESPACE}" get deployments -o name
  )

  pass "Stack stopped. PVCs are preserved."
}

# ---------------------------------------------------------------------------
# Off
# ---------------------------------------------------------------------------

cmd_off() {
  cmd_down

  if command -v minikube >/dev/null 2>&1; then
    if minikube status \
        --format '{{.Host}}' 2>/dev/null |
        grep -qi "running"; then

      info "Stopping minikube"

      minikube stop >/dev/null

      pass "minikube stopped"
    else
      info "minikube is not running"
    fi
  fi

  if command -v colima >/dev/null 2>&1; then
    if colima status 2>/dev/null | grep -qi "running"; then
      info "Stopping colima"

      colima stop >/dev/null

      pass "colima stopped"
    else
      info "colima is not running"
    fi
  fi

  pass "Local Kubernetes runtime is off"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  local cmd="${1:-help}"

  case "${cmd}" in
    up)
      if [[ "${2:-}" == "status" ]]; then
        cmd_up
        cmd_status

      elif [[ "${2:-}" == "--seed" && "${3:-}" == "status" ]]; then
        cmd_up "--seed"
        cmd_status

      else
        cmd_up "${2:-}"
      fi
      ;;

    status)
      cmd_status
      ;;
      
    pictures)
      require_cmd kubectl
      populate_pictures
      ;;
      
    restart)
      cmd_restart "${2:-}" "${3:-}"
      ;;

    down)
      cmd_down
      ;;

    off)
      cmd_off
      ;;

    help|-h|--help)
      usage
      ;;

    *)
      fail "Unknown command: ${cmd}. Run with 'help' for usage."
      ;;
  esac
}

main "$@"