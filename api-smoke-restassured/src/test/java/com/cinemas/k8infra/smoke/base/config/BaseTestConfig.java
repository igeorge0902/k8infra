package com.cinemas.k8infra.smoke.base.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public final class BaseTestConfig {
    private final Properties properties;

    private BaseTestConfig(Properties properties) {
        this.properties = properties;
    }

    public static BaseTestConfig load() {
        Properties p = new Properties();
        try (InputStream in = BaseTestConfig.class.getClassLoader().getResourceAsStream("smoke-test.properties")) {
            if (in != null) {
                p.load(in);
            }
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load smoke-test.properties", e);
        }
        return new BaseTestConfig(p);
    }

    public String baseUrl() {
        return get("baseUrl", "BASE_URL");
    }

    public String user() {
        return get("user", "SMOKE_USER");
    }

    public String passHash() {
        return get("passHash", "SMOKE_PASS_HASH");
    }

    public String bookingUserA() {
        return get("bookingUserA", "BOOKING_USER_A");
    }

    public String bookingPassHashA() {
        return get("bookingPassHashA", "BOOKING_PASS_HASH_A");
    }

    public String bookingUserB() {
        return get("bookingUserB", "BOOKING_USER_B");
    }

    public String bookingPassHashB() {
        return get("bookingPassHashB", "BOOKING_PASS_HASH_B");
    }

    public String bookingUuidA() {
        return get("bookingUuidA", "BOOKING_UUID_A");
    }

    public String bookingUuidB() {
        return get("bookingUuidB", "BOOKING_UUID_B");
    }

    public String bookingDeviceIdA() {
        return get("bookingDeviceIdA", "BOOKING_DEVICE_ID_A");
    }

    public String bookingDeviceIdB() {
        return get("bookingDeviceIdB", "BOOKING_DEVICE_ID_B");
    }

    public int bookingScreeningDateId() {
        return Integer.parseInt(get("bookingScreeningDateId", "BOOKING_SCREENING_DATE_ID"));
    }

    public String bookingRaceSeats() {
        return get("bookingRaceSeats", "BOOKING_RACE_SEATS");
    }

    public String bookingPaymentNonce() {
        return get("bookingPaymentNonce", "BOOKING_PAYMENT_NONCE");
    }

    public String loginDbUrl() {
        return get("loginDbUrl", "LOGIN_DB_URL");
    }

    public String loginDbUser() {
        return get("loginDbUser", "LOGIN_DB_USER");
    }

    public String loginDbPassword() {
        return get("loginDbPassword", "LOGIN_DB_PASSWORD");
    }

    public String deviceId() {
        return get("deviceId", "SMOKE_DEVICE_ID");
    }

    public String iosVersion() {
        return get("iosVersion", "SMOKE_IOS_VERSION");
    }

    public int connectTimeoutMs() {
        return Integer.parseInt(get("connectTimeoutMs", "SMOKE_CONNECT_TIMEOUT_MS"));
    }

    public int socketTimeoutMs() {
        return Integer.parseInt(get("socketTimeoutMs", "SMOKE_SOCKET_TIMEOUT_MS"));
    }

    public boolean requireActiveSession() {
        return Boolean.parseBoolean(get("requireActiveSession", "SMOKE_REQUIRE_ACTIVE_SESSION"));
    }

    public boolean smokeLive() {
        return Boolean.parseBoolean(get("smokeLive", "SMOKE_LIVE"));
    }

    private String get(String key, String envKey) {
        String sys = System.getProperty(key);
        if (sys != null && !sys.isBlank()) {
            return sys;
        }
        String env = System.getenv(envKey);
        if (env != null && !env.isBlank()) {
            return env;
        }
        String val = properties.getProperty(key);
        if (val == null || val.isBlank()) {
            throw new IllegalStateException("Missing smoke config key: " + key);
        }
        return val;
    }
}


