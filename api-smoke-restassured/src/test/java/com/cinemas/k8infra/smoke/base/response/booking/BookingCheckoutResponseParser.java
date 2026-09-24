package com.cinemas.k8infra.smoke.base.response.booking;

import com.cinemas.k8infra.smoke.base.response.EndpointResponseModel;

public final class BookingCheckoutResponseParser {
    private BookingCheckoutResponseParser() {
    }

    /**
     * Classifies checkout response outcome using both body markers and optional JSON fields.
     * This keeps endpoint behavior in properties while still enabling field-based checks.
     */
    public static BookingCheckoutOutcome parse(EndpointResponseModel model, BookingCheckoutResponseRules rules) {
        boolean paymentError = model.containsAny(rules.paymentErrorContains());
        boolean loginError = model.containsAny(rules.loginErrorContains());
        boolean filterError = model.containsAny(rules.filterErrorContains());
        boolean soldOut = model.containsAny(rules.soldOutFallbackContains()) || model.hasNonBlankString("Error");
        boolean bookingSucceeded = model.hasNonEmptyList("tickets");
        String purchaseId = model.string("purchaseId");

        return new BookingCheckoutOutcome(
            purchaseId == null ? "" : purchaseId,
            bookingSucceeded,
            soldOut,
            paymentError,
            loginError,
            filterError);
    }


    public record BookingCheckoutOutcome(
        String purchaseId,
        boolean bookingSucceeded,
        boolean soldOut,
        boolean paymentError,
        boolean loginError,
        boolean filterError
    ) {
    }
}


