package com.quarantinegames.crypto_assist.services;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import com.quarantinegames.crypto_assist.MainActivity;
import com.quarantinegames.crypto_assist.R;
import com.quarantinegames.crypto_assist.bloc.CoinswitchResponseHandler;
import com.quarantinegames.crypto_assist.bloc.TweetChangeHandler;
import com.quarantinegames.crypto_assist.bloc.TweetResponseHandler;
import com.quarantinegames.crypto_assist.resources.ApiClient;
import com.quarantinegames.crypto_assist.resources.CoinswitchAPI;
import com.quarantinegames.crypto_assist.resources.FlutterPrefManager;
import com.quarantinegames.crypto_assist.resources.NetworkNotifier;
import com.quarantinegames.crypto_assist.resources.RingtoneManager;
import com.quarantinegames.crypto_assist.resources.TwitterAPI;

import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import io.reactivex.rxjava3.subjects.PublishSubject;
import retrofit2.Call;

public class AlertService extends Service {

    public static final String notificationChannelId = "com.quarantinegames.crypto_assist|alertService";
    private static final int ongoing_notification_id = 1;
    public static final String ALERT_SERVICE_TAG = "Notifier/AlertService";
    private Timer timer = new Timer();
    public static final String CMD_RELOAD_CONFIG = "RELOAD_CFG";
    public static final String CMD_REFRESH = "REFRESH";
    public static final String CMD_STOP_RINGING = "STOP_RINGING";
    /*private PublishSubject<NOTIFICATION_STATUS> statusChangeSubject = PublishSubject.create();*/
    private NetworkNotifier networkNotifier;
    private CoinswitchResponseHandler coinswitchResponseHandler;

    @Override
    public void onCreate() {
        super.onCreate();
        FlutterPrefManager.getInstance().init(this); //Initiate preferences before super.onCreate
        RingtoneManager.getInstance().init(this);
        coinswitchResponseHandler = new CoinswitchResponseHandler(this);
        TweetChangeHandler.getInstance().init(this);
        runLoop();
        networkNotifier = new NetworkNotifier(this);
    }

    private Call<Map> tweetCall;
    private Call<List> coinswitchCall;
    Handler handler;
    //Elon musk profile
    private final String variables = "{\"userId\":\"44196397\",\"count\":20,\"withHighlightedLabel\":true,\"withTweetQuoteCount\":true,\"includePromotedContent\":true,\"withTweetResult\":false,\"withReactions\":false,\"withUserResults\":false,\"withVoice\":false,\"withNonLegacyCard\":true,\"withBirdwatchPivots\":false}";
    //My Profile
    //private final String variables = "{\"userId\":\"478658856\",\"count\":20,\"withHighlightedLabel\":true,\"withTweetQuoteCount\":true,\"includePromotedContent\":true,\"withTweetResult\":false,\"withReactions\":false,\"withUserResults\":false,\"withVoice\":false,\"withNonLegacyCard\":true,\"withBirdwatchPivots\":false}";
    TimerTask webViewReloadTask, checkAlarmLimitsTask;
    private static final long WEBVIEW_RELOAD_INTERVAL = 4 * 60000; //Every 4 minutes, reload webview.
    private static final long TWEET_REFRESH_INTERVAL = 20000; //20 seconds
    private static final long LIMITS_REFRESH_INTERVAL = 30000; //30 seconds
    public static final String USER_URL = "https://twitter.com/elonmusk";
    //public static final String USER_URL = "https://twitter.com/SVPDRC";

