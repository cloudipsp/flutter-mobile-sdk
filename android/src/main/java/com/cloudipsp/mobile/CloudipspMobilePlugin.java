package com.cloudipsp.mobile;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.wallet.AutoResolveHelper;
import com.google.android.gms.wallet.PaymentData;
import com.google.android.gms.wallet.PaymentDataRequest;
import com.google.android.gms.wallet.PaymentsClient;
import com.google.android.gms.wallet.Wallet;
import com.google.android.gms.wallet.WalletConstants;

import org.json.JSONObject;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;


public class CloudipspMobilePlugin implements
        ActivityAware,
        FlutterPlugin,
        MethodCallHandler,
        PluginRegistry.ActivityResultListener {
    private static final int RC_GOOGLE_PAY = 41750;

    private ActivityPluginBinding activityPluginBinding;
    private Context applicationContext;
    private MethodChannel channel;
    private Result activeGooglePayResult;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        applicationContext = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "cloudipsp_mobile");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        applicationContext = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if ("supportsGooglePay".equals(call.method)) {
            supportsGooglePay(result);
        } else if ("googlePay".equals(call.method)) {
            googlePay(new JSONObject((Map) call.arguments), result);
        } else if ("setCookie".equals(call.method)) {
            setCookie(
                    call.<String>argument("url"),
                    call.<String>argument("cookie"),
                    result
            );
        } else {
            result.notImplemented();
        }
    }

    private static boolean isGooglePayRuntimeProvided() {
        try {
            Class.forName("com.google.android.gms.common.GoogleApiAvailability");
            Class.forName("com.google.android.gms.wallet.PaymentDataRequest");
            return true;
        } catch (ClassNotFoundException e) {
            return false;
        }
    }

    private void supportsGooglePay(@NonNull Result result) {
        boolean supports = false;
        if (isGooglePayRuntimeProvided()) {
            supports = GoogleApiAvailability.getInstance()
                    .isGooglePlayServicesAvailable(applicationContext) == ConnectionResult.SUCCESS;
        }
        result.success(supports);
    }

    private void googlePay(JSONObject config, @NonNull Result result) {
        if (activeGooglePayResult != null) {
            result.error("IllegalState", "GooglePay already launched", null);
        }
        final ActivityPluginBinding activityPluginBinding = this.activityPluginBinding;
        if (activityPluginBinding == null) {
            result.error("IllegalState", "ActivityPluginBinding was not set", null);
            return;
        }

        activeGooglePayResult = result;
        final PaymentDataRequest request = PaymentDataRequest.fromJson(config.toString());

        final Activity activity = activityPluginBinding.getActivity();
        final PaymentsClient paymentsClient = Wallet.getPaymentsClient(activity,
                new Wallet.WalletOptions.Builder()
                        .setEnvironment(
                                "PRODUCTION".equals(config.optString("environment"))
                                        ? WalletConstants.ENVIRONMENT_PRODUCTION
                                        : WalletConstants.ENVIRONMENT_TEST
                        )
                        .build());
        AutoResolveHelper.resolveTask(
                paymentsClient.loadPaymentData(request),
                activity,
                RC_GOOGLE_PAY);
    }

    private void setCookie(String url, String cookie, @NonNull final Result result) {
        final CookieManager cookieManager = CookieManager.getInstance();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            cookieManager.setCookie(url, cookie, new ValueCallback<Boolean>() {
                @Override
                public void onReceiveValue(Boolean value) {
                    result.success(null);
                }
            });
        } else {
            cookieManager.setCookie(url, cookie);
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        if (activityPluginBinding != null) {
            activityPluginBinding.removeActivityResultListener(this);
            activityPluginBinding = null;
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode != RC_GOOGLE_PAY) {
            return false;
        }
        if (activeGooglePayResult == null) {
            return false;
        }
        final Result result = activeGooglePayResult;
        activeGooglePayResult = null;

        if (resultCode == Activity.RESULT_CANCELED) {
            result.error("CANCELED", null, null);
        } else if (resultCode == Activity.RESULT_OK) {
            final PaymentData paymentData = PaymentData.getFromIntent(data);
            if (paymentData == null) {
                result.error("ERROR", "Missed payment data", null);
            } else {
                result.success(paymentData.toJson());
            }
        } else {
            result.error("ERROR", "Unsupported result code", null);
        }

        return true;
    }
}
