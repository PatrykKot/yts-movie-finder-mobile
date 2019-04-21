package com.example.yts_finder_mobile;

import android.annotation.TargetApi;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.os.Build;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), "vpn")
                .setMethodCallHandler((call, result) -> result.success(isVpnEnabled()));
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private Boolean isVpnEnabled() {
        ConnectivityManager connectivityManager = (ConnectivityManager) getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        Network[] networks = connectivityManager.getAllNetworks();

        for (int i = 0; i < networks.length; i++) {
            NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(networks[i]);

            if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) {
                return true;
            }
        }

        return false;
    }
}
