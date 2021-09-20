package com.quarantinegames.crypto_assist.channels;

import android.content.Intent;

import com.quarantinegames.crypto_assist.MainActivity;
import com.quarantinegames.crypto_assist.services.AlertService;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CommonChannel {
    private MainActivity mainActivity;
    private FlutterEngine flutterEngine;
    MethodChannel containedChannel;

    public CommonChannel(MainActivity mainActivity, FlutterEngine flutterEngine, String channelName) {
        this.mainActivity = mainActivity;
        this.flutterEngine = flutterEngine;
        containedChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),
                channelName);
        containedChannel.setMethodCallHandler(this::switchToFunction);
    }

    private void switchToFunction(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "stopAlarm":
                stopAlarm(methodCall, result);
                break;
            case "checkAlarmStart":
                checkAlarmStart();
                break;
            case "checkDrawPermission":
                checkDrawPermission(methodCall, result);
                break;
            case "askDrawPermission":
                mainActivity.askDrawPermission();
                break;
            case "reloadAlarmConfigs":
                reloadAlarmConfigs();
                break;
            default:
                result.notImplemented();
        }
    }

    private void reloadAlarmConfigs() {
        Intent reloadCFGIntent = new Intent(mainActivity, AlertService.class);
        reloadCFGIntent.setAction(AlertService.CMD_RELOAD_CONFIG);
        mainActivity.startService(reloadCFGIntent);
    }


    private void checkDrawPermission(MethodCall methodCall, MethodChannel.Result result) {
        result.success(mainActivity.checkDrawPermission());
    }

    private void checkAlarmStart() {
        mainActivity.checkStartIntent();
    }

    private void stopAlarm(MethodCall methodCall, MethodChannel.Result result) {
        Intent stopIntent = new Intent(mainActivity, AlertService.class);
        stopIntent.setAction(AlertService.CMD_STOP_RINGING);
        mainActivity.startService(stopIntent);
        result.success(true);
    }

    public void drawPermissionGranted() {
        containedChannel.invokeMethod("drawPermissionGranted", null);
    }

    public void gotoRoute(String route, String content) {
        Map<String, String> arguments = new HashMap<>();
        arguments.put("route", route);
        arguments.put("content", content);
        containedChannel.invokeMethod("gotoRoute", arguments);
    }


    /*private void restoreApp(MethodCall methodCall, MethodChannel.Result result) {
        // Restore activity
        Intent i = new Intent(mainActivity, MainActivity.class);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        i.addFlags(Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
        i.setAction(Intent.ACTION_RUN);
        i.putExtra("route", "/dashboard");
        PendingIntent pendingIntent =
                PendingIntent.getActivity(mainActivity, 0, i, 0);
        try {
            pendingIntent.send();
        } catch (PendingIntent.CanceledException e) {
            e.printStackTrace();
        }
    }*/
}
