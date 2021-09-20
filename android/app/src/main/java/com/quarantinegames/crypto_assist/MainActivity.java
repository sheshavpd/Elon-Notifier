package com.quarantinegames.crypto_assist;

import android.annotation.TargetApi;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.quarantinegames.crypto_assist.channels.CommonChannel;
import com.quarantinegames.crypto_assist.resources.FlutterPrefManager;
import com.quarantinegames.crypto_assist.services.AlertService;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;


public class MainActivity extends FlutterActivity {

    public static int ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST_CODE = 5469;
    private CommonChannel commonChannel;
    private static final String TAG = "Notifier/Main";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        FlutterPrefManager.getInstance().init(this);
        super.onCreate(savedInstanceState);
        Intent service = new Intent(MainActivity.this, AlertService.class);
        ContextCompat.startForegroundService(this, service);

        // This registers messageReceiver to receive messages.
        /*LocalBroadcastManager.getInstance(this)
                .registerReceiver(messageReceiver, new IntentFilter("goto-route"));*/
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        onIntentReceived(intent);
    }

    public void checkStartIntent() {
        onIntentReceived(getIntent());
    }

    private void onIntentReceived(Intent intent) {
        if(intent == null || !intent.hasExtra("new_alarm"))
            return;
        commonChannel.gotoRoute(intent.getStringExtra("routeName"), intent.getStringExtra("alarm_content"));
        Log.d(TAG, "New alarm intent received: " + intent.getStringExtra("alarm_content"));
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        commonChannel = new CommonChannel(this, flutterEngine, getString(R.string.commonChannel));
    }


    /*private BroadcastReceiver messageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
           commonChannel.gotoRoute(intent.getStringExtra("route"));
        }
    };*/

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        // Unregister since the activity is not visible
        //LocalBroadcastManager.getInstance(this).unregisterReceiver(messageReceiver);
        super.onDestroy();
    }

    public boolean checkDrawPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return Settings.canDrawOverlays(this);
        }
        return true; // on lower OS versions granted during apk installation
    }

    public boolean askDrawPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:" + getPackageName()));
                startActivityForResult(intent, ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST_CODE);
                return false; // above will start new Activity with proper app setting
            }
        }
        return true; // on lower OS versions granted during apk installation
    }

    @TargetApi(Build.VERSION_CODES.M)
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST_CODE) {
            if (!Settings.canDrawOverlays(this)) {
                //User didn't provide permission
            } else {
                commonChannel.drawPermissionGranted();
            }

        }
    }
}
