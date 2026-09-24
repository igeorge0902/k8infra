package com.cinemas.k8infra.smoke;

import com.cinemas.k8infra.smoke.base.concurrency.TwoCallRaceRunner;
import com.cinemas.k8infra.smoke.base.config.BaseTestConfig;
import com.cinemas.k8infra.smoke.base.endpoint.BaseApiClient;
import com.cinemas.k8infra.smoke.base.response.EndpointBodyResponseRules;
import com.cinemas.k8infra.smoke.base.response.EndpointResponseModel;
import com.cinemas.k8infra.smoke.base.response.EndpointResponseValidator;
import com.cinemas.k8infra.smoke.base.response.booking.BookingCheckoutResponseParser;
import com.cinemas.k8infra.smoke.base.response.booking.BookingCheckoutResponseRules;
import com.cinemas.k8infra.smoke.base.session.LoginSession;
import io.restassured.response.Response;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.concurrent.TimeoutException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class BookingConcurrentApiTest {

    private static final String BOOKING_CHECKOUT_RULES_PATH = "response-rules/booking-checkout-response.properties";
    private static final EndpointBodyResponseRules CHECKOUT_RESPONSE_RULES =
        EndpointBodyResponseRules.load(BOOKING_CHECKOUT_RULES_PATH);
    private static final BookingCheckoutResponseRules CHECKOUT_PARSE_RULES =
        BookingCheckoutResponseRules.load(BOOKING_CHECKOUT_RULES_PATH);
    private static final int RACE_TIMEOUT_SECONDS = 45;

    private String userA;
    private String userB;
    private String userAUuid;
    private String userBUuid;
    private int screeningDateId;
    private String paymentNonce;
    private List<String> contestedSeats;

    private BaseApiClient userAClient;
    private BaseApiClient userBClient;
    private LoginSession userASession;
    private LoginSession userBSession;

    /** Loads users and sessions used by the two concurrent checkout calls. */
    @BeforeEach
    void setUp() {
        BaseTestConfig config = BaseTestConfig.load();
        userAClient = new BaseApiClient(config, true);
        userBClient = new BaseApiClient(config, true);
        userAClient.assumeLiveBackend();

        userA = config.bookingUserA();
        userB = config.bookingUserB();
        String userAPassHash = config.bookingPassHashA();
        String userBPassHash = config.bookingPassHashB();
        userAUuid = config.bookingUuidA();
        userBUuid = config.bookingUuidB();
        String userADeviceId = config.bookingDeviceIdA();
        String userBDeviceId = config.bookingDeviceIdB();
        screeningDateId = config.bookingScreeningDateId();
        paymentNonce = config.bookingPaymentNonce();
        contestedSeats = List.of(config.bookingRaceSeats().split("-"));

        // Validate both users can log in before race booking.
        userASession = userAClient.loginAs(userA, userAPassHash, userADeviceId);
        userBSession = userBClient.loginAs(userB, userBPassHash, userBDeviceId);
        assertNotNull(userASession);
        assertNotNull(userBSession);
        assertNotNull(userAUuid);
        assertNotNull(userBUuid);
    }

    /** Verifies that exactly one of the concurrent booking attempts wins the same seat race. */
    @Test
    void exactOverlap_onlyOneRequestCanReserveTheSameSeatSubset() throws Exception {
        RaceResult race = runTwoUserRace(contestedSeats, userA, userB);
        int successCount = (race.first().bookingSucceeded() ? 1 : 0) + (race.second().bookingSucceeded() ? 1 : 0);

        assertEquals(1, successCount,
            () -> "Expected exactly one success but got: first=" + race.first() + ", second=" + race.second());
    }

    /** Runs two booking calls with synchronized start and returns both outcomes. */
    private RaceResult runTwoUserRace(List<String> seatNumbers, String userTagA, String userTagB) throws Exception {
        try {
            TwoCallRaceRunner.Pair<BookingAttemptResult> pair = TwoCallRaceRunner.run(
                () -> bookOnce(userTagA, seatNumbers),
                () -> bookOnce(userTagB, seatNumbers),
                RACE_TIMEOUT_SECONDS);
            return new RaceResult(pair.first(), pair.second());
        } catch (TimeoutException timeout) {
            throw new AssertionError("Race call timed out after " + RACE_TIMEOUT_SECONDS + "s; at least one fullcheckout2 request hung", timeout);
        }
    }

    /** Sends a single checkout request and classifies the response using shared response rules. */
    private BookingAttemptResult bookOnce(String userName, List<String> seatNumbers) {
        String uuid = activeUuid(userName);
        // fullcheckout2 requires a caller-provided orderId; purchaseId is generated internally by DAO.
        String requestOrderId = "order-" + uuid + "-" + System.nanoTime();
        Response checkoutResponse = activeSupport(userName).postFullCheckout2(
                activeSession(userName),
                uuid,
                requestOrderId,
                paymentNonce,
                seatsPayloadJson(screeningDateId, seatNumbers));

        int status = checkoutResponse.statusCode();
        String body = checkoutResponse.asString();
        if (status != 200) {
            throw new AssertionError("fullcheckout2 expected HTTP 200 but got " + status + " body=" + body);
        }

        EndpointResponseModel responseModel = EndpointResponseValidator.assertBodyMatchesRules(checkoutResponse, body, "/login/CheckOut", CHECKOUT_RESPONSE_RULES);
        BookingCheckoutResponseParser.BookingCheckoutOutcome outcome = BookingCheckoutResponseParser.parse(responseModel, CHECKOUT_PARSE_RULES);

      return new BookingAttemptResult(
          userName,
          requestOrderId,
          outcome.purchaseId(),
          outcome.bookingSucceeded(),
          outcome.soldOut(),
          outcome.paymentError(),
          outcome.loginError(),
          outcome.filterError(),
          body);
    }

    /** Returns the user-specific API client by logical test user name. */
    private BaseApiClient activeSupport(String userName) {
        return userA.equals(userName) ? userAClient : userBClient;
    }

    /** Returns the user-specific login session by logical test user name. */
    private LoginSession activeSession(String userName) {
        return userA.equals(userName) ? userASession : userBSession;
    }

    /** Returns the configured UUID by logical test user name. */
    private String activeUuid(String userName) {
        return userA.equals(userName) ? userAUuid : userBUuid;
    }

    /** Builds the seats payload expected by /login/CheckOut form parameter. */
    private static String seatsPayloadJson(int screeningDateId, List<String> seats) {
        String csv = String.join("-", seats);
        return "{\"seatsToBeReserved\":[{\"screeningDateId\":" + screeningDateId + ",\"seat\":\"" + csv + "\"}]}";
    }

    private record BookingAttemptResult(
            String user,
            String orderId,
            String purchaseId,
            boolean bookingSucceeded,
            boolean soldOut,
            boolean paymentError,
            boolean loginError,
            boolean filterError,
            String rawBody
    ) {
    }


    private record RaceResult(BookingAttemptResult first, BookingAttemptResult second) {
    }
}

