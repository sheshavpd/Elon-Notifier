package com.quarantinegames.crypto_assist.pojo;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.quarantinegames.crypto_assist.services.AlertService;

@Keep
public class ElonTweet {
    private String text;
    private boolean containsMedia;
    private String id;
    private String url;
    private String matchReason;

    public ElonTweet(String id, String text, boolean containsMedia) {
        this.id = id;
        this.text = text;
        this.containsMedia = containsMedia;
        this.url = AlertService.USER_URL + "/status/"+id;
    }

    public boolean isContainsMedia() {
        return containsMedia;
    }

    public void setContainsMedia(boolean containsMedia) {
        this.containsMedia = containsMedia;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    @NonNull
    @Override
    public String toString() {
        return "[Elon Tweet] Text: "+text+"\n"+
                "Contains Media: "+ containsMedia+"\n"+
                "ID: " + id;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String toJson() {
        return new Gson().toJson(this);
    }

    public String getMatchReason() {
        return matchReason;
    }

    public void setMatchReason(String matchReason) {
        this.matchReason = matchReason;
    }

    public String getUrl() {
        return url;
    }
}
