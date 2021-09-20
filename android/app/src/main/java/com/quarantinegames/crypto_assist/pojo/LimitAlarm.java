package com.quarantinegames.crypto_assist.pojo;

import androidx.annotation.Keep;

import com.google.gson.Gson;

import java.util.Map;

@Keep
public class LimitAlarm {
    private String symbol;
    private double limit;
    private boolean lowerLimit;
    private boolean enabled;

    public LimitAlarm(String symbol, double limit, boolean lowerLimit, boolean enabled) {
        this.symbol = symbol;
        this.limit = limit;
        this.lowerLimit = lowerLimit;
        this.enabled = enabled;
    }

    public boolean isLowerLimit() {
        return lowerLimit;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public double getLimit() {
        return limit;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public static LimitAlarm fromJSON(Map<String, Object> jsonMap) {
        return new LimitAlarm(
                ((String)jsonMap.get("symbol")),
                ((double)jsonMap.get("limit")),
                ((boolean)jsonMap.get("lowerLimit")),
                ((boolean)jsonMap.get("enabled"))
        );
    }

    public String toJson() {
        return new Gson().toJson(this);
    }
}
