# API Smoke Tests (RestAssured)

This module replaces Python smoke scripts in `k8infra` with Java + RestAssured.

## What is covered

- Login handshake (`POST /login/HelloWorld`) with HMAC headers.
- Admin/user retrieval (`GET /login/admin`).
- Active sessions (`GET /login/activeSessions`).
- mbooks smoke endpoints:
  - `GET /mbooks-1/rest/book/locations`
  - `GET /mbooks-1/rest/book/hello`
- Manual race smoke template:
  - `POST /mbooks-1/rest/book/payment/fullcheckout2` (`BookingConcurrentApiTest`, disabled by default)

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
- `BookingConcurrentApiTest` is intentionally disabled and meant for manual runs with isolated seat data.
- Python scripts are retained temporarily for fallback, but RestAssured is the default framework moving forward.

Run the race smoke test explicitly with overrides:

```bash
cd /Users/gyorgy.gaspar/work/cinemas/cinemas/k8infra/api-smoke-restassured
mvn -s /Users/gyorgy.gaspar/work/cinemas/cinemas/k8infra/settings-local.xml \
  -Dtest=BookingRaceApiSmokeTest \
  -DbookingUserA=GG \
  -DbookingPassHashA=<GG_PASS_HASH> \
  -DbookingUserB=GI \
  -DbookingPassHashB=<GI_PASS_HASH> \
  -DbookingScreeningDateId=1 \
  -DbookingPaymentNonce=fake-valid-nonce \
  -DbookingRaceSeats=A1-A2 \
  test
```

`BookingConcurrentApiTest` fetches Braintree `clientToken` from `/mbooks-1/rest/book/payment/clientToken` as a live readiness check.
The backend checkout API still expects `payment_method_nonce` input; for automation use a known sandbox nonce (for example `fake-valid-nonce`) or pass one via `-DbookingPaymentNonce=...`.

