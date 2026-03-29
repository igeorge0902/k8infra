#!/usr/bin/env python3
"""
End-to-end test: login via dalogin → call /admin → retrieve user from mbook.
Tests the full internal flow: dalogin AdminServlet → ServiceClient → mbook REST.
Connects over HTTPS (self-signed cert).
"""
import hashlib, hmac, base64, time, sys, json, ssl
import urllib.parse, urllib.request, urllib.error, http.cookiejar

# ── Configuration ──────────────────────────────────────────────────
BASE = "https://milo.crabdance.com"
USER = "GI"
PASS_HASH = "52fa80662e64c128f8389c9ea6c73d4c02368004bf4463491900d11aaadca39d47de1b01361f207c512cfa79f0f92c3395c67ff7928e3f5ce3e3c852b392f976"
DEVICE_ID = "test-device-001"
IOS_VERSION = "17.0"

cj = http.cookiejar.CookieJar()
# Accept self-signed certificate
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cj),
    urllib.request.HTTPSHandler(context=ctx),
)

def hmac_sha512(message, secret):
    h = hmac.new(secret.encode(), message.encode(), hashlib.sha512).digest()
    return base64.b64encode(h).decode()

# ── Step 1: Login ────────────────────────────────────────────────
print("=" * 60)
print("STEP 1 — Login via POST /login/HelloWorld")
print("=" * 60)

body_params = {
    "user": USER,
    "pswrd": PASS_HASH,
    "deviceId": DEVICE_ID,
    "ios": IOS_VERSION,
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
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json",
        "X-HMAC-HASH": hmac_hash,
        "X-MICRO-TIME": micro_time,
        "Content-Length": content_length,
        "M-Device": DEVICE_ID,
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
login_json = json.loads(body)
print(f"  JSON   : {json.dumps(login_json, indent=2)}")
cookies = {c.name: c.value for c in cj}
print(f"  Cookies: {cookies}")

if status != 200:
    print("\n*** LOGIN FAILED — aborting ***")
    sys.exit(1)

jsessionid = login_json.get("JSESSIONID", "")
x_token = login_json.get("X-Token", "")
xsrf = cookies.get("XSRF-TOKEN", "")

print(f"\n  JSESSIONID = {jsessionid}")
print(f"  X-Token    = {x_token}")
print(f"  XSRF-TOKEN = {xsrf}")

# ── Step 2: GET /login/admin (through AuthFilter → AdminServlet → mbook) ──
print()
print("=" * 60)
print("STEP 2 — GET /login/admin (retrieve user via AdminServlet)")
print("=" * 60)

admin_url = f"{BASE}/login/admin?JSESSIONID={jsessionid}"
req2 = urllib.request.Request(admin_url)
req2.add_header("X-Token", x_token)
# Ciphertext must match the token2 header that dalogin forwards to mbook.
# dalogin's RequestFilter copies Ciphertext from our request; mbook's
# CiphertextFilter checks Ciphertext == token2.  The X-Token IS token2.
req2.add_header("Ciphertext", x_token)
# The cookie jar already has JSESSIONID and XSRF-TOKEN from Step 1

try:
    resp2 = opener.open(req2)
    status2 = resp2.status
    body2 = resp2.read().decode()
except urllib.error.HTTPError as e:
    status2 = e.code
    body2 = e.read().decode()

print(f"  Status : {status2}")
print(f"  Body   : {body2[:800]}")

if status2 == 200:
    try:
        user_json = json.loads(body2)
        print(f"  Parsed : {json.dumps(user_json, indent=2)}")
        # Verify user data fields
        assert "user" in user_json, "Response must contain 'user'"
        assert "uuid" in user_json, "Response must contain 'uuid'"
        assert user_json["user"] == USER, f"Expected user={USER}, got {user_json['user']}"
        print(f"\n  ✅ User retrieved: user={user_json['user']}, uuid={user_json['uuid']}")
    except (json.JSONDecodeError, AssertionError) as e:
        print(f"\n  ⚠️  Response parsing/validation: {e}")
elif status2 == 300:
    print(f"\n  ⚠️  Activation required (status 300) — user not yet activated")
else:
    print(f"\n  ❌ Admin call failed with status {status2}")

# ── Step 3: Active sessions ───────────────────────────────────────
print()
print("=" * 60)
print("STEP 3 — GET /login/activeSessions (active user sessions)")
print("=" * 60)

req_sessions = urllib.request.Request(f"{BASE}/login/activeSessions")
try:
    resp_sessions = opener.open(req_sessions)
    status_sessions = resp_sessions.status
    body_sessions = resp_sessions.read().decode()
except urllib.error.HTTPError as e:
    status_sessions = e.code
    body_sessions = e.read().decode()

print(f"  Status : {status_sessions}")
print(f"  Body   : {body_sessions[:800]}")

if status_sessions == 200:
    try:
        sessions = json.loads(body_sessions)
        assert isinstance(sessions, list), "Response must be a JSON array"
        print(f"  Count  : {len(sessions)} active session(s)")

        # Each session entry must have the expected fields
        for s in sessions:
            for field in ("id", "sessionId", "user", "deviceId", "creationTime"):
                assert field in s, f"Session entry missing field '{field}': {s}"

        # Find our session in the list
        our_session = None
        for s in sessions:
            if s.get("user") == USER and s.get("deviceId") == DEVICE_ID:
                our_session = s
                break

        if our_session:
            print(f"  ✅ Found our session: user={our_session['user']}, "
                  f"deviceId={our_session['deviceId']}, "
                  f"sessionId={our_session.get('sessionId', '?')}, "
                  f"creationTime={our_session.get('creationTime', 0)}")
            assert our_session["sessionId"], "sessionId must not be empty"
            assert our_session["creationTime"] > 0, "creationTime must be > 0"
        else:
            print(f"  ⚠️  Our session (user={USER}, deviceId={DEVICE_ID}) not found")
            print(f"  All sessions: {json.dumps(sessions, indent=2)}")

    except (json.JSONDecodeError, AssertionError) as e:
        print(f"  ❌ Validation failed: {e}")
else:
    print(f"  ❌ Active sessions call failed with status {status_sessions}")

# ── Step 4: Smoke-test mbooks ────────────────────────────────────
print()
print("=" * 60)
print("STEP 4 — GET /mbooks-1/rest/book/hello (smoke test)")
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
print("=" * 60)
print("All steps completed.")
print("=" * 60)

