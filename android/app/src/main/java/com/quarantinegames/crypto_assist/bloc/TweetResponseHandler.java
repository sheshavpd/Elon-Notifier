package com.quarantinegames.crypto_assist.bloc;

import android.util.Log;

import com.quarantinegames.crypto_assist.pojo.ElonTweet;
import com.quarantinegames.crypto_assist.resources.FlutterPrefManager;
import com.quarantinegames.crypto_assist.resources.utils.JsonUtils;
import com.quarantinegames.crypto_assist.services.AlertService;

import java.math.BigInteger;
import java.util.List;
import java.util.Map;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;


public class TweetResponseHandler implements Callback<Map> {
    private AlertService alertService;

    public TweetResponseHandler(AlertService alertService) {
        this.alertService = alertService;
    }

    static ElonTweet extractTweet(Map response) {
        Object instruction = JsonUtils.getEntry(response, List.class, "data", "user", "result", "timeline",
                "timeline", "instructions").get(0);
        List entries = JsonUtils.getEntry(instruction, List.class, "entries");
        for (Object entry : entries) {
            Map itemContent = JsonUtils.getEntry(entry, Map.class, "content", "itemContent");
            if (!(itemContent.containsKey("itemType") && itemContent.get("itemType").equals("TimelineTweet"))) {
                continue;
            }
            Map tweetMap = JsonUtils.getEntry(itemContent, Map.class, "tweet", "legacy");
            if (!tweetMap.containsKey("retweeted_status")) {
                String text = (String) tweetMap.get("full_text");
                String id = (String) tweetMap.get("id_str");
                return new ElonTweet(id, text, JsonUtils.containsEntry(tweetMap, "extended_entities", "media"));
                //System.out.println(elonTweet.toString());
            }
        }
        return null;
        //return response.get("data").get("user").get("result").get("timeline").get("timeline").get("instructions").get(0).get("entries").get(0).get("content").get("itemContent").get("tweet").get("legacy").get("full_text");
    }

    @Override
    public void onResponse(Call<Map> call, Response<Map> response) {
        try {
            ElonTweet tweet = extractTweet(response.body());
            Log.d(AlertService.ALERT_SERVICE_TAG, "Latest tweet: "+tweet);
            alertService.updateStatus(AlertService.NOTIFICATION_STATUS.FETCHING);
            //should inspect why tweet contains null fields even though tweet itself isn't null.
            if(tweet == null || tweet.getText() == null) {
                return;
            }

            FlutterPrefManager pref = FlutterPrefManager.getInstance();
            String lastTweetID = pref.getString("last_tweet_id", "");
            if(!lastTweetID.equals(tweet.getId())) {
                pref.putString("last_tweet_id", tweet.getId());
                pref.commit();
                if(!lastTweetID.equals("")) {
                    if(new BigInteger(tweet.getId()).compareTo(new BigInteger(lastTweetID)) > 0) {
                        Log.d(AlertService.ALERT_SERVICE_TAG, "Tweet changed: "+tweet);
                        TweetChangeHandler.getInstance().publish(tweet);
                    }
                }
            }
        }catch (Exception e) {
            e.printStackTrace();
            alertService.updateStatus(AlertService.NOTIFICATION_STATUS.ERROR);
            alertService.refreshTweetAPI(); //Refresh webview. Reset the cookies.
        }
        //response.body().get("data").get("user").get("result").get("timeline").get("timeline").get("instructions").get(0).get("entries").get(0).get("content").get("itemContent").get("tweet").get("legacy").get("full_text")
        Log.d(AlertService.ALERT_SERVICE_TAG, "Received response");
    }

    @Override
    public void onFailure(Call<Map> call, Throwable t) {
        alertService.updateStatus(AlertService.NOTIFICATION_STATUS.ERROR);
    }
}
