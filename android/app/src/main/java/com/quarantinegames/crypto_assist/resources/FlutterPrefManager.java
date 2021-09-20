package com.quarantinegames.crypto_assist.resources;

import android.content.Context;
import android.content.SharedPreferences;

import com.quarantinegames.crypto_assist.R;

public class FlutterPrefManager {

    private SharedPreferences.Editor editor;
    private SharedPreferences pref;

    private static FlutterPrefManager instance;
    private FlutterPrefManager(){}

    public static FlutterPrefManager getInstance() {
        if(instance == null) instance = new FlutterPrefManager();
        return instance;
    }

    public void init(Context context) {
        pref = context.getApplicationContext().getSharedPreferences(context.getString(R.string.app_prefs), 0); // 0 - for private mode
        editor = pref.edit();
        remove("defaultElonFilters");
        commit();
        putString("defaultElonFilters", "bitcoin, [eth], ethereum, doge, crypto");
        commit();
    }

    private String flutterKey(String key) {
        return "flutter."+key;
    }

    public void remove(String key) {
        editor.remove(flutterKey(key));
    }

    public void commit() {
        editor.commit();
    }
    public void putString(String key, String val) {
        editor.putString(flutterKey(key), val);
    }

    public void putBoolean(String key, boolean val) {
        editor.putBoolean(flutterKey(key), val);
    }

    public void putInt(String key, int val) {
        editor.putInt(flutterKey(key), val);
    }

    public void putLong(String key, long val) {
        editor.putLong(flutterKey(key), val);
    }

    public void putFloat(String key, float val) {
        editor.putFloat(flutterKey(key), val);
    }

    public String getString(String key, String def) {
        return pref.getString(flutterKey(key), def);
    }

    public boolean getBoolean(String key, boolean def) {
        return pref.getBoolean(flutterKey(key), def);
    }

    public int getInt(String key, int def) {
        return pref.getInt(flutterKey(key), def);
    }

    public long getLong(String key, long def) {
        return pref.getLong(flutterKey(key), def);
    }

    public float getFloat(String key, float def) {
        return pref.getFloat(flutterKey(key), def);
    }
}
