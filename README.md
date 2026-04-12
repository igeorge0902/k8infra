# k8infra

Kubernetes manifests, API tests, and deployment runbook for the Cinemas booking platform.

## Contents

| File | Purpose |
|------|---------|
| `quarkus-backend.yaml` | **Primary manifest** — deploys all services (dalogin, mbook, mbooks, simple-service-webapp), MySQL, Kafka, ZooKeeper, Apache reverse proxy, and NGINX ingress into the `cinemas` namespace |
| `kubernetes.yaml` | Legacy WildFly-era manifest (reference only) |
| `README-k8s-local.md` | Step-by-step local deployment runbook (Minikube + Podman) |
| `system-documentation.html` | Comprehensive HTML documentation — architecture diagrams, database schemas, API reference, refactoring suggestions |
| `api-smoke-restassured/` | **Primary API smoke framework** — Java + RestAssured tests |
| `gen-quarkus-backend.py` | Utility to regenerate `quarkus-backend.yaml` from `kubernetes.yaml` |
| `settings-local.xml` | Maven settings for local builds |
| `tls/` | Self-signed TLS certificate + key for the NGINX ingress |

## Quick start

```bash
# Deploy to Minikube
kubectl apply -f quarkus-backend.yaml

# Seed databases (both scripts are self-contained — no fix scripts needed)
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < ../mysql_8/login.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < ../mysql_8/book.sql

# Run API tests
(cd api-smoke-restassured && mvn test)
```

For the full step-by-step guide, see [README-k8s-local.md](README-k8s-local.md).

## Kubernetes topology

```
                    ┌─────────────────┐
                    │  NGINX Ingress   │  (TLS termination, milo.crabdance.com)
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Apache Proxy    │  (:80, route-based dispatch)
                    └──┬──┬──┬──┬─────┘
         /login        │  │  │  │  /simple-service-webapp
    ┌────▼────┐  ┌─────▼┐ │  │  └────────▼──────────────┐
    │ dalogin │  │mbook │ │  │     │ simple-service-webapp│
    │ :8080   │  │:8888 │ │  │     │ :8085               │
    └──┬──────┘  └──┬───┘ │  │     └─────────────────────┘
       │            │     │  │ /mbooks-1
       │  ┌─────────┘     │  └──────▼─────┐
       │  │               │   │  mbooks   │
       │  │               │   │  :8080    │
       │  │               │   └─────┬─────┘
       ▼  ▼               │         ▼
    ┌──────────┐     ┌────▼────┐  ┌────────┐
    │ MySQL    │     │  Kafka  │  │ZooKeeper│
    │ :3306    │     │  :9092  │  │ :2181   │
    │login_+book│    └─────────┘  └────────┘
    └──────────┘
```

## Database notes

- MySQL runs with `--lower-case-table-names=1` for Hibernate entity compatibility.
- Both `mysql_8/login.sql` and `mysql_8/book.sql` are self-contained — no additional fix scripts are needed.

## CI tooling (local pre-push)

```bash
cd /Users/gyorgy.gaspar/work/cinemas/cinemas
python3 k8infra/ci/check_governance.py
```

This runs naming lint + doc drift checks in one command.

## Part of the Cinemas platform

| Service | Repo | Role |
|---------|------|------|
| dalogin-quarkus | [igeorge0902/dalogin-quarkus](https://github.com/igeorge0902/dalogin-quarkus) | Auth gateway |
| mbook-quarkus | [igeorge0902/mbook-quarkus](https://github.com/igeorge0902/mbook-quarkus) | User/device API |
| mbooks-quarkus | [igeorge0902/mbooks-quarkus](https://github.com/igeorge0902/mbooks-quarkus) | Movie/booking/payment API |
| simple-service-webapp-quarkus | [igeorge0902/simple-service-webapp-quarkus](https://github.com/igeorge0902/simple-service-webapp-quarkus) | Image server |
| **k8infra** | this repo | Kubernetes manifests, SQL fixes, deploy runbook |

