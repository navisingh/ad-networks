/*
 * Copyright (c) 2010, MoPub Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * * Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 * * Neither the name of 'MoPub Inc.' nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.mopub.mobileads;

import java.lang.ref.WeakReference;

import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import com.google.ads.GoogleAdView;
import com.google.ads.AdViewListener;
import com.google.ads.AdSenseSpec;
import com.google.ads.AdSenseSpec.AdFormat;
import com.google.ads.AdSenseSpec.AdType;

import com.mopub.mobileads.MoPubView;

public class AdSenseAdapter implements AdViewListener {
	private GoogleAdView 					mAdView;
	private final WeakReference<MoPubView> 	mMoPubViewReference;
	private String 							mParams;

	public AdSenseAdapter(MoPubView view, String params) {
		this.mMoPubViewReference = new WeakReference<MoPubView>(view);
		mParams = params;
	}

	public void loadAd() {
		MoPubView view = mMoPubViewReference.get();
		if(view == null) {
			return;
		}

		mAdView = new GoogleAdView(view.getContext());

		// The following parameters are required.  Fail if they aren't set
		JSONObject object; 
		String pubId; 
		String companyName; 
		String appName;
		try { 
			object = (JSONObject) new JSONTokener(mParams).nextValue(); 
			pubId = object.getString("Gclientid"); 
			companyName = object.getString("Gcompanyname"); 
			appName = object.getString("Gappname"); 
		} catch (JSONException e) { 
			view.adFailed(); 
			return; 
		}

		// The rest of the parameters are optional
		AdSenseSpec.AdType adtype = AdType.TEXT_IMAGE;
		Boolean testState = false;
		String keywords = "";
		String channelId = "";
		try {
			String at = object.getString("Gadtype");
			if (at.equals("GADAdSenseTextAdType")) {
				adtype = AdType.TEXT;
			}
			else if (at.equals("GADAdSenseImageAdType")) {
				adtype = AdType.IMAGE;
			}
		} catch (JSONException e) {
		}
		try {
			testState = object.getString("Gtestadrequest").equals("1");
		} catch (JSONException e) {
		}
		try {
			keywords = object.getString("Gkeywords");
		} catch (JSONException e) {
		}
		try {
			channelId = object.getString("Gchannelids");
		} catch (JSONException e) {
		}

		if (keywords == null || keywords.equals("")) {
			keywords = "None";
		}

		AdSenseSpec adSenseSpec = new AdSenseSpec(pubId) // Specify client ID. (Required) 
		.setCompanyName(companyName) // Set company name. (Required) 
		.setAppName(appName) // Set application name. (Required) 
		.setKeywords(keywords) // Specify keywords. 
		.setChannel(channelId) // Set channel ID. 
		.setAdType(adtype) // Set ad type to Text. 
		//.setExpandDirection(AdSenseSpec.ExpandDirection.TOP)
		.setAdTestEnabled(testState); // Keep
		
		if (view.getAdWidth() == 300 && view.getAdHeight() == 250) {
			adSenseSpec.setAdFormat(AdFormat.FORMAT_300x250);
		}
		else {
			adSenseSpec.setAdFormat(AdFormat.FORMAT_320x50);
		}

		mAdView.setAdViewListener(this);
		Log.d("MoPub","Showing AdSense ad...");

	    // The GoogleAdView has to be in the view hierarchy to make a request
		mAdView.setVisibility(View.INVISIBLE);
	    view.addView(mAdView, new FrameLayout.LayoutParams(
	    		FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT));

		mAdView.showAds(adSenseSpec);
	}

	public void onStartFetchAd() {}

	public void onFinishFetchAd() {
		MoPubView view = mMoPubViewReference.get(); 
		if (view != null) {
			view.removeAllViews();
			mAdView.setVisibility(View.VISIBLE);
			FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(
					FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
			layoutParams.gravity = Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL;
			view.addView(mAdView, layoutParams);
			
			view.adLoaded(); 
		} 
	}

	public void onClickAd() {
		Log.d("MoPub", "AdSense clicked"); 
		MoPubView view = mMoPubViewReference.get(); 
		if (view != null) { 
			view.registerClick(); 
		} 
	}

	public void onAdFetchFailure() {
		Log.d("MoPub", "AdSense failed. Trying another"); 
		MoPubView view = mMoPubViewReference.get(); 
		if (view != null) { 
			view.loadFailUrl(); 
		} 
	} 
}