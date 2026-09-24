package com.cinemas.k8infra.smoke.base.response.booking;

import com.cinemas.k8infra.smoke.base.response.ResponseRuleProperties;

import java.util.List;
import java.util.Properties;

public record BookingCheckoutResponseRules(
    List<String> paymentErrorContains,
    List<String> loginErrorContains,
    List<String> filterErrorContains,
    List<String> soldOutFallbackContains
) {
    /** Loads booking checkout classification markers from a classpath properties file. */
    public static BookingCheckoutResponseRules load(String resourcePath) {
        Properties properties = ResponseRuleProperties.load(resourcePath);

        return new BookingCheckoutResponseRules(
            ResponseRuleProperties.list(properties, "payment.error.contains"),
            ResponseRuleProperties.list(properties, "login.error.contains"),
            ResponseRuleProperties.list(properties, "filter.error.contains"),
            ResponseRuleProperties.list(properties, "soldout.fallback.contains"));
    }
}


