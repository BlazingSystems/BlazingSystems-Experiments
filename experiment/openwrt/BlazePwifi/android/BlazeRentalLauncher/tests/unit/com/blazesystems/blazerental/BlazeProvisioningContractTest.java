package com.blazesystems.blazerental;

import org.junit.Test;
import static org.junit.Assert.*;

public class BlazeProvisioningContractTest {
    private static final String TOKEN =
            "0123456789ab.0123456789abcdef0123456789abcdef";
    private static final String PIN =
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";

    @Test public void acceptsPinnedHttpsProvisioningOnly() {
        assertTrue(BlazeProvisioningContract.isValidValues(
                BlazeProvisioningContract.SCHEMA,
                "https://192.168.1.1",
                TOKEN,
                PIN));
    }

    @Test public void rejectsPlainHttpProvisioning() {
        assertFalse(BlazeProvisioningContract.isValidValues(
                BlazeProvisioningContract.SCHEMA,
                "http://192.168.1.1",
                TOKEN,
                PIN));
    }

    @Test public void rejectsWrongSchema() {
        assertFalse(BlazeProvisioningContract.isValidValues(
                "blazerental.enrollment.v1",
                "https://192.168.1.1",
                TOKEN,
                PIN));
    }

    @Test public void rejectsMalformedOrShortToken() {
        assertFalse(BlazeProvisioningContract.isValidValues(
                BlazeProvisioningContract.SCHEMA,
                "https://192.168.1.1",
                "bad.token",
                PIN));
        assertFalse(BlazeProvisioningContract.isValidValues(
                BlazeProvisioningContract.SCHEMA,
                "https://192.168.1.1",
                "0123456789ab.nope!",
                PIN));
    }

    @Test public void rejectsMissingOrMalformedCertificatePin() {
        assertFalse(BlazeProvisioningContract.isValidValues(
                BlazeProvisioningContract.SCHEMA,
                "https://192.168.1.1",
                TOKEN,
                ""));
        assertFalse(BlazeProvisioningContract.isValidValues(
                BlazeProvisioningContract.SCHEMA,
                "https://192.168.1.1",
                TOKEN,
                "abcd"));
    }

    @Test public void acceptsColonSeparatedCertificatePinAfterNormalization() {
        String colonPin =
                "01:23:45:67:89:ab:cd:ef:01:23:45:67:89:ab:cd:ef:" +
                "01:23:45:67:89:ab:cd:ef:01:23:45:67:89:ab:cd:ef";
        assertTrue(BlazeProvisioningContract.isValidValues(
                BlazeProvisioningContract.SCHEMA,
                "https://router.local",
                TOKEN,
                colonPin));
    }
}
