package com.quarantinegames.crypto_assist.bloc;

import android.app.Notification;
import android.content.Intent;
import android.provider.Settings;
import android.util.Log;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.quarantinegames.crypto_assist.MainActivity;
import com.quarantinegames.crypto_assist.R;
import com.quarantinegames.crypto_assist.pojo.ElonTweet;
import com.quarantinegames.crypto_assist.resources.FlutterPrefManager;
import com.quarantinegames.crypto_assist.resources.RingtoneManager;
import com.quarantinegames.crypto_assist.services.AlertService;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Pattern;

import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.subjects.PublishSubject;

public class TweetChangeHandler {
    private PublishSubject<ElonTweet> tweetPublishSubject = PublishSubject.create();
    private AlertService alertService;
    public static final String TWEET_ALARM_ROUTE = "/tweet-alarm";

    private TweetChangeHandler() {
        tweetPublishSubject.subscribe(tweet -> {
            try {
                onNewTweet(tweet);
            } catch (Exception e) {
                e.printStackTrace();
                alertService.updateStatus(AlertService.NOTIFICATION_STATUS.ERROR);
            }
        });
    }

    private String matchReason = "";
    private void onNewTweet(ElonTweet tweet) {
        Log.d(AlertService.ALERT_SERVICE_TAG, "New tweet: " + tweet.toString());
        String tweetText = tweet.getText().toLowerCase();
        List<String> tweetWords = Arrays.asList(tweetText.split(" "));
        boolean mediaAlarmEnabled = FlutterPrefManager.getInstance().getBoolean("mediaAlarm", false);
        boolean mediaMatches = (mediaAlarmEnabled && tweet.isContainsMedia());
        if(mediaMatches) {
            matchReason = "Tweet contains media";
        }
        boolean matches =
                mediaMatches ||
                Observable.fromArray(FlutterPrefManager.getInstance().getString("defaultElonFilters", "").split(","))
                        .mergeWith(
                                Observable.fromArray(FlutterPrefManager.getInstance().getString("customElonFilters", "").split(",")))
                        .map(String::trim)
                        .filter(ft -> ft.length() > 0)
                        .any(filterText -> {
                            if (filterText.startsWith("/") && filterText.endsWith("/") && filterText.length() > 2) {
                                Pattern pattern = Pattern.compile(filterText.substring(1, filterText.length() - 1));
                                boolean matched = pattern.matcher(tweetText).matches();
                                if(matched) {
                                    matchReason = "Tweet matched pattern " + filterText;
                                }
                                return matched;
                            }
                            if (filterText.startsWith("[") && filterText.endsWith("]") && filterText.length() > 2) {
                                String word = filterText.substring(1, filterText.length() - 1).toLowerCase();
                                boolean matched = tweetWords.contains(word);
                                if(matched) {
                                    matchReason = "Tweet contains word '" + word +"'";
                                }
                                return matched;
                            }
                            boolean contains = tweetText.contains(filterText.toLowerCase());
                            if(contains) {
                                matchReason = "Tweet contains sequence '" + filterText +"'";
                            }
                            return contains;
                        }).blockingGet();
        if (matches) {
            Log.d(AlertService.ALERT_SERVICE_TAG, matchReason);
            tweet.setMatchReason(matchReason);
            if(Settings.canDrawOverlays(alertService)) {
                RingtoneManager.getInstance().play();
            }
            alertService.execInUIThread(()->{
                //Goto that route if app is open.
                /*Intent routeIntent = new Intent("goto-route");
                routeIntent.putExtra("route", TWEET_ALARM_ROUTE);
                LocalBroadcastManager.getInstance(alertService).sendBroadcast(routeIntent);*/

                showNotification(tweet);
                //Try opening the app (it might be destroyed).
                Intent intent = new Intent(alertService, MainActivity.class);
                intent.setAction(Intent.ACTION_RUN);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.putExtra("routeName", TWEET_ALARM_ROUTE);
                intent.putExtra("alarm_content", tweet.toJson());
                intent.putExtra("new_alarm", true);
                alertService.startActivity(intent);
            });

        }
    }

    public void publish(ElonTweet tweet) {
        tweetPublishSubject.onNext(tweet);
    }


    //Create notifications starting from ID 3000.
    private final static AtomicInteger notificationId = new AtomicInteger(3000);
    private void showNotification(ElonTweet tweet) {
        Notification notification = new NotificationCompat.Builder(alertService, AlertService.notificationChannelId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Elon's Crypto tweet")
                .setContentText(tweet.getMatchReason())
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setAutoCancel(true).build();
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(alertService);
        notificationManager.notify(notificationId.incrementAndGet(), notification);
    }

    private static TweetChangeHandler instance;

    public static TweetChangeHandler getInstance() {
        if (instance == null) instance = new TweetChangeHandler();
        return instance;
    }

    public void init(AlertService alertService) {
        this.alertService = alertService;
    }
}
