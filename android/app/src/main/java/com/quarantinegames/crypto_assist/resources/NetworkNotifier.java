package com.quarantinegames.crypto_assist.resources;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.os.Build;

import androidx.annotation.NonNull;

import com.quarantinegames.crypto_assist.services.AlertService;

public class NetworkNotifier {
    private AlertService alertService;

    public NetworkNotifier(AlertService alertService) {
        this.alertService = alertService;
        setListeners();
    }

    private void setListeners() {
        ConnectivityManager connectivityManager = (ConnectivityManager) alertService.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            connectivityManager.registerDefaultNetworkCallback(new ConnectivityManager.NetworkCallback(){
                @Override
                public void onAvailable(@NonNull Network network) {
                    super.onAvailable(network);
                    alertService.refreshTweetAPI();
                }
            });
        }
    }

}
