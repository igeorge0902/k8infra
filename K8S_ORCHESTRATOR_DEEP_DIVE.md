# Kubernetes Orchestrator Deep Dive (`k8infra/k8s-orchestrator.sh`)

## 1) Review objective
This document explains the implementation of `k8infra/k8s-orchestrator.sh` in detail so it can be reviewed thoroughly for correctness, reliability, and maintainability.

Primary review goals:
- Verify behavior of each command (`up`, `status`, `restart`, `down`, `help`)
- Verify dependency order and failure handling
- Verify idempotency and safe reruns
- Identify assumptions, limits, and extension points

---

## 2) Where it fits in this repository
The orchestrator sits between developer operations and existing infra assets.

Inputs and dependencies:
- Manifest: `k8infra/quarkus-backend.yaml`
- Runbook: `k8infra/README-k8s-local.md`
- Seed files: `mysql_8/login.sql`, `mysql_8/book.sql`

Target services explicitly managed in rollout order:
1. `mysql`
2. `dalogin`
3. `mbook`
4. `mbooks`
5. `simple-service-webapp`

Namespace contract:
- Hardcoded as `cinemas`

Host/endpoints contract used for final checks:
- `https://milo.crabdance.com/login/`
- `https://milo.crabdance.com/mbooks-1/rest/book/locations`
- `https://milo.crabdance.com/simple-service-webapp/webapi/myresource`

---

## 3) Script design model
Core shell settings:
- `set -euo pipefail`

Meaning:
- `-e`: exit on command failure
- `-u`: treat unset variables as errors
- `-o pipefail`: fail pipeline if any command fails

Operational consequences:
- The script is intentionally fail-fast.
- Most unexpected errors stop execution immediately.
- This is good for deterministic CI/operator behavior, but it also means partial progress is possible (e.g., manifest applied, then rollout fails).

Logging model:
- `[INFO]` for step narration
- `[PASS]` for successful checkpoints
- `[FAIL]` + immediate exit for hard failures
- `[WARN]` appears in `status` mode for non-blocking checks

---

## 4) Command contract and exact behavior

### `help`
Syntax:
```bash
./k8infra/k8s-orchestrator.sh help
```
Behavior:
- Prints usage and notes
- Exit code `0`

### `up [--seed]`
Syntax:
```bash
./k8infra/k8s-orchestrator.sh up
./k8infra/k8s-orchestrator.sh up --seed
```
Behavior (5 phases):
1. Runtime and cluster checks
2. Manifest apply
3. Ordered rollout waits
4. Optional MySQL seed import
5. Endpoint reachability checks

Exit behavior:
- Exits non-zero on first failure (missing prerequisite, rollout timeout, seed failure, endpoint failure)

### `status`
Syntax:
```bash
./k8infra/k8s-orchestrator.sh status
```
Behavior:
- Prints namespace resources
- Checks rollout status of key deployments with short timeout
- Checks endpoint reachability
- Emits warnings for degraded state

Exit behavior:
- Intended as non-blocking health snapshot; warnings do not force fail

### `restart <service> [--build]`
Syntax:
```bash
./k8infra/k8s-orchestrator.sh restart dalogin
./k8infra/k8s-orchestrator.sh restart mbook --build
```
Supported service values:
- `dalogin`
- `mbook`
- `mbooks`
- `simple-service-webapp`

Behavior:
- Validates service name
- Optional `--build`: package + image build/load for selected service only
- Performs rollout restart of selected deployment
- Waits for selected deployment readiness

### `down`
Syntax:
```bash
./k8infra/k8s-orchestrator.sh down
```
Behavior:
- Scales all deployments in `cinemas` to `0`
- Does not delete PVCs

---

## 5) Deep flow walk-through (`up`)

### Phase 1: prerequisite/runtime checks (`ensure_runtime`)
Required binaries:
- `kubectl`
- `minikube`
- `curl`

Optional runtime:
- `colima`
  - If present and not running: starts with
    - `colima start --cpu 4 --memory 4 --disk 20`
  - If not installed: logs info and continues (assumes an alternative docker-compatible runtime)

Minikube behavior:
- If not running, starts with
  - `minikube start --driver=docker --cpus=4 --memory=3900`
- Always enables ingress addon

Ingress service patching (`patch_ingress_lb_if_needed`):
- Reads `ingress-nginx-controller` service type
- If `NodePort`, patches to `LoadBalancer`
- Purpose: align with tunnel-based local HTTPS routing

### Phase 2: manifest apply
Command:
```bash
kubectl apply -f k8infra/quarkus-backend.yaml
```
Properties:
- Idempotent apply
- Output is suppressed in script to keep logs concise

### Phase 3: dependency-aware rollouts
Sequence is strict and blocking:
1. `deployment/mysql`
2. `deployment/dalogin`
3. `deployment/mbook`
4. `deployment/mbooks`
5. `deployment/simple-service-webapp`

Mechanism:
```bash
kubectl -n cinemas rollout status deployment/<name> --timeout=${TIMEOUT_SECONDS}s
```

Default timeout:
- `TIMEOUT_SECONDS=300` (env-overridable)

### Phase 4: optional seed
Enabled only if `--seed` is passed.

Actions:
- Verifies `mysql_8/login.sql` exists
- Verifies `mysql_8/book.sql` exists
- Executes both files against mysql deployment using root credentials

### Phase 5: endpoint checks
Uses:
```bash
curl -sk --max-time 10 <url>
```
Notes:
- `-k` ignores TLS trust errors (local self-signed setup)
- Reachability is checked; semantic response content is not validated here

---

## 6) Dependency model: explicit vs implicit

Explicitly enforced by script:
- App startup ordering among mysql + core services

