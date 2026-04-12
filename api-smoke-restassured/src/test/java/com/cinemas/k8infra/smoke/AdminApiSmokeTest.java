package com.cinemas.k8infra.smoke;

import com.cinemas.k8infra.smoke.support.LoginSession;
import com.cinemas.k8infra.smoke.support.SmokeSupport;
import com.cinemas.k8infra.smoke.support.SmokeTestConfig;
import io.restassured.response.Response;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class AdminApiSmokeTest {
    private SmokeSupport support;

    @BeforeEach
    void setUp() {
        support = new SmokeSupport(SmokeTestConfig.load());
        support.assumeLiveBackend();
    }

    @Test
    void loginAdminActiveSessionsAndHelloSmoke() {
        LoginSession session = support.login();

        Response admin = support.getAdmin(session);
        assertTrue(admin.statusCode() == 200 || admin.statusCode() == 300,
            "Admin expected 200/300 but got " + admin.statusCode() + " body=" + admin.asString());

        if (admin.statusCode() == 200) {
            String user = admin.jsonPath().getString("user");
            String uuid = admin.jsonPath().getString("uuid");
            assertEquals(support.config().user(), user, "Admin user mismatch");
            assertNotNull(uuid, "Admin uuid missing");
            assertFalse(uuid.isBlank(), "Admin uuid empty");
        }

        Response sessionsResp = support.getActiveSessions();
        assertEquals(200, sessionsResp.statusCode(), "Active sessions failed: " + sessionsResp.asString());
        List<Map<String, Object>> sessions = sessionsResp.jsonPath().getList("$");
        assertNotNull(sessions, "Active sessions must return JSON array");

        for (Map<String, Object> s : sessions) {
            SmokeSupport.assertSessionShape(s);
        }

        Response hello = support.getHello();
        assertEquals(200, hello.statusCode(), "Hello failed: " + hello.asString());
        assertEquals("hello", hello.jsonPath().getString("greeting"), "Hello greeting mismatch");
    }
}

