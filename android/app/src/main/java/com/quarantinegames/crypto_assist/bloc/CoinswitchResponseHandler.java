package com.quarantinegames.crypto_assist.bloc;

import android.app.Notification;
import android.app.PendingIntent;
import android.content.Intent;
import android.provider.Settings;
import android.util.Log;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.google.gson.Gson;
import com.quarantinegames.crypto_assist.MainActivity;
import com.quarantinegames.crypto_assist.R;
import com.quarantinegames.crypto_assist.pojo.LimitAlarm;
import com.quarantinegames.crypto_assist.resources.FlutterPrefManager;
import com.quarantinegames.crypto_assist.resources.RingtoneManager;
import com.quarantinegames.crypto_assist.resources.utils.JsonUtils;
import com.quarantinegames.crypto_assist.services.AlertService;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class CoinswitchResponseHandler implements Callback<List> {
    private AlertService alertService;
    private List<LimitAlarm> limitAlarms = Collections.synchronizedList(new ArrayList<>());
    public static final String LIMIT_ALARM_ROUTE = "/limit-alarm";

    public CoinswitchResponseHandler(AlertService alertService) {
        this.alertService = alertService;
        reloadLimitAlarms();
    }

    public void reloadLimitAlarms() {
        limitAlarms.clear();
        List alarmsList = new Gson().fromJson(FlutterPrefManager.getInstance().getString("limitAlarms", "[]"), List.class);
        synchronized (limitAlarms) {
            for (Object alarmMap : alarmsList) {
                limitAlarms.add(LimitAlarm.fromJSON((Map<String, Object>) alarmMap));
            }
        }
        Log.d(AlertService.ALERT_SERVICE_TAG, "Alarm configurations Reloaded");
    }

    static Map<String, Double> extractValues(List response) {
        Map<String, Double> coinValueMap = new HashMap<>();
        for (Object obj : response) {
            String symbol = JsonUtils.getEntry(obj, String.class, "symbol");
            double rate = JsonUtils.getEntry(obj, Double.class, "cmc_coin", "rate_inr");
            coinValueMap.put(symbol, rate);
        }
        return coinValueMap;
    }

    private String currencyPricesString = "";
    @Override
    public void onResponse(Call<List> call, Response<List> response) {
        try {
            Map<String, Double> latestValues = extractValues(response.body());
            Map<String, Double> interestedValues = new HashMap<>();
            List<LimitAlarm> alarmsTriggered = new ArrayList<>();
            synchronized (limitAlarms) {
                Iterator<LimitAlarm> it = limitAlarms.iterator();
                while (it.hasNext()) {
                    LimitAlarm limitAlarm = it.next();
                    if(!limitAlarm.isEnabled()) {
                        continue;
                    }
                    //Log.d(AlertService.ALERT_SERVICE_TAG, "Checking Limit for "+limitAlarm.getSymbol());
                    if (latestValues.containsKey(limitAlarm.getSymbol())) {
                        interestedValues.put(limitAlarm.getSymbol(), latestValues.get(limitAlarm.getSymbol()));
                        //Log.d(AlertService.ALERT_SERVICE_TAG, latestValues.get(limitAlarm.getSymbol()) + ", "+limitAlarm.getLimit() + ", "+ limitAlarm.isLowerLimit());
                        if (limitAlarm.isLowerLimit()) {
                            if (latestValues.get(limitAlarm.getSymbol()) <= limitAlarm.getLimit()) {
                                it.remove();
                                alarmsTriggered.add(limitAlarm);
                            }
                        } else {
                            if (latestValues.get(limitAlarm.getSymbol()) >= limitAlarm.getLimit()) {
                                it.remove();
                                alarmsTriggered.add(limitAlarm);
                            }
                        }
                    }
                }
            }
            if(alarmsTriggered.size() > 0) {
                FlutterPrefManager.getInstance().putString("limitAlarms", new Gson().toJson(limitAlarms));
                FlutterPrefManager.getInstance().commit();
                for(LimitAlarm alarm: alarmsTriggered) {
                    raiseAlarm(alarm);
                }
            }
            if(interestedValues.size() > 0) {
                StringBuilder watcherBuilder = new StringBuilder();
                for(Map.Entry<String, Double> entry: interestedValues.entrySet()) {
                    watcherBuilder.append(entry.getKey().toUpperCase())
                            .append(": ")
                            .append(entry.getValue())
                            .append("\n");
                }
                if(watcherBuilder.length() > 0)
                    watcherBuilder.deleteCharAt(watcherBuilder.length() - 1);
                currencyPricesString = watcherBuilder.toString();
            }
        } catch (Exception e) {
            alertService.updateStatus(AlertService.NOTIFICATION_STATUS.ERROR);
        }
    }


    private void raiseAlarm(LimitAlarm limitAlarm) {
        showNotification(limitAlarm);
        if(Settings.canDrawOverlays(alertService)) {
            RingtoneManager.getInstance().play();
        }
        Intent intent = new Intent(alertService, MainActivity.class);
        intent.setAction(Intent.ACTION_RUN);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("routeName", LIMIT_ALARM_ROUTE);
        intent.putExtra("alarm_content", limitAlarm.toJson());
        intent.putExtra("new_alarm", true);
        alertService.startActivity(intent);
    }

    //Create notifications starting from ID 50000.
    private final static AtomicInteger notificationId = new AtomicInteger(50000);

    private void showNotification(LimitAlarm limitAlarm) {
        String content = limitAlarm.getSymbol().toUpperCase() +
                (limitAlarm.isLowerLimit() ? " went below " : " went above ") +
                limitAlarm.getLimit();
        Intent notificationIntent = alertService.getPackageManager().getLaunchIntentForPackage("com.coinswitch.kuber");


        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(alertService, AlertService.notificationChannelId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Limit breached")
                .setContentText(content)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setAutoCancel(true);

        if(notificationIntent != null) {
            notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
                    | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            PendingIntent intent = PendingIntent.getActivity(alertService, 0,
                    notificationIntent, 0);
            notificationBuilder.setContentIntent(intent);
        }
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(alertService);
        notificationManager.notify(notificationId.incrementAndGet(), notificationBuilder.build());
    }

    @Override
    public void onFailure(Call<List> call, Throwable t) {

    }


    public List<LimitAlarm> getLimitAlarms() {
        return limitAlarms;
    }

    public String getCurrencyPricesString() {
        return currencyPricesString;
    }
}
