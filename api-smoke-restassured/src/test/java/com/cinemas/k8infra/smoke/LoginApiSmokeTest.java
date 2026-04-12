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

class LoginApiSmokeTest {
    private SmokeSupport support;

    @BeforeEach
    void setUp() {
        support = new SmokeSupport(SmokeTestConfig.load());
        support.assumeLiveBackend();
    }

    @Test
    void loginAdminActiveSessionsAndLocationsSmoke() {
        LoginSession session = support.login();

        Response admin = support.getAdmin(session);
        assertTrue(admin.statusCode() == 200 || admin.statusCode() == 300,
            "Admin expected 200/300 but got " + admin.statusCode() + " body=" + admin.asString());

        Response sessionsResp = support.getActiveSessions();
        assertEquals(200, sessionsResp.statusCode(), "Active sessions failed: " + sessionsResp.asString());

        List<Map<String, Object>> sessions = sessionsResp.jsonPath().getList("$");
        assertNotNull(sessions, "Active sessions must return JSON array");

        Map<String, Object> found = null;
        for (Map<String, Object> s : sessions) {
            if (support.config().user().equals(String.valueOf(s.get("user")))
                && support.config().deviceId().equals(String.valueOf(s.get("deviceId")))) {
                found = s;
                break;
            }
        }

        if (support.config().requireActiveSession()) {
            assertNotNull(found, "Expected to find active session for configured user/device");
        }

        if (found != null) {
            assertNotNull(found.get("sessionId"), "sessionId must exist");
            long creationTime = Long.parseLong(String.valueOf(found.get("creationTime")));
            assertTrue(creationTime > 0, "creationTime must be > 0");
        }

        Response locations = support.getLocations();
        assertEquals(200, locations.statusCode(), "Locations failed: " + locations.asString());
        List<Object> locationList = locations.jsonPath().getList("locations");
        assertNotNull(locationList, "Expected 'locations' key in response");
    }
}

