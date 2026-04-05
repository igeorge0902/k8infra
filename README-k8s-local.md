# Local Kubernetes Runbook (Quarkus stack)

This runbook brings up all backend services (`dalogin-quarkus`, `mbook-quarkus`, `mbooks-quarkus`, `simple-service-webapp-quarkus`) plus MySQL, Kafka, Zookeeper, and an Apache reverse proxy for local development.

## Prerequisites

| Tool | Install | Notes |
|------|---------|-------|
| Docker CLI | `brew install docker` | Docker **client** only — no Docker Desktop licence needed |
| colima | `brew install colima` | Lightweight Docker-compatible runtime for macOS |
| Minikube | `brew install minikube` | Local Kubernetes cluster |
| Podman *(optional)* | `brew install podman` | Only needed if you prefer Podman for image builds |
| kubectl | `brew install kubectl` | Kubernetes CLI (or via `minikube kubectl`) |

## 1) Start the container runtime and cluster

### Start colima (Docker daemon)

```bash
colima start --cpu 4 --memory 8 --disk 60
```

> colima provides a Docker-compatible daemon without Docker Desktop.
> The Docker CLI (`docker build`, `docker images`, etc.) works against it.
> To stop: `colima stop`. To check status: `colima status`.

### Start Minikube with the Docker driver

```bash
minikube start --driver=docker --cpus=4 --memory=8192
```

Enable the NGINX ingress controller:

```bash
minikube addons enable ingress
```

> **Why Docker instead of qemu2?** The Docker driver runs Minikube as a container
> on the host network. `minikube tunnel` provides a stable LoadBalancer IP on
> `127.0.0.1` — no more `kubectl port-forward` + `pf` redirect that dies on idle,
> sleep/wake, or reboot. Image loading is also simpler (no tarball + retag dance).

## 2) Build Quarkus artifacts + container images

From repo root:

```bash
cd /Users/gyorgy.gaspar/work/cinemas/cinemas
```

Build JAR layouts first:

```bash
(cd dalogin-quarkus            && ./mvnw package -DskipTests)
(cd mbook-quarkus              && ./mvnw package -DskipTests)
(cd mbooks-quarkus             && ./mvnw package -DskipTests)
(cd simple-service-webapp-quarkus && ./mvnw package -DskipTests)
```

> If behind a corporate proxy that blocks Maven Central, use the bundled settings:
> `./mvnw -s ../k8infra/settings-local.xml package -DskipTests`

### Build images and load into Minikube

**Option A — Build inside Minikube's Docker (fastest, no loading needed):**

```bash
eval $(minikube docker-env)

docker build -t dalogin-quarkus:local              ./dalogin-quarkus
docker build -t mbook-quarkus:local                ./mbook-quarkus
docker build -t mbooks-quarkus:local               ./mbooks-quarkus
docker build -t simple-service-webapp-quarkus:local ./simple-service-webapp-quarkus

eval $(minikube docker-env --unset)
```

> `eval $(minikube docker-env)` points the Docker CLI at Minikube's internal daemon.
> Images built this way are immediately visible to Kubernetes — no `image load` or
> retag step. Run `--unset` afterwards to restore the normal Docker context.

**Option B — Build with Podman, then load:**

```bash
podman build -t dalogin-quarkus:local              ./dalogin-quarkus
podman build -t mbook-quarkus:local                ./mbook-quarkus
podman build -t mbooks-quarkus:local               ./mbooks-quarkus
podman build -t simple-service-webapp-quarkus:local ./simple-service-webapp-quarkus
```

Load into Minikube (Docker driver — no retag needed):

```bash
for img in dalogin-quarkus mbook-quarkus mbooks-quarkus simple-service-webapp-quarkus; do
  podman save localhost/${img}:local | minikube image load --daemon=false -
done
```

> With the Docker driver, `minikube image load` works reliably and the retag
> step (`ctr images tag`) that was required with qemu2 is **not needed**.

## 3) Deploy backend manifests

```bash
kubectl apply -f k8infra/quarkus-backend.yaml
kubectl -n cinemas get pods          # wait until all pods are Running
```

## 4) Seed databases

