package com.quarantinegames.crypto_assist.resources;

import android.content.Context;
import android.media.Ringtone;
import android.net.Uri;

public class RingtoneManager {
    private Ringtone ringtone;
    private static final RingtoneManager ourInstance = new RingtoneManager();

    public static RingtoneManager getInstance() {
        return ourInstance;
    }

    private RingtoneManager() {
    }

    public void play() {
        ringtone.play();
    }

    public void stop() {
        ringtone.stop();
    }

    public void init(Context context){
        Uri notification = android.media.RingtoneManager.getDefaultUri(android.media.RingtoneManager.TYPE_RINGTONE);
        ringtone = android.media.RingtoneManager.getRingtone(context.getApplicationContext(), notification);
    }
}
