package com.cinemas.k8infra.smoke.base.response;

import io.restassured.response.Response;

import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;

public final class EndpointResponseValidator {
    private EndpointResponseValidator() {
    }

    /**
     * Validates body markers and optional JSON schema using endpoint-specific rules,
     * then returns a response model for downstream parsing/assertions.
     */
    public static EndpointResponseModel assertBodyMatchesRules(Response response, String body, String endpointName, EndpointBodyResponseRules rules) {
        for (String forbidden : rules.forbiddenContains()) {
            if (body.contains(forbidden)) {
                throw new AssertionError(endpointName + " returned forbidden payload fragment '" + forbidden + "': " + body);
            }
        }

        boolean looksExpected = rules.expectedAnyContains().isEmpty()
            || rules.expectedAnyContains().stream().anyMatch(body::contains);
        if (!looksExpected) {
            throw new AssertionError(endpointName + " response did not match any expected payload markers "
                + rules.expectedAnyContains() + ": " + body);
        }

        if (rules.shouldValidateSchema(body)) {
            response.then().body(matchesJsonSchemaInClasspath(rules.schemaClasspath()));
        }

        return EndpointResponseModel.fromBody(body);
    }
}



