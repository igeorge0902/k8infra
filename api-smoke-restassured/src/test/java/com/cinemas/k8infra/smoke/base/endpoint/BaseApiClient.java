package com.cinemas.k8infra.smoke.base.endpoint;

import com.cinemas.k8infra.smoke.base.config.BaseTestConfig;
import com.cinemas.k8infra.smoke.base.security.HmacSigner;
import com.cinemas.k8infra.smoke.base.session.LoginSession;

import io.restassured.RestAssured;
import io.restassured.config.HttpClientConfig;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.filter.cookie.CookieFilter;
import io.restassured.filter.log.RequestLoggingFilter;
import io.restassured.filter.log.ResponseLoggingFilter;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import org.junit.jupiter.api.Assumptions;

import java.nio.charset.StandardCharsets;
import java.util.Map;

import static io.restassured.RestAssured.given;

public final class BaseApiClient {
    private final BaseTestConfig config;
    private final CookieFilter cookieFilter;
    private final RequestSpecification baseSpec;

    public BaseApiClient(BaseTestConfig config) {
        this(config, false);
    }

    public BaseApiClient(BaseTestConfig config, boolean enableHttpLogging) {
        this.config = config;
        this.cookieFilter = new CookieFilter();
        RestAssured.useRelaxedHTTPSValidation();
        RestAssured.config = RestAssured.config().httpClient(HttpClientConfig.httpClientConfig()
            .setParam("http.connection.timeout", config.connectTimeoutMs())
            .setParam("http.socket.timeout", config.socketTimeoutMs())
            .setParam("http.connection-manager.timeout", (long) config.connectTimeoutMs()));
        RequestSpecBuilder builder = new RequestSpecBuilder()
            .setBaseUri(config.baseUrl())
            .setRelaxedHTTPSValidation()
            .setUrlEncodingEnabled(false)
            .addFilter(cookieFilter);
        if (enableHttpLogging) {
            builder
                .addFilter(new RequestLoggingFilter())
                .addFilter(new ResponseLoggingFilter());
        }
        this.baseSpec = builder.build();
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
        return loginAs(config.user(), config.passHash());
    }

    public LoginSession loginAs(String user, String passHash) {
        return loginAs(user, passHash, config.deviceId());
    }

    public LoginSession loginAs(String user, String passHash, String deviceId) {
        String body = HmacSigner.buildLoginBody(user, passHash, deviceId, config.iosVersion());
        String microTime = String.valueOf(System.currentTimeMillis());
        int contentLength = body.getBytes(StandardCharsets.UTF_8).length;
        String xHmacHash = HmacSigner.buildLoginHash(user, passHash, deviceId, microTime, contentLength);

        Response response = given().spec(baseSpec)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .header("Accept", "application/json")
            .header("X-HMAC-HASH", xHmacHash)
            .header("X-MICRO-TIME", microTime)
            .header("M-Device", deviceId)
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

        String xsrfToken = response.getCookie("XSRF-TOKEN");
        if (xsrfToken == null || xsrfToken.isBlank()) {
            throw new AssertionError("Missing XSRF-TOKEN in login response cookies");
        }
        return new LoginSession(jsessionId, xToken, microTime, xsrfToken);
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

    public Response getAdminMoviesOnVenues() {
        return given().spec(baseSpec)
            .when()
            .get("/mbooks-1/rest/book/admin/moviesonvenues");
    }

    public Response getSeatsForScreening(int screeningDateId) {
        return given().spec(baseSpec)
            .when()
            .get("/mbooks-1/rest/book/seats/{screeningDateId}", screeningDateId);
    }

    public Response getBraintreeClientToken(LoginSession session) {
        return given().spec(baseSpec)
            .when()
            .get("/login/CheckOut");
    }

    public Response postFullCheckout2(LoginSession session, String uuid, String orderId, String paymentNonce, String seatsPayloadJson) {
        String endpoint = config.baseUrl() + "/login/CheckOut";
        System.out.println("DIRECT_CHECKOUT_CALL endpoint=" + endpoint + " uuid=" + uuid + " orderId=" + orderId);
        return given().spec(baseSpec)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .header("Accept", "application/json")
            .header("X-Token", session.xToken())
          //  .header("uuid", uuid)
          //  .header("TIME", session.timeToken())
          //  .header("token2", session.xToken())
            .header("Ciphertext", session.xToken())
            .cookie("XSRF-TOKEN", session.xsrfToken())
            .cookie("JSESSIONID", session.jsessionId())
            .formParam("orderId", orderId)
            .formParam("payment_method_nonce", paymentNonce)
            .formParam("seatsToBeReserved", seatsPayloadJson)
            .when()
            .post("/login/CheckOut");
    }

    public Response deletePurchase(LoginSession session, String purchaseId) {
        return given().spec(baseSpec)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .header("Accept", "application/json")
            .header("X-Token", session.xToken())
            .header("Ciphertext", session.xToken())
            .cookie("XSRF-TOKEN", session.xsrfToken())
            .cookie("JSESSIONID", session.jsessionId())
            .formParam("purchaseId", purchaseId)
            .when()
            .post("/login/ManagePurchases");
    }

    public BaseTestConfig config() {
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



