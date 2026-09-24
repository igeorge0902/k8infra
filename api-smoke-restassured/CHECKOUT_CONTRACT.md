# Checkout Contract (`fullcheckout2` direct)

This note documents what `BookingRaceApiSmokeTest.bookOnce(...)` sends and validates when calling `fullcheckout2` directly.

## 1) Smoke test call path in this repo

- Smoke test calls directly: `POST /mbooks-1/rest/book/payment/fullcheckout2`.
- The test sends all required form fields and auth headers itself.

## 2) `fullcheckout2` required request contract

Endpoint: `POST /mbooks-1/rest/book/payment/fullcheckout2`

Consumes: `application/x-www-form-urlencoded`

Required values read by backend:

- Header: `uuid`
- Form field: `orderId`
- Form field: `payment_method_nonce`
- Form field: `seatsToBeReserved` (JSON string)

Backend returns `400` when any required value is missing/empty.

## 3) Important domain meaning

- `orderId` is client/request-provided and persisted as `Purchase.orderId`.
- `purchaseId` is DB-internal/generated.
- `uuid` is user identity and is tied to the logged-in user/session.

So in `bookOnce(...)`, treat `orderId` only as request correlation + business order reference, not as internal DB id.

## 4) Payload shape for `seatsToBeReserved`

Form field value must be a JSON object with an array key `seatsToBeReserved`:

```json
{"seatsToBeReserved":[{"screeningDateId":12345,"seat":"A1-A2"}]}
```

- `screeningDateId`: integer
- `seat`: dash-separated seats (backend splits by `-`)

## 5) Response contract checks (what smoke test should assert)

After receiving body from `/login/CheckOut`:

1. Fail if dalogin returns wrapper shape:
   - contains `"mapType":"java.util.HashMap"`
2. Require fullcheckout2-style payload indicators:
   - success path: `"tickets"`
   - business error path: `"Error"`
   - payment error path: `"Error with Transaction"`
3. If none of those keys are present, fail test as unexpected contract.

## 6) iOS implementation alignment

iOS checkout code builds exactly these form fields:

- `payment_method_nonce`
- `orderId`
- `seatsToBeReserved`

And posts to `/login/CheckOut` with form-urlencoded body.

## 7) Direct call to `fullcheckout2` (without `/login/CheckOut`)

Possible for diagnostics, but only if required auth headers are supplied exactly as mbooks expects.

Minimum needed in practice:

- `uuid`
- `token2`
- `Ciphertext` (must equal `token2` for payment/purchases paths)
- `Content-Type: application/x-www-form-urlencoded`
- Form fields: `orderId`, `payment_method_nonce`, `seatsToBeReserved`

Notes:

- `payment_method_nonce` can be a test nonce only if the target payment setup accepts it (environment dependent).
- Calling via `/login/CheckOut` is safer for smoke tests because dalogin injects auth headers from session context.

## 8) Current race smoke setup

- `bookOnce(...)` calls `fullcheckout2` directly.
- Use a unique request `orderId` per attempt (for traceability).
- Keep strict payload contract assertions (`tickets` / `Error` / `Error with Transaction`).

