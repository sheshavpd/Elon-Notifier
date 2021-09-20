package com.quarantinegames.crypto_assist.resources;

import java.util.Map;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.HeaderMap;
import retrofit2.http.Query;
import retrofit2.http.Url;

public interface TwitterAPI {

    @GET
    Call<Map> getTweets(@Url String url, @HeaderMap Map<String, String> headers, @Query("variables") String variables);

}