The manifest creates empty `login_` and `book` databases via an init ConfigMap.
MySQL data is persisted on a PVC (`mysql-pvc`) — the import below only needs to
be run once per cluster (it survives pod restarts):

```bash
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < mysql_8/login.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < mysql_8/book.sql
```

> Both SQL scripts are **self-contained** — they include correct table-name casing
> for triggers, `login_.` references in all stored procedures, and the `profilePicture`
> column on `logins`. No further fix scripts need to be applied.

> **Important:** Do **not** create a database named `login` (without underscore).
> Only `login_` should exist. If a stale `login` database is present, drop it:
> `kubectl -n cinemas exec deploy/mysql -- mysql -uroot -prootpw -e "DROP DATABASE IF EXISTS login;"`

Verify:

```bash
kubectl -n cinemas exec deploy/mysql -- mysql -uroot -prootpw \
  -e "SELECT COUNT(*) AS users FROM login_.logins; SELECT COUNT(*) AS movies FROM book.movie;"
# → users 5, movies 103
```

## 4a) Restore from an external MySQL master (optional)

The K8s MySQL pod is a **fully read-write, independent clone** — not a read-only
replica. You can restore production data from an external master whenever you
want, then continue making local writes (bookings, test users, etc.) without
affecting the master.

### Dump from the external master

From a machine that can reach the master:

```bash
mysqldump -h <master-host> -u root -p \
  --databases login_ book \
  --routines --triggers --events \
  --single-transaction \
  --set-gtid-purged=OFF \
  > master-dump.sql
```

> `--single-transaction` takes a consistent InnoDB snapshot without table locks.
> `--set-gtid-purged=OFF` prevents GTID errors when importing into an unrelated server.
> `--routines --triggers --events` includes stored procedures, triggers, and scheduled events.

### Import into the K8s MySQL pod

```bash
# Drop and recreate to get a clean slate
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw \
  -e "DROP DATABASE IF EXISTS login_; DROP DATABASE IF EXISTS book;"

# Import the dump
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < master-dump.sql

# Re-grant privileges (the dump may not include user grants)
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw \
  -e "CREATE USER IF NOT EXISTS 'sqluser'@'%' IDENTIFIED BY 'sqluserpw';
      GRANT ALL PRIVILEGES ON login_.* TO 'sqluser'@'%';
      GRANT ALL PRIVILEGES ON book.* TO 'sqluser'@'%';
      FLUSH PRIVILEGES;"
```

### Or just use the repo SQL files

If you don't have access to the external master, the repo SQL dumps are the
canonical seed data source:

```bash
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < mysql_8/login.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < mysql_8/book.sql
```

### Persisting data across pod restarts

MySQL now uses `mysql-pvc` (a 2 Gi PersistentVolumeClaim) by default — **data
survives `kubectl rollout restart` and pod crashes**. No extra configuration is
needed.

Data is **lost** when the Minikube cluster itself is deleted (`minikube delete`),
since PVCs are tied to the cluster. To reset MySQL to a clean state, delete the
PVC and re-apply the manifest, then re-seed:

```bash
kubectl -n cinemas delete pvc mysql-pvc
kubectl apply -f k8infra/quarkus-backend.yaml
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < mysql_8/login.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < mysql_8/book.sql
```

### Re-sync workflow (restore from master again)

When you want to reset the K8s database back to the master's state:

```bash
# 1. Take a fresh dump from the master
mysqldump -h <master-host> -u root -p \
  --databases login_ book \
  --routines --triggers --events \
  --single-transaction --set-gtid-purged=OFF \
  > master-dump.sql

# 2. Drop everything and re-import
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw \
  -e "DROP DATABASE IF EXISTS login_; DROP DATABASE IF EXISTS book;"
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < master-dump.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw \
  -e "CREATE USER IF NOT EXISTS 'sqluser'@'%' IDENTIFIED BY 'sqluserpw';
      GRANT ALL PRIVILEGES ON login_.* TO 'sqluser'@'%';
      GRANT ALL PRIVILEGES ON book.* TO 'sqluser'@'%';
      FLUSH PRIVILEGES;"

# 3. Restart services to clear Hibernate L2 cache and connection pools
kubectl -n cinemas rollout restart deployment/dalogin deployment/mbook deployment/mbooks
```

