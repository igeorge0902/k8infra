package com.cinemas.k8infra.smoke.support;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public final class HmacSigner {

    private HmacSigner() {
    }

    public static String hmacSha512Base64(String message, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] digest = mac.doFinal(message.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(digest);
        } catch (Exception e) {
            throw new IllegalStateException("Unable to create HMAC SHA512", e);
        }
    }

    public static String buildLoginBody(String user, String passHash, String deviceId, String iosVersion) {
        return "user=" + enc(user)
            + "&pswrd=" + enc(passHash)
            + "&deviceId=" + enc(deviceId)
            + "&ios=" + enc(iosVersion);
    }

    public static String buildLoginHash(String user, String passHash, String deviceId, String microTime, int contentLength) {
        String hmacSecret = hmacSha512Base64(user, passHash);
        String message = "/login/HelloWorld:user=" + user
            + "&pswrd=" + passHash
            + "&deviceId=" + deviceId
            + ":" + microTime + ":" + contentLength;
        return hmacSha512Base64(message, hmacSecret);
    }

    private static String enc(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}

