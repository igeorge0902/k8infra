package com.cinemas.k8infra.smoke.support;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public final class SmokeTestConfig {
    private final Properties properties;

    private SmokeTestConfig(Properties properties) {
        this.properties = properties;
    }

    public static SmokeTestConfig load() {
        Properties p = new Properties();
        try (InputStream in = SmokeTestConfig.class.getClassLoader().getResourceAsStream("smoke-test.properties")) {
            if (in != null) {
                p.load(in);
            }
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load smoke-test.properties", e);
        }
        return new SmokeTestConfig(p);
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

