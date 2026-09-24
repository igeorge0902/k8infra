package com.cinemas.k8infra.smoke.base.session;

public record LoginSession(String jsessionId, String xToken, String timeToken, String xsrfToken) {
}