> **Why restart services?** Hibernate's L2 cache (Infinispan) in `mbook` and
> `mbooks` caches Movie, Venue, Location, and Ticket entities. After a full
> database re-import, cached entity IDs may be stale. Restarting clears the
> cache. Alternatively, you can wait for the cache TTL to expire (configured in
> `infinispan-configs-local.xml`).

## 4b) Populate pictures volume

The `simple-service-webapp` pod serves images from a PVC.
Copy the repo `pictures/` content into the running pod:

```bash
kubectl -n cinemas cp pictures/ \
  $(kubectl -n cinemas get pod -l app=simple-service-webapp \
      -o jsonpath='{.items[0].metadata.name}'):/pictures/
```

Alternatively, for local Minikube you can mount the host folder directly:

```bash
minikube mount $(pwd)/pictures:/pictures &
```

and change the PVC to a `hostPath` volume pointing to `/pictures`.

## 5) HTTPS & iOS simulator access

The ingress terminates TLS with a self-signed certificate.

### Generate TLS cert (one-time)

```bash
mkdir -p k8infra/tls
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout k8infra/tls/tls.key \
  -out k8infra/tls/tls.crt \
  -subj "/CN=milo.crabdance.com" \
  -addext "subjectAltName=DNS:milo.crabdance.com,DNS:localhost"
```

### Create the K8s TLS secret

```bash
kubectl create secret tls cinemas-tls \
  --cert=k8infra/tls/tls.crt \
  --key=k8infra/tls/tls.key \
  -n cinemas
```

The ingress in `quarkus-backend.yaml` already references `cinemas-tls`.

### Expose locally with `minikube tunnel`

Point `milo.crabdance.com` to localhost (iOS simulator uses host DNS):

```bash
echo "127.0.0.1 milo.crabdance.com" | sudo tee -a /etc/hosts
```

Flush any leftover `pf` rules from a previous qemu2 setup (they intercept port 443):

```bash
sudo pfctl -F all 2>/dev/null; true
```

The ingress addon may create the controller service as `NodePort` instead of `LoadBalancer`.
Check and patch if needed (the tunnel only assigns IPs to `LoadBalancer` services):

```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller
# If TYPE is NodePort:
kubectl -n ingress-nginx patch svc ingress-nginx-controller \
  -p '{"spec":{"type":"LoadBalancer"}}'
```

Start the tunnel (keeps running in the foreground — use a dedicated terminal):

```bash
sudo minikube tunnel
```

> **How it works:** `minikube tunnel` assigns `127.0.0.1` as the external IP for
> the `ingress-nginx-controller` LoadBalancer service. Traffic to `127.0.0.1:443`
> goes directly to the NGINX ingress — no `kubectl port-forward` or `pf` redirect
> needed. The tunnel auto-reconnects after sleep/wake.
>
> **`sudo` is required** because it binds to privileged port 443. The tunnel
> process stays running; stop it with Ctrl+C.

### Verify

```bash
curl -sk https://milo.crabdance.com/login/
curl -sk https://milo.crabdance.com/mbooks-1/rest/book/movies | head -c 200
curl -sk https://milo.crabdance.com/simple-service-webapp/webapi/myresource
# → Got it
```

Verify WebSocket upgrade (must use `--http1.1` — HTTP/2 strips `Connection: Upgrade`):

```bash
curl -sk --http1.1 -o /dev/null -w "%{http_code}\n" \
  -H 'Upgrade: websocket' -H 'Connection: Upgrade' \
  -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
  -H 'Sec-WebSocket-Version: 13' \
  https://milo.crabdance.com/mbook-1/ws
# → 101
```

The iOS app (via `URLManager.baseURL = "https://milo.crabdance.com"`) and the `CustomURLSessionDelegate`
already trust self-signed certs for `milo.crabdance.com`.

## 6) Quick checks

```bash
kubectl -n cinemas get svc,ingress
kubectl -n cinemas get pods
curl -sk https://milo.crabdance.com/login/
curl -sk https://milo.crabdance.com/mbook-1/rest/device/test
curl -sk https://milo.crabdance.com/mbooks-1/rest/book/locations
curl -sk https://milo.crabdance.com/simple-service-webapp/webapi/myresource
# → Got it
```

