package com.mopub.mobileads.simpleadsdemo;

import com.mopub.mobileads.MoPubActivity;
import com.mopub.mobileads.R;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Toast;

public class InterstitialsTab extends Activity {
    private final int INTERSTITIAL_AD_REQUEST = 0;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.interstitials);

        Button loadShowButton = (Button) findViewById(R.id.loadshowinterstitial);
        loadShowButton.setOnClickListener(new OnClickListener() {
            public void onClick(View v) {
                showInterstitialAd();
            }
        });
    }

    public void showInterstitialAd() {
        Intent i = new Intent(this, MoPubActivity.class);
        i.putExtra("com.mopub.mobileads.AdUnitId", SimpleAdsDemoConstants.PUB_ID_INTERSTITIAL);
        startActivityForResult(i, INTERSTITIAL_AD_REQUEST);
    }

    // Listen for results from the interstitial ad
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
        case INTERSTITIAL_AD_REQUEST:
            // Handle interstitial closed result here if needed.
            // This is called immediately before onResume()
            if (resultCode == MoPubActivity.MOPUB_ACTIVITY_NO_AD) {
                Toast.makeText(this, "No ad available", Toast.LENGTH_SHORT).show();
            }
        }
    }
}