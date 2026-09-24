package com.cinemas.k8infra.smoke.base.response;

import java.util.List;
import java.util.Properties;

public record EndpointBodyResponseRules(
    List<String> forbiddenContains,
    List<String> expectedAnyContains,
    String schemaValidateWhenContains,
    String schemaClasspath
) {
    /** Loads endpoint body validation rules from a classpath properties file. */
    public static EndpointBodyResponseRules load(String resourcePath) {
        Properties properties = ResponseRuleProperties.load(resourcePath);

        return new EndpointBodyResponseRules(
            ResponseRuleProperties.list(properties, "forbidden.contains"),
            ResponseRuleProperties.list(properties, "expected.any.contains"),
            ResponseRuleProperties.string(properties, "schema.validate.when.contains"),
            ResponseRuleProperties.string(properties, "schema.classpath"));
    }

    /** Returns true when schema validation should run for the current raw response body. */
    public boolean shouldValidateSchema(String body) {
        return !schemaValidateWhenContains.isBlank() && !schemaClasspath.isBlank() && body.contains(schemaValidateWhenContains);
    }

}

