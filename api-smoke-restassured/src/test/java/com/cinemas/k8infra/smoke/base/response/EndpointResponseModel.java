package com.cinemas.k8infra.smoke.base.response;

import io.restassured.path.json.JsonPath;
import io.restassured.path.json.exception.JsonPathException;

import java.util.List;

public final class EndpointResponseModel {
    private final String body;
    private final JsonPath json;

    private EndpointResponseModel(String body, JsonPath json) {
        this.body = body;
        this.json = json;
    }

    /** Creates a response model from raw body text and enables JSON access when payload is valid JSON. */
    public static EndpointResponseModel fromBody(String body) {
        try {
            JsonPath jsonPath = new JsonPath(body);
            jsonPath.get("$");
            return new EndpointResponseModel(body, jsonPath);
        } catch (JsonPathException ignored) {
            return new EndpointResponseModel(body, null);
        }
    }

    /** Returns the original response body exactly as received. */
    public String body() {
        return body;
    }

    /** Returns true when at least one marker is present in the raw response body. */
    public boolean containsAny(List<String> markers) {
        return markers.stream().anyMatch(body::contains);
    }

    /** Reads a JSON string value by JsonPath or returns null when payload/path is not readable. */
    public String string(String path) {
        if (json == null) {
            return null;
        }
        try {
            return json.getString(path);
        } catch (JsonPathException ignored) {
            return null;
        }
    }

    /** Reads a JSON list value by JsonPath or returns null when payload/path is not readable. */
    public List<?> list(String path) {
        if (json == null) {
            return null;
        }
        try {
            return json.getList(path);
        } catch (JsonPathException ignored) {
            return null;
        }
    }

    /** Returns true when the JsonPath points to a non-empty list. */
    public boolean hasNonEmptyList(String path) {
        List<?> value = list(path);
        return value != null && !value.isEmpty();
    }

    /** Returns true when the JsonPath points to a non-blank string. */
    public boolean hasNonBlankString(String path) {
        String value = string(path);
        return value != null && !value.isBlank();
    }
}


