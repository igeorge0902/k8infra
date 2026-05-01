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

usage() {
  cat <<'EOF'
Usage:
  k8infra/k8s-orchestrator.sh up [--seed]
  k8infra/k8s-orchestrator.sh up [--seed] status
  k8infra/k8s-orchestrator.sh status
  k8infra/k8s-orchestrator.sh restart <dalogin|mbook|mbooks|simple-service-webapp> [--build]
  k8infra/k8s-orchestrator.sh down
  k8infra/k8s-orchestrator.sh off
  k8infra/k8s-orchestrator.sh help

Notes:
  - up applies k8infra/quarkus-backend.yaml and waits on dependency order:
    mysql -> dalogin -> mbook -> mbooks -> simple-service-webapp
  - up ... status runs a startup followed by an immediate status snapshot
  - down scales deployments in namespace cinemas to 0, preserving PVCs
  - off performs down, then stops minikube and colima when available/running
  - restart --build performs service-scoped Maven package + image build/load + rollout
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

ensure_manifest_exists() {
  [[ -f "${MANIFEST}" ]] || fail "Manifest file not found: ${MANIFEST}"
}

wait_rollout() {
  local deployment="$1"
  info "Waiting for deployment/${deployment} rollout"
  kubectl -n "${NAMESPACE}" rollout status "deployment/${deployment}" --timeout="${TIMEOUT_SECONDS}s" >/dev/null
  pass "deployment/${deployment} is ready"
}

check_endpoint() {
  local url="$1"
  local attempt http_code
  for attempt in $(seq 1 "${ENDPOINT_RETRIES}"); do
    if http_code="$(curl -skL --noproxy "${ENDPOINT_NO_PROXY}" --connect-timeout 5 --max-time "${ENDPOINT_TIMEOUT_SECONDS}" -o /dev/null -w '%{http_code}' "${url}" 2>/dev/null)"; then
      if [[ "${http_code}" != "000" ]]; then
        pass "Reachable: ${url} (HTTP ${http_code})"
        return
      fi
    fi
    warn "Endpoint probe attempt ${attempt}/${ENDPOINT_RETRIES} failed for ${url}"
    sleep 1
  done

  fail "Endpoint check failed: ${url}. If browser works but curl fails, verify proxy bypass (ENDPOINT_NO_PROXY=${ENDPOINT_NO_PROXY}) and tunnel status"
}

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
    info "colima not installed; assuming an alternative Docker runtime is already available"
  fi

  if ! minikube status --format '{{.Host}}' 2>/dev/null | grep -qi "running"; then
    info "Starting minikube with docker driver"
    minikube start --driver=docker --cpus=4 --memory=3900 >/dev/null
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
  svc_type="$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.type}' 2>/dev/null || true)"
  if [[ "${svc_type}" == "NodePort" ]]; then
    info "Patching ingress-nginx-controller service to LoadBalancer"
    kubectl -n ingress-nginx patch svc ingress-nginx-controller -p '{"spec":{"type":"LoadBalancer"}}' >/dev/null
    pass "ingress-nginx-controller patched to LoadBalancer"
  fi
}

seed_mysql() {
  local login_sql="${REPO_ROOT}/mysql_8/login.sql"
  local book_sql="${REPO_ROOT}/mysql_8/book.sql"

  [[ -f "${login_sql}" ]] || fail "Missing SQL seed file: ${login_sql}"
  [[ -f "${book_sql}" ]] || fail "Missing SQL seed file: ${book_sql}"

  info "Seeding mysql with mysql_8/login.sql"
  kubectl -n "${NAMESPACE}" exec -i deploy/mysql -- mysql -uroot -prootpw < "${login_sql}"
  info "Seeding mysql with mysql_8/book.sql"
  kubectl -n "${NAMESPACE}" exec -i deploy/mysql -- mysql -uroot -prootpw < "${book_sql}"
  pass "MySQL seed completed"
}

service_src_dir() {
  case "$1" in
    dalogin) echo "dalogin-quarkus" ;;
    mbook) echo "mbook-quarkus" ;;
    mbooks) echo "mbooks-quarkus" ;;
    simple-service-webapp) echo "simple-service-webapp-quarkus" ;;
    *) return 1 ;;
  esac
}

service_image() {
  case "$1" in
    dalogin) echo "dalogin-quarkus:local" ;;
    mbook) echo "mbook-quarkus:local" ;;
    mbooks) echo "mbooks-quarkus:local" ;;
    simple-service-webapp) echo "simple-service-webapp-quarkus:local" ;;
    *) return 1 ;;
  esac
}

