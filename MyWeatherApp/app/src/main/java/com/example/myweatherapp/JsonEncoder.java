package com.example.myweatherapp;

import android.content.Context;
import android.util.Log;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.FileWriter;
import java.io.IOException;

public class JsonEncoder {

    public static JsonObjectRequest buildRequest(String city, final Context context){
        String requestURL="https://api.waqi.info/feed/"+city+"/?token=320bc7c9c75fa7c72d0309802b368341322af58c";
        RequestQueue requestQueue = Volley.newRequestQueue(context);
        JsonObjectRequest objectRequest=new JsonObjectRequest(
                Request.Method.GET,
                requestURL,
                null,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                    Log.e("Zawartość JSON", response.toString());
                        try {
                            getName(response);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        System.out.println("Request nie zadzialal");
                    }
                }

        );
        requestQueue.add(objectRequest);
        System.out.println(objectRequest.toString());
        return objectRequest;
    }

    private static void getName(JSONObject response) throws JSONException {
  JSO;
//        System.out.println(arr);
        //return arr.getJSONObject(0).getString("Status");
    }
//    public void readJSONData(RequestQueue requestQueue){
//        requestQueue.
//    }


}
