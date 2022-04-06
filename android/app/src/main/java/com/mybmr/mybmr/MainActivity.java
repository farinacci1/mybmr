package com.mybmr.mybmr;

import android.os.Bundle;
import android.widget.Toast;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class MainActivity extends FlutterActivity {
    private static final String  CHANNEL = "toast.flutter.io/toast";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        flutterEngine.getPlugins().add(new GoogleMobileAdsPlugin());
        super.configureFlutterEngine(flutterEngine);

        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "adFactory", new NativeAdFactory(getLayoutInflater()));
    }

    @Override
    public void cleanUpFlutterEngine(FlutterEngine flutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "adFactory");
    }



    @Override protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(new FlutterEngine(this));

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler(){
                    @Override public void onMethodCall(MethodCall methodCall, MethodChannel.Result result){
                        if(methodCall.method.equals("showToast")){

                            Toast.makeText(getBaseContext(), methodCall.argument("message"), Toast.LENGTH_SHORT).show();
                        }else{
                            result.notImplemented();
                        }
                    }
                });


    }
}
