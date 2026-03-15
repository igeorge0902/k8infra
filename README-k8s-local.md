# Local Kubernetes Runbook (Quarkus stack)

This runbook brings up all backend services (`dalogin-quarkus`, `mbook-quarkus`, `mbooks-quarkus`, `simple-service-webapp-quarkus`) plus MySQL, Kafka, Zookeeper, and an Apache reverse proxy for local development.

## 1) Recommended local cluster

Use **Minikube** (easiest ingress workflow for this repo).

```bash
minikube start --driver=qemu2 --cpus=4 --memory=8192
```

Enable the NGINX ingress controller:

```bash
minikube addons enable ingress
```

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

Build images with Podman:

```bash
podman build -t dalogin-quarkus:local              ./dalogin-quarkus
podman build -t mbook-quarkus:local                ./mbook-quarkus
podman build -t mbooks-quarkus:local               ./mbooks-quarkus
podman build -t simple-service-webapp-quarkus:local ./simple-service-webapp-quarkus
```

### Load images into Minikube (qemu2 / containerd)

With the qemu2 driver, `minikube image load <name>` does not see Podman images directly.
Save each image as a tarball, load the tarball, then retag so Kubernetes finds it:

```bash
for img in dalogin-quarkus mbook-quarkus mbooks-quarkus simple-service-webapp-quarkus; do
  podman save -o /tmp/${img}.tar localhost/${img}:local
  minikube image load /tmp/${img}.tar
  minikube ssh -- sudo ctr -n k8s.io images tag \
    localhost/${img}:local docker.io/library/${img}:local
done
```

> **Why the retag?** `minikube image load` stores the image under the `localhost/` prefix,
> but Kubernetes resolves bare image names via `docker.io/library/`.
> The `ctr images tag` command creates the alias Kubernetes expects.

## 3) Deploy backend manifests

```bash
kubectl apply -f k8infra/quarkus-backend.yaml
kubectl -n cinemas get pods          # wait until all pods are Running
```

## 4) Seed databases

The manifest creates empty `login_` and `book` databases via an init ConfigMap.
Import schema, data, stored procedures, and triggers from the repo SQL dumps:

```bash
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < mysql_8/login.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < mysql_8/book.sql
```

> `login.sql` already uses `CREATE DATABASE IF NOT EXISTS login_` and `USE login_`.
> No `sed` or database name rewriting is needed.

Apply the stored-procedure and trigger fixes (rewrites `login.` → `login_.` references
and corrects table-name casing for MySQL 8 on Linux):

```bash
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < k8infra/fix-sprocs.sql
kubectl -n cinemas exec -i deploy/mysql -- mysql -uroot -prootpw < k8infra/fix-triggers.sql
```

> **Important:** Do **not** create a database named `login` (without underscore).
> Only `login_` should exist. If a stale `login` database is present, drop it:
> `kubectl -n cinemas exec deploy/mysql -- mysql -uroot -prootpw -e "DROP DATABASE IF EXISTS login;"`

Verify:

```bash
kubectl -n cinemas exec deploy/mysql -- mysql -uroot -prootpw \
  -e "SELECT COUNT(*) AS users FROM login_.logins; SELECT COUNT(*) AS movies FROM book.movie;"
# → users 5, movies 103
```

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

### Expose locally

Point `milo.crabdance.com` to localhost (iOS simulator uses host DNS):

```bash
echo "127.0.0.1 milo.crabdance.com" | sudo tee -a /etc/hosts
```

Port-forward the ingress HTTPS port and redirect port 443 so the iOS app
and test scripts can reach `https://milo.crabdance.com` on the default port:

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443 &
```

Add a macOS `pf` redirect so port 443 reaches the port-forward:

```bash
echo "rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 443 -> 127.0.0.1 port 8443" \
  | sudo pfctl -ef -
```

### Verify

```bash
curl -sk https://milo.crabdance.com/login/
curl -sk https://milo.crabdance.com/mbooks-1/rest/book/movies | head -c 200
curl -sk https://milo.crabdance.com/simple-service-webapp/webapi/myresource
# → Got it
```

The iOS app (`serverURL = "https://milo.crabdance.com"`) and the `CustomURLSessionDelegate`
already trust self-signed certs for `milo.crabdance.com`.

## 6) Quick checks

```bash
kubectl -n cinemas get svc,ingress
kubectl -n cinemas get pods
curl -sk https://milo.crabdance.com/login/
curl -sk https://milo.crabdance.com/mbook-1/rest/device/test
curl -sk https://milo.crabdance.com/mbooks-1/rest/book/hello
curl -sk https://milo.crabdance.com/simple-service-webapp/webapi/myresource
# → Got it
```

## 7) Run the API tests

```bash
python3 k8infra/test-login-admin.py
python3 k8infra/test-login.py
```

## 8) Redeploy after code changes

After editing source, rebuild and reload only the changed service:

```bash
# Example: dalogin changed
(cd dalogin-quarkus && ./mvnw package -DskipTests)
podman build -t dalogin-quarkus:local ./dalogin-quarkus
podman save -o /tmp/dalogin-quarkus.tar localhost/dalogin-quarkus:local
minikube image load /tmp/dalogin-quarkus.tar
minikube ssh -- sudo ctr -n k8s.io images tag \
  localhost/dalogin-quarkus:local docker.io/library/dalogin-quarkus:local
kubectl -n cinemas rollout restart deployment/dalogin
```

## Notes specific to this codebase

- All external backend traffic goes through an in-cluster Apache reverse proxy service (`apache`) that fronts `/login`, `/mbook-1`, `/mbooks-1`, and `/simple-service-webapp`.
- `dalogin` expects one backend base URL (`WILDFLY_URL`) for both `/mbook-1` and `/mbooks-1`; it is pointed to the Apache service (`http://apache`, port 80).
- MySQL runs with `--lower-case-table-names=1` so that Hibernate entity names (lowercase) match the dump's mixed-case table names.
- Kafka topics: producers publish to `ios-movies-notifications2` (movies) and `ios-users-notifications` (users); consumers subscribe to matching topics. Both producers and consumers read `BOOTSTRAP_URL` from the environment.
- iOS `serverURL` is `https://milo.crabdance.com`; the self-signed cert is trusted via `CustomURLSessionDelegate`.
- To tear down the pf redirect: `sudo pfctl -F all -f /etc/pf.conf`
- To remove the hosts entry: `sudo sed -i '' '/milo.crabdance.com/d' /etc/hosts`
