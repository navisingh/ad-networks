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

import android.content.Context;
import android.location.Location;
import android.util.AttributeSet;
import android.util.Log;
import android.webkit.WebViewDatabase;
import android.widget.FrameLayout;

import org.apache.http.HttpResponse;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

public class MoPubView extends FrameLayout {

    public interface OnAdWillLoadListener {
        public void OnAdWillLoad(MoPubView m, String url);
    }

    public interface OnAdLoadedListener {
        public void OnAdLoaded(MoPubView m);
    }

    public interface OnAdFailedListener {
        public void OnAdFailed(MoPubView m);
    }

    public interface OnAdClosedListener {
        public void OnAdClosed(MoPubView m);
    }

    public static String HOST = "ads.mopub.com";
    public static String AD_HANDLER = "/m/ad";

    private AdView mAdView;
    private Object mAdSenseAdapter;
    private OnAdWillLoadListener mOnAdWillLoadListener;
    private OnAdLoadedListener mOnAdLoadedListener;
    private OnAdFailedListener mOnAdFailedListener;
    private OnAdClosedListener mOnAdClosedListener;

    public MoPubView(Context context) {
        this(context, null);
    }

    public MoPubView(Context context, AttributeSet attrs) {
        super(context, attrs);

        // There is a rare bug in Froyo/2.2 where creation of a WebView causes a
        // NullPointerException. (http://code.google.com/p/android/issues/detail?id=10789)
        // It happens when the WebView can't access the local file store to make a cache file.
        // Here, we'll work around it by trying to create a file store and then just go inert
        // if it's not accessible.
        if (WebViewDatabase.getInstance(context) == null) {
            Log.e("MoPub", "Disabling MoPub. Local cache file is inaccessbile so MoPub will " +
                "fail if we try to create a WebView. Details of this Android bug found at:" +
                "http://code.google.com/p/android/issues/detail?id=10789");
            return;
        }

        // The AdView doesn't need to be in the view hierarchy until an ad is loaded
        mAdView = new AdView(context, this);
    }

    public void loadAd() {
        if (mAdView == null) {
            return;
        }
        mAdView.loadAd();
    }

    public void loadFailUrl() {
        if (mAdView == null) {
            return;
        }
        mAdView.loadFailUrl();
    }

    public void loadAdSense(String params) {
        try {
            Class.forName("com.google.ads.GoogleAdView");
        } catch (ClassNotFoundException e) {
            Log.d("MoPub", "Couldn't find AdSense SDK. Trying next ad...");
            loadFailUrl();
            return;
        }

        try {
            Class<?> adapterClass
                    = (Class<?>) Class.forName("com.mopub.mobileads.AdSenseAdapter");

            Class<?>[] parameterTypes = new Class[2];
            parameterTypes[0] = MoPubView.class;
            parameterTypes[1] = String.class;

            Constructor<?> constructor = adapterClass.getConstructor(parameterTypes);

            Object[] args = new Object[2];
            args[0] = this;
            args[1] = params;

            mAdSenseAdapter = constructor.newInstance(args);

            Method loadAdMethod = adapterClass.getMethod("loadAd", (Class[]) null);
            loadAdMethod.invoke(mAdSenseAdapter, (Object[]) null);
        } catch (ClassNotFoundException e) {
            Log.d("MoPub", "Couldn't find AdSenseAdapter class.  Trying next ad...");
            loadFailUrl();
            return;
        } catch (Exception e) {
            Log.d("MoPub", "Couldn't create AdSenseAdapter class.  Trying next ad...");
            loadFailUrl();
            return;
        }
    }

    public void registerClick() {
        if (mAdView == null) {
            return;
        }
        mAdView.registerClick();
    }

    // Getters and Setters

    public void setAdUnitId(String adUnitId) {
        if (mAdView == null) {
            return;
        }
        mAdView.setAdUnitId(adUnitId);
    }

    public void setKeywords(String keywords) {
        if (mAdView == null) {
            return;
        }
        mAdView.setKeywords(keywords);
    }

    public String getKeywords() {
        if (mAdView == null) {
            return null;
        }
        return mAdView.getKeywords();
    }

    public void setLocation(Location location) {
        if (mAdView == null) {
            return;
        }
        mAdView.setLocation(location);
    }

    public Location getLocation() {
        if (mAdView == null) {
            return null;
        }
        return mAdView.getLocation();
    }

    public void setTimeout(int milliseconds) {
        if (mAdView == null) {
            return;
        }
        mAdView.setTimeout(milliseconds);
    }

    public int getAdWidth() {
        if (mAdView == null) {
            return 0;
        }
        return mAdView.getAdWidth();
    }

    public int getAdHeight() {
        if (mAdView == null) {
            return 0;
        }
        return mAdView.getAdHeight();
    }

    public HttpResponse getResponse() {
        if (mAdView == null) {
            return null;
        }
        return mAdView.getResponse();
    }

    public String getResponseString() {
        if (mAdView == null) {
            return null;
        }
        return mAdView.getResponseString();
    }

    public void adWillLoad(String url) {
        Log.d("MoPub", "adWillLoad: "+url);
        if (mOnAdWillLoadListener != null) {
            mOnAdWillLoadListener.OnAdWillLoad(this, url);
        }
    }

    public void adLoaded() {
        Log.d("MoPub","adLoaded");
        if (mOnAdLoadedListener != null) {
            mOnAdLoadedListener.OnAdLoaded(this);
        }
    }

    public void adFailed() {
        if (mOnAdFailedListener != null) {
            mOnAdFailedListener.OnAdFailed(this);
        }
    }

    public void adClosed() {
        if (mOnAdClosedListener != null) {
            mOnAdClosedListener.OnAdClosed(this);
        }
    }

    public void setOnAdWillLoadListener(OnAdWillLoadListener listener) {
        mOnAdWillLoadListener = listener;
    }

    public void setOnAdLoadedListener(OnAdLoadedListener listener) {
        mOnAdLoadedListener = listener;
    }

    public void setOnAdFailedListener(OnAdFailedListener listener) {
        mOnAdFailedListener = listener;
    }

    public void setOnAdClosedListener(OnAdClosedListener listener) {
        mOnAdClosedListener = listener;
    }
}