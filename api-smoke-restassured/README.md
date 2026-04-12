# API Smoke Tests (RestAssured)

This module replaces Python smoke scripts in `k8infra` with Java + RestAssured.

## What is covered

- Login handshake (`POST /login/HelloWorld`) with HMAC headers.
- Admin/user retrieval (`GET /login/admin`).
- Active sessions (`GET /login/activeSessions`).
- mbooks smoke endpoints:
  - `GET /mbooks-1/rest/book/locations`
  - `GET /mbooks-1/rest/book/hello`

## Run

```bash
cd /Users/gyorgy.gaspar/work/cinemas/cinemas/k8infra/api-smoke-restassured
mvn test
```

Run with explicit overrides:

```bash
cd /Users/gyorgy.gaspar/work/cinemas/cinemas/k8infra/api-smoke-restassured
mvn test \
  -DbaseUrl=https://milo.crabdance.com \
  -Duser=GI \
  -DpassHash=... \
  -DdeviceId=test-device-001 \
  -DsmokeLive=true
```

## Notes

- Tests use relaxed TLS to support local self-signed certs.
- If backend is unavailable, tests are skipped with a clear message.
- Python scripts are retained temporarily for fallback, but RestAssured is the default framework moving forward.

