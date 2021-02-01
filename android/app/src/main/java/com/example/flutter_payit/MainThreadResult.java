package com.example.flutter_payit;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodChannel;

public class MainThreadResult implements MethodChannel.Result {
    private MethodChannel.Result result;
    private Handler handler;

    MainThreadResult(MethodChannel.Result result) {
        this.result = result;
        handler = new Handler(Looper.getMainLooper());
    }

        @Override
        public void success(final Object r) {
            handler.post(
                    () -> result.success(r));
    }

    @Override
    public void error(
            final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(
                () -> result.error(errorCode, errorMessage, errorDetails));
    }

    @Override
    public void notImplemented() {
        handler.post(
                () -> result.notImplemented());
    }
}