    private void runLoop() {
        handler = new Handler(getMainLooper());
        WebView webView = new WebView(this);
        webView.getSettings().setJavaScriptEnabled(true);
        webViewReloadTask = new TimerTask() {
            @Override
            public void run() {
                Log.d(ALERT_SERVICE_TAG, "Loading webview");
                handler.post(() -> {
                    webView.loadUrl(USER_URL);
                });
            }
        };
        coinswitchCall = ApiClient.getCoinswitchClient().create(CoinswitchAPI.class).getCoins();
        checkAlarmLimitsTask = new TimerTask() {
            @Override
            public void run() {

                if (coinswitchResponseHandler.getLimitAlarms().size() > 0) {
                    Log.d(ALERT_SERVICE_TAG, "Checking Limit Alarms");
                    coinswitchCall.clone().enqueue(coinswitchResponseHandler);
                }
            }
        };
        timer.scheduleAtFixedRate(webViewReloadTask, 0, WEBVIEW_RELOAD_INTERVAL);
        timer.scheduleAtFixedRate(checkAlarmLimitsTask, 0, LIMITS_REFRESH_INTERVAL);
        webView.setWebViewClient(new WebViewClient() {
            @Nullable
            @Override
            public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest request) {
                String url = request.getUrl().toString();
                WebResourceResponse response = super.shouldInterceptRequest(view, request);
                if (!url.contains("UserTweets")) {
                    return response;
                }
                Log.d(ALERT_SERVICE_TAG, "Intercepted userTweets");
                tweetCall = ApiClient.getClient().create(TwitterAPI.class).getTweets(url, request.getRequestHeaders(), variables);
                handler.post(view::stopLoading);
                updateStatus(NOTIFICATION_STATUS.FETCHING);
                return response;
            }
        });
        Thread checkTweetsThread = new Thread(() -> {
            while (true) {
                if (tweetCall != null) {
                    Log.d(ALERT_SERVICE_TAG, "Calling UserTweets");
                    tweetCall.clone().enqueue(new TweetResponseHandler(this));
                }
                try {
                    Thread.sleep(TWEET_REFRESH_INTERVAL);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });
        checkTweetsThread.start();
        /*statusChangeSubject.distinctUntilChanged().subscribe(this::updateNotification);*/
    }

    public void refreshTweetAPI() {
        handler.post(() -> {
            webViewReloadTask.run();
        });
    }

    public void execInUIThread(Runnable runnable) {
        handler.post(runnable);
    }

    boolean started = false;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && intent.getAction() != null) {
            if (intent.getAction().equals("stopSelf")) {
                stopForeground(true);
                stopSelf(startId);
            } else if (intent.getAction().equals(CMD_REFRESH)) {
                refreshTweetAPI();
                updateStatus(NOTIFICATION_STATUS.WAITING);
            } else if (intent.getAction().equals(CMD_RELOAD_CONFIG)) {
                reloadConfigurations();
            } else if (intent.getAction().equals(CMD_STOP_RINGING)) {
                RingtoneManager.getInstance().stop();
            }
        }
        if (!started) showNotification();
        started = true;
        return START_REDELIVER_INTENT;
    }

    private void reloadConfigurations() {
        coinswitchResponseHandler.reloadLimitAlarms();
    }


    private void showNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            createNotificationChannel(notificationChannelId, "Alert Service");
        startForeground(ongoing_notification_id, getMyNotification(NOTIFICATION_STATUS.WAITING));

    }

    public enum NOTIFICATION_STATUS {
        WAITING,
        FETCHING,
        ERROR
    }

    private Notification getMyNotification(NOTIFICATION_STATUS notification_status) {
        // The PendingIntent to launch our activity if the user selects
        // this notification
        Intent notificationIntent = new Intent(this, MainActivity.class);
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);
        Bitmap icon = BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher);

        Intent stopIntent = new Intent(this, AlertService.class);
        stopIntent.setAction("stopSelf");
        PendingIntent stopActionIntent = PendingIntent.getService(this, 0, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        Intent refreshIntent = new Intent(this, AlertService.class);
        refreshIntent.setAction(CMD_REFRESH);
        PendingIntent refreshActionIntent = PendingIntent.getService(this, 0, refreshIntent, PendingIntent.FLAG_UPDATE_CURRENT);


        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, notificationChannelId)
                .setOngoing(true)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setContentTitle("Alarm service")
                .setSmallIcon(R.mipmap.logo_min)
                .setContentIntent(pendingIntent)
                .addAction(android.R.drawable.ic_menu_close_clear_cancel, "STOP", stopActionIntent)
                .addAction(android.R.drawable.ic_popup_sync, "REFRESH", refreshActionIntent)
                .setLargeIcon(Bitmap.createScaledBitmap(icon, 128, 128, false));
        String text = "";
        switch (notification_status) {
            case ERROR:
                text = "Error Fetching.";
                break;
            case FETCHING:
                text = "Running without draining battery :)";
                break;
            case WAITING:
                text = "Initializing...";
                break;
        }

        builder.setContentText(text);
        builder.setStyle(new NotificationCompat.BigTextStyle().bigText(coinswitchResponseHandler.getCurrencyPricesString()));

        return builder.build();
    }

    private void updateNotification(NOTIFICATION_STATUS notification_status) {
        Notification notification = getMyNotification(notification_status);
        NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.notify(ongoing_notification_id, notification);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private void createNotificationChannel(String channelId, String channelName) {
        NotificationChannel channel = new NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_NONE);
        channel.setLightColor(Color.BLUE);
        channel.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        manager.createNotificationChannel(channel);
    }

    public void updateStatus(NOTIFICATION_STATUS status) {
        /*statusChangeSubject.onNext(status);*/
        updateNotification(status);
    }
}
