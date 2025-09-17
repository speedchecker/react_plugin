// SpeedCheckerPluginModule.java

package com.speedchecker_react_native_plugin;

import android.os.Build;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.speedchecker.android.sdk.Public.Server;
import com.speedchecker.android.sdk.Public.SpeedTestListener;
import com.speedchecker.android.sdk.Public.SpeedTestOptions;
import com.speedchecker.android.sdk.Public.SpeedTestResult;
import com.speedchecker.android.sdk.SpeedcheckerSDK;

public class SpeedCheckerPluginModule extends ReactContextBaseJavaModule {

    private static final String PLUGIN_NAME = "SpeedCheckerPlugin";
    private Server server = null;
    private int speedTestType = 0;
    private String licenseKey;

    private final ReactApplicationContext reactContext;

    public SpeedCheckerPluginModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return PLUGIN_NAME;
    }

    @Override
    public void initialize() {
        super.initialize();
        if (licenseKey != null && !licenseKey.isEmpty()) {
            SpeedcheckerSDK.init(reactContext, licenseKey);
        } else {
            SpeedcheckerSDK.init(reactContext);
        }
    }
    public void startTestWithParams() {
        if (speedTestType != 0) {
            SpeedTestOptions options = new SpeedTestOptions();
            SpeedcheckerSDK.SpeedTest.startTest(reactContext, options);
        } else if (server != null) {
            SpeedcheckerSDK.SpeedTest.startTest(reactContext, server);
        } else {
            SpeedcheckerSDK.SpeedTest.startTest(reactContext);
        }
    }

    @ReactMethod
    public void setLicenseKey(String licenseKey) {
        this.licenseKey = licenseKey;
    }

    @ReactMethod
    public void startTest() {
        SpeedcheckerSDK.SpeedTest.setOnSpeedTestListener(new SpeedTestListener() {
            @Override
            public void onTestStarted() {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Speed test started");
                map.putString("server", "");
                map.putInt("ping", 0);
                map.putInt("jitter", 0);
                map.putDouble("downloadSpeed", 0);
                map.putInt("percent", 0);
                map.putDouble("currentSpeed", 0);
                map.putDouble("uploadSpeed", 0);
                map.putString("connectionType", "");
                map.putString("serverInfo", "");
                map.putString("deviceInfo", "");
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onFetchServerFailed(Integer integer) {

            }

            @Override
            public void onFindingBestServerStarted() {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Finding best server");
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onTestFinished(SpeedTestResult speedTestResult) {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Speed test finished");
                map.putString("server", speedTestResult.getServer().Domain);
                map.putInt("ping", speedTestResult.getPing());
                map.putInt("jitter", speedTestResult.getJitter());
                map.putDouble("downloadSpeed", speedTestResult.getDownloadSpeed());
                map.putDouble("uploadSpeed", speedTestResult.getUploadSpeed());
                map.putString("connectionType", speedTestResult.getConnectionTypeHuman());
                map.putString("serverInfo", speedTestResult.getServerInfo());
                map.putString("deviceInfo", speedTestResult.getDeviceInfo());
                map.putDouble("downloadTransferredMb", speedTestResult.getDownloadTransferredMb());
                map.putDouble("uploadTransferredMb", speedTestResult.getUploadTransferredMb());
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);

            }

            @Override
            public void onPingStarted() {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Ping");
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onPingFinished(int ping, int jitter) {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Ping");
                map.putInt("ping", ping);
                map.putInt("jitter", jitter);
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onDownloadTestStarted() {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Download Test");
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onDownloadTestProgress(int percent, double speedMbs, double transferredMb) {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Download Test");
                map.putInt("percent", percent);
                map.putDouble("currentSpeed", speedMbs);
                map.putDouble("downloadTransferredMb", transferredMb);
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onDownloadTestFinished(double speedMbs) {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Download Test");
                map.putDouble("downloadSpeed", speedMbs);
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onUploadTestStarted() {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Upload Test");
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onUploadTestProgress(int percent, double speedMbs, double transferredMb) {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Upload Test");
                map.putInt("percent", percent);
                map.putDouble("currentSpeed", speedMbs);
                map.putDouble("uploadTransferredMb", transferredMb);
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onUploadTestFinished(double speedMbs) {
                WritableMap map = new WritableNativeMap();
                map.putString("status", "Upload Test");
                map.putDouble("uploadSpeed", speedMbs);
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onTestWarning(String warning) {
                WritableMap map = new WritableNativeMap();
                map.putString("warning", warning);
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }

            @Override
            public void onTestFatalError(String error) {
                WritableMap map = new WritableNativeMap();
                map.putString("error", error);
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);

            }

            @Override
            public void onTestInterrupted(String s) {
                WritableMap map = new WritableNativeMap();
                map.putString("error", s);
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
            }
        });
        startTestWithParams();
    }

    @ReactMethod
    public void startTestWithTestType(int testType) {
        speedTestType = testType;
        startTest();
    }

    @ReactMethod
    public void startTestWithCustomServer(ReadableMap map) {
        server = new Server();
        server.Domain = map.getString("domain");
        server.DownloadFolderPath = map.getString("downloadFolderPath");
        server.Id = map.getInt("id");
        server.Scheme = "https";
        server.Script = "php";
        server.UploadFolderPath = map.getString("uploadFolderPath");
        server.Version = 3;
        server.Location = server.new Location();
        server.Location.City = map.getString("city");
        server.Location.Country = map.getString("country");
        server.Location.CountryCode = map.getString("countryCode");
        startTest();
    }

    @ReactMethod
    public void stopTest() {
        SpeedcheckerSDK.SpeedTest.interruptTest();
    }
}
