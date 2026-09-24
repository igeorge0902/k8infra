package com.cinemas.k8infra.smoke.base.response;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

/** Shared helpers for loading and reading endpoint response rule properties files. */
public final class ResponseRuleProperties {
    private ResponseRuleProperties() {
    }

    /** Loads a required classpath properties resource. */
    public static Properties load(String resourcePath) {
        Properties properties = new Properties();
        try (InputStream in = ResponseRuleProperties.class.getClassLoader().getResourceAsStream(resourcePath)) {
            if (in == null) {
                throw new IllegalStateException("Missing response rules file: " + resourcePath);
            }
            properties.load(in);
            return properties;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load response rules file: " + resourcePath, e);
        }
    }

    /** Reads a pipe-separated marker list from properties and returns trimmed non-empty values. */
    public static List<String> list(Properties properties, String key) {
        String value = properties.getProperty(key);
        if (value == null || value.isBlank()) {
            return List.of();
        }
        return Arrays.stream(value.split("\\|"))
            .map(String::trim)
            .filter(token -> !token.isEmpty())
            .toList();
    }

    /** Reads a string from properties and returns a trimmed value or empty string. */
    public static String string(Properties properties, String key) {
        return properties.getProperty(key, "").trim();
    }
}

