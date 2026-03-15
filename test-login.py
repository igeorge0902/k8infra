#!/usr/bin/env python3
"""
End-to-end login test for the cinemas backend.
Reproduces the iOS client's HMAC-SHA512 handshake, logs in via dalogin,
then calls mbook to retrieve the user profile.

Uses only stdlib — no pip packages required.
Connects over HTTPS (self-signed cert).
"""
import hashlib, hmac, base64, time, sys, json, ssl
import urllib.parse, urllib.request, urllib.error, http.cookiejar

# ── Configuration ──────────────────────────────────────────────────
BASE = "https://milo.crabdance.com"    # HTTPS via ingress
USER = "GI"                             # existing user in login_ DB
PASS_HASH = "52fa80662e64c128f8389c9ea6c73d4c02368004bf4463491900d11aaadca39d47de1b01361f207c512cfa79f0f92c3395c67ff7928e3f5ce3e3c852b392f976"
DEVICE_ID = "test-device-001"
IOS_VERSION = "17.0"

# ── Shared cookie jar ────────────────────────────────────────────
cj = http.cookiejar.CookieJar()
# Accept self-signed certificate
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cj),
    urllib.request.HTTPSHandler(context=ctx),
)

# ── HMAC helper ──────────────────────────────────────────────────
def hmac_sha512(message: str, secret: str) -> str:
    h = hmac.new(secret.encode(), message.encode(), hashlib.sha512).digest()
    return base64.b64encode(h).decode()

# ── Step 1: Login ────────────────────────────────────────────────
print("=" * 60)
print("STEP 1 — Login via POST /login/HelloWorld")
print("=" * 60)

body_params = {
    "user":     USER,
    "pswrd":    PASS_HASH,
    "deviceId": DEVICE_ID,
    "ios":      IOS_VERSION,
}
body_str = urllib.parse.urlencode(body_params)
content_length = str(len(body_str))
micro_time = str(int(time.time() * 1000))

hmac_secret = hmac_sha512(USER, PASS_HASH)
hmac_message = (
    f"/login/HelloWorld:user={USER}&pswrd={PASS_HASH}"
    f"&deviceId={DEVICE_ID}:{micro_time}:{content_length}"
)
hmac_hash = hmac_sha512(hmac_message, hmac_secret)

req = urllib.request.Request(
    f"{BASE}/login/HelloWorld",
    data=body_str.encode("ascii"),
    method="POST",
    headers={
        "Content-Type":  "application/x-www-form-urlencoded",
        "Accept":        "application/json",
        "X-HMAC-HASH":   hmac_hash,
        "X-MICRO-TIME":  micro_time,
        "Content-Length": content_length,
        "M-Device":      DEVICE_ID,
    },
)

try:
    resp = opener.open(req)
    status = resp.status
    body = resp.read().decode()
except urllib.error.HTTPError as e:
    status = e.code
    body = e.read().decode()

print(f"  Status : {status}")
print(f"  Body   : {body[:500]}")
cookies = {c.name: c.value for c in cj}
print(f"  Cookies: {cookies}")

if status != 200:
    print("\n*** LOGIN FAILED — aborting remaining steps ***")
    sys.exit(1)

login_json = json.loads(body)
print(f"  JSON   : {json.dumps(login_json, indent=2)}")

jsessionid = login_json.get("JSESSIONID", "")
x_token    = login_json.get("X-Token", "")
print(f"\n  JSESSIONID = {jsessionid}")
print(f"  X-Token    = {x_token}")

# ── Step 2: Retrieve user via /login/admin (AdminServlet → mbook) ─
print()
print("=" * 60)
print("STEP 2 — GET /login/admin (retrieve user via AdminServlet)")
print("=" * 60)

req2 = urllib.request.Request(f"{BASE}/login/admin?JSESSIONID={jsessionid}")
req2.add_header("X-Token", x_token)
# Ciphertext must match token2 — forwarded by dalogin's RequestFilter to mbook
req2.add_header("Ciphertext", x_token)
try:
    resp2 = opener.open(req2)
    print(f"  Status : {resp2.status}")
    body2 = resp2.read().decode()[:500]
    print(f"  Body   : {body2}")
except urllib.error.HTTPError as e:
    print(f"  Status : {e.code}")
    body2 = e.read().decode()[:500]
    print(f"  Body   : {body2}")

# ── Step 3: Smoke-test mbooks ────────────────────────────────────
print()
print("=" * 60)
print("STEP 3 — GET /mbooks-1/rest/book/hello")
print("=" * 60)

req3 = urllib.request.Request(f"{BASE}/mbooks-1/rest/book/hello")
try:
    resp3 = opener.open(req3)
    print(f"  Status : {resp3.status}")
    print(f"  Body   : {resp3.read().decode()[:500]}")
except urllib.error.HTTPError as e:
    print(f"  Status : {e.code}")
    print(f"  Body   : {e.read().decode()[:500]}")

print()
print("✅  All API calls completed.")