build_and_load_service() {
  local service="$1"
  local src_dir image
  src_dir="$(service_src_dir "${service}")" || fail "Unsupported service for restart --build: ${service}"
  image="$(service_image "${service}")"

  info "Packaging ${src_dir}"
  (
    cd "${REPO_ROOT}/${src_dir}"
    ./mvnw package -DskipTests
  )

  if command -v docker >/dev/null 2>&1; then
    info "Building image via minikube docker-env: ${image}"
    eval "$(minikube docker-env)"
    docker build -t "${image}" "${REPO_ROOT}/${src_dir}"
    eval "$(minikube docker-env --unset)"
    pass "Image built inside minikube docker daemon"
    return
  fi

  if command -v podman >/dev/null 2>&1; then
    info "Building image via podman: ${image}"
    podman build -t "${image}" "${REPO_ROOT}/${src_dir}"
    podman save "localhost/${image}" | minikube image load --daemon=false -
    pass "Image built with podman and loaded into minikube"
    return
  fi

  fail "Neither docker nor podman is available for restart --build"
}

cmd_up() {
  local do_seed="false"
  if [[ "${1:-}" == "--seed" ]]; then
    do_seed="true"
  elif [[ -n "${1:-}" ]]; then
    fail "Unsupported argument for up: ${1}. Allowed: --seed"
  fi

  info "Step 1/5: runtime and cluster checks"
  ensure_manifest_exists
  ensure_runtime
  patch_ingress_lb_if_needed

  info "Step 2/5: apply backend manifest"
  kubectl apply -f "${MANIFEST}" >/dev/null
  pass "Manifest applied: ${MANIFEST}"

  info "Step 3/5: dependency-aware rollout checks"
  wait_rollout mysql
  wait_rollout dalogin
  wait_rollout mbook
  wait_rollout mbooks
  wait_rollout simple-service-webapp

  info "Step 4/5: optional seed"
  if [[ "${do_seed}" == "true" ]]; then
    seed_mysql
  else
    info "Seed skipped (use 'up --seed' to import mysql_8/login.sql and mysql_8/book.sql)"
  fi

  info "Step 5/5: endpoint reachability"
  check_endpoint "https://milo.crabdance.com/login/"
  check_endpoint "https://milo.crabdance.com/mbooks-1/rest/book/locations"
  check_endpoint "https://milo.crabdance.com/simple-service-webapp/webapi/myresource"

  pass "Startup orchestration finished"
}

cmd_status() {
  info "Namespace resources"
  kubectl -n "${NAMESPACE}" get deploy,pods,svc,ingress | cat

  info "Dependency rollouts"
  for dep in mysql dalogin mbook mbooks simple-service-webapp; do
    if kubectl -n "${NAMESPACE}" rollout status "deployment/${dep}" --timeout=5s >/dev/null 2>&1; then
      pass "deployment/${dep} ready"
    else
      printf "[WARN] deployment/%s not ready\n" "${dep}"
    fi
  done

  info "Endpoint checks"
  for url in \
    "https://milo.crabdance.com/login/" \
    "https://milo.crabdance.com/mbooks-1/rest/book/locations" \
    "https://milo.crabdance.com/simple-service-webapp/webapi/myresource"; do
    if curl -sk --max-time 5 "$url" >/dev/null; then
      pass "Reachable: ${url}"
    else
      printf "[WARN] Unreachable: %s\n" "${url}"
    fi
  done
}

cmd_restart() {
  local service="${1:-}"
  local build="${2:-}"
  local extra="${3:-}"

  [[ -n "${service}" ]] || fail "restart requires a service: dalogin|mbook|mbooks|simple-service-webapp"
  service_src_dir "${service}" >/dev/null || fail "Unsupported service: ${service}"
  [[ -z "${extra}" ]] || fail "Too many arguments for restart: ${service} ${build} ${extra}"
  if [[ -n "${build}" && "${build}" != "--build" ]]; then
    fail "Unsupported restart option: ${build}. Allowed: --build"
  fi

  if [[ "${build}" == "--build" ]]; then
    build_and_load_service "${service}"
  else
    info "Skipping build/load (use 'restart <service> --build' for full service-scoped rebuild)"
  fi

  info "Rolling restart deployment/${service}"
  kubectl -n "${NAMESPACE}" rollout restart "deployment/${service}" >/dev/null
  wait_rollout "${service}"
  pass "Restart completed for ${service}"
}

cmd_down() {
  info "Scaling all deployments in namespace ${NAMESPACE} to 0 (PVCs preserved)"
  local dep
  while IFS= read -r dep; do
    kubectl -n "${NAMESPACE}" scale "${dep}" --replicas=0 >/dev/null
    pass "Scaled ${dep} to 0"
  done < <(kubectl -n "${NAMESPACE}" get deployments -o name)

  pass "Stack stopped. PVCs are preserved."
}

cmd_off() {
  cmd_down

  if command -v minikube >/dev/null 2>&1; then
    if minikube status --format '{{.Host}}' 2>/dev/null | grep -qi "running"; then
      info "Stopping minikube"
      minikube stop >/dev/null
      pass "minikube stopped"
    else
      info "minikube is not running"
    fi
  else
    info "minikube not installed; skipping stop"
  fi

  if command -v colima >/dev/null 2>&1; then
    if colima status 2>/dev/null | grep -qi "running"; then
      info "Stopping colima"
      colima stop >/dev/null
      pass "colima stopped"
    else
      info "colima is not running"
    fi
  else
    info "colima not installed; skipping stop"
  fi

  pass "Local Kubernetes runtime is off"
}

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

