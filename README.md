# k8infra

Kubernetes manifests, database fix scripts, API tests, and deployment runbook for the Cinemas booking platform.

## Contents

| File | Purpose |
|------|---------|
| `quarkus-backend.yaml` | **Primary manifest** — deploys all services (dalogin, mbook, mbooks, simple-service-webapp), MySQL, Kafka, ZooKeeper, Apache reverse proxy, and NGINX ingress into the `cinemas` namespace |
| `kubernetes.yaml` | Legacy WildFly-era manifest (reference only) |
| `fix-sprocs.sql` | **Must apply after importing `login.sql`** — rewrites stored-procedure bodies from `login.` → `login_.` table references, adds missing `profilePicture` column |
| `fix-triggers.sql` | **Must apply after `fix-sprocs.sql`** — recreates triggers with correct table-name casing for MySQL 8 on Linux |
| `README-k8s-local.md` | Step-by-step local deployment runbook (Minikube + Podman) |
| `system-documentation.html` | Comprehensive HTML documentation — architecture diagrams, database schemas, API reference, refactoring suggestions |
| `test-login.py` | End-to-end API test — HMAC login + user retrieval + mbooks smoke test |
| `test-login-admin.py` | Extended API test — login + admin endpoint + user data validation |
| `gen-quarkus-backend.py` | Utility to regenerate `quarkus-backend.yaml` from `kubernetes.yaml` |
| `settings-local.xml` | Maven settings for local builds |
| `tls/` | Self-signed TLS certificate + key for the NGINX ingress |

## Quick start

```bash
# Deploy to Minikube
kubectl apply -f quarkus-backend.yaml

# Seed databases
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < ../mysql_8/login.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < ../mysql_8/book.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < fix-sprocs.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < fix-triggers.sql

# Run API tests
python3 test-login.py
python3 test-login-admin.py
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
- After importing `login.sql`, always apply `fix-sprocs.sql` then `fix-triggers.sql`.

## Part of the Cinemas platform

| Service | Repo | Role |
|---------|------|------|
| dalogin-quarkus | [igeorge0902/dalogin-quarkus](https://github.com/igeorge0902/dalogin-quarkus) | Auth gateway |
| mbook-quarkus | [igeorge0902/mbook-quarkus](https://github.com/igeorge0902/mbook-quarkus) | User/device API |
| mbooks-quarkus | [igeorge0902/mbooks-quarkus](https://github.com/igeorge0902/mbooks-quarkus) | Movie/booking/payment API |
| simple-service-webapp-quarkus | [igeorge0902/simple-service-webapp-quarkus](https://github.com/igeorge0902/simple-service-webapp-quarkus) | Image server |
| **k8infra** | this repo | Kubernetes manifests, SQL fixes, deploy runbook |