## 7) Run the API tests

```bash
python3 k8infra/test-login-admin.py
python3 k8infra/test-login.py
```

## 8) Redeploy after code changes

After editing source, rebuild and reload only the changed service.

### Service reference

| Service | Source directory | Image name | K8s deployment name |
|---------|-----------------|------------|---------------------|
| dalogin | `dalogin-quarkus/` | `dalogin-quarkus:local` | `dalogin` |
| mbook | `mbook-quarkus/` | `mbook-quarkus:local` | `mbook` |
| mbooks | `mbooks-quarkus/` | `mbooks-quarkus:local` | `mbooks` |
| simple-service-webapp | `simple-service-webapp-quarkus/` | `simple-service-webapp-quarkus:local` | `simple-service-webapp` |

Replace `<dir>`, `<image>`, and `<deployment>` below with values from the table.

**If using `minikube docker-env` (Option A):**

```bash
eval $(minikube docker-env)
(cd <dir> && ./mvnw package -DskipTests)
docker build -t <image>:local ./<dir>
eval $(minikube docker-env --unset)
kubectl -n cinemas rollout restart deployment/<deployment>
```

Example — redeploy `dalogin` after a code change:

```bash
eval $(minikube docker-env)
(cd dalogin-quarkus && ./mvnw package -DskipTests)
docker build -t dalogin-quarkus:local ./dalogin-quarkus
eval $(minikube docker-env --unset)
kubectl -n cinemas rollout restart deployment/dalogin
```

**If using Podman (Option B):**

```bash
(cd <dir> && ./mvnw package -DskipTests)
podman build -t <image>:local ./<dir>
podman save localhost/<image>:local | minikube image load --daemon=false -
kubectl -n cinemas rollout restart deployment/<deployment>
```

Example — redeploy `mbooks` after a code change:

```bash
(cd mbooks-quarkus && ./mvnw package -DskipTests)
podman build -t mbooks-quarkus:local ./mbooks-quarkus
podman save localhost/mbooks-quarkus:local | minikube image load --daemon=false -
kubectl -n cinemas rollout restart deployment/mbooks
```

### Redeploy all four services at once

**Option A (minikube docker-env):**

```bash
eval $(minikube docker-env)
for svc in dalogin-quarkus mbook-quarkus mbooks-quarkus simple-service-webapp-quarkus; do
  (cd "$svc" && ./mvnw package -DskipTests)
  docker build -t "${svc}:local" "./${svc}"
done
eval $(minikube docker-env --unset)
kubectl -n cinemas rollout restart deployment/dalogin deployment/mbook deployment/mbooks deployment/simple-service-webapp
```

**Option B (Podman):**

```bash
for svc in dalogin-quarkus mbook-quarkus mbooks-quarkus simple-service-webapp-quarkus; do
  (cd "$svc" && ./mvnw package -DskipTests)
  podman build -t "${svc}:local" "./${svc}"
  podman save "localhost/${svc}:local" | minikube image load --daemon=false -
done
kubectl -n cinemas rollout restart deployment/dalogin deployment/mbook deployment/mbooks deployment/simple-service-webapp
```

### Verify the rollout

```bash
kubectl -n cinemas rollout status deployment/<deployment>
# or watch all pods:
kubectl -n cinemas get pods -w
```

## Notes specific to this codebase

