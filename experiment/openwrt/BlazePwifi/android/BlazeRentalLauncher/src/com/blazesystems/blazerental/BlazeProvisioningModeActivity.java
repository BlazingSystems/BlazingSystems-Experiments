package com.blazesystems.blazerental;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.PersistableBundle;

public class BlazeProvisioningModeActivity extends Activity {
    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        Intent request = getIntent();
        PersistableBundle extras = BlazeProvisioningContract.extras(request);
        if (!BlazeProvisioningContract.isValid(extras)
                || !BlazeProvisioningContract.allowsFullyManaged(request)) {
            setResult(RESULT_CANCELED);
            finish();
            return;
        }
        RentalLeaseStore.acceptProvisioningExtras(this, extras);
        setResult(RESULT_OK, BlazeProvisioningContract.modeResult(extras));
        finish();
    }
}
