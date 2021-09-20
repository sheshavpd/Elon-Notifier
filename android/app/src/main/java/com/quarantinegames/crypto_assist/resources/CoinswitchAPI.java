package com.quarantinegames.crypto_assist.resources;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.GET;

public interface CoinswitchAPI {

    @GET("api/v1/coins")
    Call<List> getCoins();
}
