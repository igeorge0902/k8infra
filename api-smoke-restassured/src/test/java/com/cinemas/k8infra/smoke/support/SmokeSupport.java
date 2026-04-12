package com.cinemas.k8infra.smoke.support;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.filter.cookie.CookieFilter;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import org.junit.jupiter.api.Assumptions;

import java.nio.charset.StandardCharsets;
import java.util.Map;

import static io.restassured.RestAssured.given;

public final class SmokeSupport {
    private final SmokeTestConfig config;
    private final CookieFilter cookieFilter;
    private final RequestSpecification baseSpec;

    public SmokeSupport(SmokeTestConfig config) {
        this.config = config;
        this.cookieFilter = new CookieFilter();
        RestAssured.useRelaxedHTTPSValidation();
        this.baseSpec = new RequestSpecBuilder()
            .setBaseUri(config.baseUrl())
            .setRelaxedHTTPSValidation()
            .setUrlEncodingEnabled(false)
            .addFilter(cookieFilter)
            .build();
    }

    public void assumeLiveBackend() {
        Assumptions.assumeTrue(config.smokeLive(), "Smoke live tests disabled by config (smokeLive=false)");
        try {
            Response health = given().spec(baseSpec)
                .when()
                .get("/login/");
            Assumptions.assumeTrue(health.statusCode() < 500, "Backend is not reachable for smoke tests");
        } catch (Exception e) {
            Assumptions.assumeTrue(false, "Skipping smoke tests: backend not reachable: " + e.getMessage());
        }
    }

    public LoginSession login() {
        String body = HmacSigner.buildLoginBody(config.user(), config.passHash(), config.deviceId(), config.iosVersion());
        String microTime = String.valueOf(System.currentTimeMillis());
        int contentLength = body.getBytes(StandardCharsets.UTF_8).length;
        String xHmacHash = HmacSigner.buildLoginHash(config.user(), config.passHash(), config.deviceId(), microTime, contentLength);

        Response response = given().spec(baseSpec)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .header("Accept", "application/json")
            .header("X-HMAC-HASH", xHmacHash)
            .header("X-MICRO-TIME", microTime)
            .header("Content-Length", String.valueOf(contentLength))
            .header("M-Device", config.deviceId())
            .body(body)
            .when()
            .post("/login/HelloWorld");

        if (response.statusCode() != 200) {
            throw new AssertionError("Login failed: status=" + response.statusCode() + " body=" + response.asString());
        }

        String jsessionId = response.jsonPath().getString("JSESSIONID");
        String xToken = response.jsonPath().getString("X-Token");

        if (jsessionId == null || jsessionId.isBlank()) {
            throw new AssertionError("Missing JSESSIONID in login response: " + response.asString());
        }
        if (xToken == null || xToken.isBlank()) {
            throw new AssertionError("Missing X-Token in login response: " + response.asString());
        }

        return new LoginSession(jsessionId, xToken);
    }

    public Response getAdmin(LoginSession session) {
        return given().spec(baseSpec)
            .queryParam("JSESSIONID", session.jsessionId())
            .header("X-Token", session.xToken())
            .header("Ciphertext", session.xToken())
            .when()
            .get("/login/admin");
    }

    public Response getActiveSessions() {
        return given().spec(baseSpec)
            .when()
            .get("/login/activeSessions");
    }

    public Response getLocations() {
        return given().spec(baseSpec)
            .when()
            .get("/mbooks-1/rest/book/locations");
    }

    public Response getHello() {
        return given().spec(baseSpec)
            .when()
            .get("/mbooks-1/rest/book/hello");
    }

    public SmokeTestConfig config() {
        return config;
    }

    @SuppressWarnings("unchecked")
    public static void assertSessionShape(Map<String, Object> session) {
        for (String field : new String[]{"id", "sessionId", "user", "deviceId", "creationTime"}) {
            if (!session.containsKey(field)) {
                throw new AssertionError("Session entry missing field '" + field + "': " + session);
            }
        }
    }
}

