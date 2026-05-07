package com.walid.tokentrove;

import android.os.Bundle;
import android.widget.FrameLayout;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.startapp.sdk.adsbase.StartAppAd;
import com.startapp.sdk.adsbase.StartAppSDK;
import com.startapp.sdk.ads.banner.Banner;
import com.startapp.sdk.adsbase.adlisteners.AdEventListener;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "start_io_ads";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "initSdk":
                        StartAppSDK.init(this, "207483674", true);
                        result.success(null);
                        break;
                    case "showBanner":
                        Banner banner = new Banner(this);
                        addContentView(banner, new FrameLayout.LayoutParams(
                                FrameLayout.LayoutParams.MATCH_PARENT,
                                FrameLayout.LayoutParams.WRAP_CONTENT));
                        result.success(null);
                        break;
                    case "showInterstitial":
                        StartAppAd.showAd(this);
                        result.success(null);
                        break;
                    case "showRewardedVideo":
                        StartAppAd rewardedAd = new StartAppAd(this);
                        rewardedAd.loadAd(StartAppAd.AdMode.REWARDED_VIDEO, new AdEventListener() {
                            @Override
                            public void onReceiveAd(com.startapp.sdk.adsbase.Ad ad) {
                                rewardedAd.showAd();
                            }

                            @Override
                            public void onFailedToReceiveAd(com.startapp.sdk.adsbase.Ad ad) {
                                // Handle ad load failure
                            }
                        });
                        result.success(null);
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            });
    }
}
