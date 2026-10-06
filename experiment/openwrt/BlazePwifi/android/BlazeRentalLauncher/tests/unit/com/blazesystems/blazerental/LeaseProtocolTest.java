package com.blazesystems.blazerental;

import org.junit.Test;
import static org.junit.Assert.*;

public class LeaseProtocolTest {
    @Test public void legacyStatusAuthenticationCanonicalizationRemainsCompatible() throws Exception {
        assertEquals(
                "d3da368b0cd5d70736d1070bf9c1e3e3bc630f576f357c87780bd336bef89aae",
                Hmac.sha256Hex("secret", "status|nonce123|secret"));
    }

    @Test public void v2StatusAuthenticationBindsDeviceIdentity() throws Exception {
        assertEquals(
                "3562c81cde221ac2a6cf0111eabf87ab9c88f407c44e0b84f668254bf672b965",
                Hmac.sha256Hex("secret",
                        "v2|status|nonce123|0123456789abcdef01234567"));
    }

    @Test public void v2CoinStartAuthenticationBindsRequestedController() throws Exception {
        assertEquals(
                "80e84e89394cbe09d13ad691f9a106d620c609acdefd9f5a7550a717f2e100eb",
                Hmac.sha256Hex("secret",
                        "v2|coin_start|abc|0123456789abcdef01234567|vendo-02"));
    }

    @Test public void enrollmentAuthenticationCanonicalizationIsStable() throws Exception {
        assertEquals(
                "e6b45dafdfbcd5bd2e0ad684e7758a133e652e7c05026dce8df2293c382a0ca7",
                Hmac.sha256Hex("enroll.secret", "enroll|abc|enroll.secret"));
    }

    @Test public void noncesAreUniqueAndHexEncoded() {
        String first = Hmac.nonce();
        String second = Hmac.nonce();
        assertEquals(32, first.length());
        assertTrue(first.matches("[0-9a-f]{32}"));
        assertNotEquals(first, second);
    }
}
