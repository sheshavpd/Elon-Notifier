package com.quarantinegames.crypto_assist.resources.utils;

import java.util.Map;

public class JsonUtils {


    public static <T> T getEntry(Object object, Class<T> resultClazz, String... objectEntries) {
        Map map = (Map) object;
        T res = null;
        for (int i = 0; i < objectEntries.length; i++) {
            if (i == objectEntries.length - 1) {
                res = resultClazz.cast(map.get(objectEntries[i]));
                break;
            }
            map = (Map) map.get(objectEntries[i]);
        }
        if (res == null) {
            res = resultClazz.cast(map);
        }
        return res;
    }

    public static boolean containsEntry(Object object, String... objectEntries) {
        Map map = (Map) object;
        for (int i = 0; i < objectEntries.length; i++) {
            if (!map.containsKey(objectEntries[i]))
                return false;
            if (i != objectEntries.length - 1)
                map = (Map) map.get(objectEntries[i]);
        }
        return true;
    }
}