Not explicitly gated in ordered waits:
- `zookeeper`
- `kafka`
- `apache`
- observability components (prometheus/tempo/grafana)

Impact:
- Script can report success for core chain while a non-gated component is degraded.
- This is acceptable for local startup acceleration but should be explicitly understood in review.

---

## 7) Restart build pipeline internals

`restart <service> --build` includes:
1. Service mapping resolution:
   - source dir mapping (`*-quarkus` folder)
   - image tag mapping (`*:local`)
2. Maven package in service directory (`./mvnw package -DskipTests`)
3. Image build/load strategy:
   - Prefer Docker with `minikube docker-env`
   - Fallback to Podman + `minikube image load`
4. Rollout restart of only selected deployment
5. Wait for selected deployment readiness

Why this matters:
- Keeps blast radius minimal (single deployment)
- Aligns with current runbook conventions and tag names

---

## 8) Error model and diagnostics

Hard-fail classes (exit non-zero):
- Required command missing (`kubectl`, `minikube`, `curl`)
- Minikube start failure
- Manifest apply failure
- Rollout wait timeout/failure
- Missing SQL seed file when `--seed` used
- MySQL seed command failure
- Endpoint check failure in `up`
- Unsupported command/service

Soft-fail classes (warning only):
- Deployment not ready in `status`
- Endpoint unreachable in `status`

Diagnostic quality:
- Messages are concise and step-scoped.
- They are suitable for terminal operations and simple CI logs.
- There is no machine-readable JSON mode currently.

---

## 9) Idempotency and rerun behavior

Generally idempotent:
- `up` can be rerun safely due to apply semantics and readiness gates
- `status` is read-only
- `restart` without `--build` is safe and scoped
- `down` repeated calls are safe (already scaled deployments remain at 0)

State persistence:
- `down` preserves PVC-backed data
- Seed behavior depends on SQL script design and DB objects; current scripts are intended for repeated local use

---

## 10) Security and operational posture
Current model is local-dev oriented.

Notable choices:
- Uses root DB password in seed commands (present in local manifest model)
- Uses `curl -k` for local TLS checks
- Uses `eval "$(minikube docker-env)"` in build path

Review focus:
- Ensure this stays in local scope only
- Avoid promoting these defaults into non-local environments
- Keep secrets/documentation sanitized outside local infra context

---

## 11) Observability of the orchestrator itself
What it has:
- Human-readable step logs and pass/fail markers

What it does not yet have:
- Timestamps in every line
- Structured log output mode (JSON)
- Per-step duration metrics
- Built-in artifact/report generation

Workable review approach today:
- Capture terminal output for each command path
- Correlate failures with `kubectl describe`, pod logs, and events

---

## 12) Known limitations
- Hardcoded namespace (`cinemas`)
- Hardcoded manifest path (`k8infra/quarkus-backend.yaml`)
- Hardcoded endpoint host (`milo.crabdance.com`)
- No dry-run mode
- No selective `up` target list (always full chain)
- No semantic endpoint assertion beyond reachability

These are acceptable for current local-dev scope, but should be tracked if this script becomes a broader automation entrypoint.

---

## 13) Extension guide for reviewers
If adding another service to managed lifecycle:
1. Add service to `service_src_dir()`
2. Add service to `service_image()`
3. Insert rollout wait in `cmd_up()` at correct dependency point
4. Add optional endpoint checks in `cmd_up()` and `cmd_status()`
5. Update `k8infra/README-k8s-local.md`
6. Update Speckit files (`specify`, `plan`, `tasks`, and implementation docs)

---

## 14) Thorough review checklist

### Functional contract
- [ ] `help` usage is complete and accurate
- [ ] `up` performs all 5 phases
- [ ] `up --seed` imports both SQL files
- [ ] `status` reports both K8s resource view and endpoint reachability
- [ ] `restart <service>` is service-scoped only
- [ ] `restart <service> --build` updates image path and deployment
- [ ] `down` preserves PVC-backed state

### Reliability/failure handling
- [ ] Missing required CLI fails immediately with clear message
- [ ] Timeout behavior works with reduced `TIMEOUT_SECONDS`
- [ ] Failing endpoint in `up` produces non-zero exit
- [ ] Failing endpoint in `status` warns but continues

### Environment assumptions
- [ ] Behavior with `colima` installed and stopped
- [ ] Behavior with no `colima` but working docker runtime
- [ ] Behavior when ingress service is already `LoadBalancer`
- [ ] Behavior when ingress service starts as `NodePort`

### Consistency and docs
- [ ] Script values match `k8infra/README-k8s-local.md`
- [ ] Script service names match deployment names in `k8infra/quarkus-backend.yaml`
- [ ] Speckit artifacts remain aligned with current script behavior

---

## 15) Suggested evidence package for sign-off
For a clean review trail, capture:
1. Command logs for:
   - `help`
   - `up`
   - `status`
   - `restart mbook --build`
   - `down`
2. `kubectl -n cinemas get deploy,pods,svc,ingress` before/after
3. Endpoint curl outputs (or status snippets)
4. One forced-timeout run (`TIMEOUT_SECONDS=...`) and outcome
5. Notes for security/performance reviewers

---

## 16) Traceability
- Spec: `.specify/features/System/speckit.system.k8s-startup-orchestrator.specify`
- Plan: `.specify/features/System/speckit.system.k8s-startup-orchestrator.plan`
- Tasks: `.specify/features/System/speckit.system.k8s-startup-orchestrator.tasks`
- Clarification: `.specify/features/System/speckit.system.k8s-startup-orchestrator.implementation.md`
- Summary: `K8S_ORCHESTRATOR_SUMMARY.md`
- Implementation script: `k8infra/k8s-orchestrator.sh`
- Runbook integration: `k8infra/README-k8s-local.md`