- All external backend traffic goes through an in-cluster Apache reverse proxy service (`apache`) that fronts `/login`, `/mbook-1`, `/mbooks-1`, and `/simple-service-webapp`.
- Film-review Angular routing uses plain hash routes (`#/...`), not hashbang (`#!/...`) — this is configured via `$locationProvider.hashPrefix('')` in `film-review/app.js`. Canonical URL example: `https://milo.crabdance.com/login/film-review/#/venues-list`.
- Legacy login/register Angular scripts are served from `/login/film-review/jsR/...` (filesystem: `dalogin-quarkus/src/main/resources/META-INF/resources/film-review/jsR/`).
- **Apache proxy rule ordering matters.** In `proxy.conf`, WebSocket routes (`/mbook-1/ws`, `/mbooks-1/ws`) must appear **before** their parent HTTP routes (`/mbook-1`, `/mbooks-1`). Apache `mod_proxy` is first-match — if the HTTP route comes first it swallows WebSocket upgrade requests and the iOS client gets `Socket is not connected`.
- `dalogin` expects one backend base URL (`WILDFLY_URL`) for both `/mbook-1` and `/mbooks-1`; it is pointed to the Apache service (`http://apache`, port 80).
- MySQL runs with `--lower-case-table-names=1` so that Hibernate entity names (lowercase) match the dump's mixed-case table names.
- Kafka topics: producers publish to `ios-movies-notifications2` (movies) and `ios-users-notifications` (users); consumers subscribe to matching topics. Both producers and consumers read `BOOTSTRAP_URL` from the environment.
- iOS URLs are centralised in `URLManager.swift` (`baseHost = "milo.crabdance.com"`); the self-signed cert is trusted via `CustomURLSessionDelegate`. To point at a different host, change only `URLManager.baseHost`.
- To remove the hosts entry: `sudo sed -i '' '/milo.crabdance.com/d' /etc/hosts`

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `minikube tunnel` won't bind to 443 | Old `pf` redirect rule from qemu2 setup intercepting port 443 | `sudo pfctl -F all` to flush all pf rules, tunnel will bind immediately |
| Ingress external IP stays `<pending>` | Ingress addon created the service as `NodePort` instead of `LoadBalancer` | `kubectl -n ingress-nginx patch svc ingress-nginx-controller -p '{"spec":{"type":"LoadBalancer"}}'` |
| iOS: `NSURLErrorDomain: -1003` or `Code=57` | Tunnel not running, or `/etc/hosts` missing | Start `sudo minikube tunnel`, verify `/etc/hosts` |
| `ImagePullBackOff` on pods | Images not loaded into Minikube | Re-run image build/load (step 2) |
| WebSocket: `Socket is not connected` | Apache proxy rule ordering wrong, or HTTP/2 stripping headers | Check `proxy.conf` ordering; use `--http1.1` for curl tests |
| `minikube image load` hangs | Large images + Docker driver | Use `minikube docker-env` (Option A) instead |
| colima not responding | VM crashed after sleep | `colima stop && colima start --cpu 4 --memory 8 --disk 60` |

---

## Appendix: qemu2 driver (legacy)

If you cannot use the Docker driver (e.g. no Docker CLI, no colima), the qemu2
driver works but requires manual port-forwarding that is fragile:

```bash
minikube start --driver=qemu2 --cpus=4 --memory=8192
minikube addons enable ingress
```

### Image loading (qemu2)

With qemu2, `minikube image load` needs tarballs and a retag step:

```bash
for img in dalogin-quarkus mbook-quarkus mbooks-quarkus simple-service-webapp-quarkus; do
  podman save -o /tmp/${img}.tar localhost/${img}:local
  minikube image load /tmp/${img}.tar
  minikube ssh -- sudo ctr -n k8s.io images tag \
    localhost/${img}:local docker.io/library/${img}:local
done
```

### Networking (qemu2)

Instead of `minikube tunnel`, you must use port-forward + pf redirect:

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443 &
echo "rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 443 -> 127.0.0.1 port 8443" \
  | sudo pfctl -ef -
```

> **⚠️ Both commands do not survive a reboot or sleep/wake.** The port-forward
> process dies silently and must be re-run. This is the main reason the Docker
> driver is recommended instead.

To tear down: `sudo pfctl -F all` and kill the port-forward background process.

### Redeploy (qemu2)

```bash
(cd dalogin-quarkus && ./mvnw package -DskipTests)
podman build -t dalogin-quarkus:local ./dalogin-quarkus
podman save -o /tmp/dalogin-quarkus.tar localhost/dalogin-quarkus:local
minikube image load /tmp/dalogin-quarkus.tar
minikube ssh -- sudo ctr -n k8s.io images tag \
  localhost/dalogin-quarkus:local docker.io/library/dalogin-quarkus:local
kubectl -n cinemas rollout restart deployment/dalogin
```
