package com.speedchecker_react_native_plugin;

import androidx.annotation.NonNull;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.speedchecker.android.sdk.Public.SpeedTestListener;
import com.speedchecker.android.sdk.Public.SpeedTestResult;
import com.speedchecker.android.sdk.SpeedcheckerSDK;

public class SpeedCheckerPlugin extends ReactContextBaseJavaModule {

	private static final String PLUGIN_NAME = "SpeedCheckerPlugin";

	private static ReactApplicationContext reactContext;

	SpeedCheckerPlugin(ReactApplicationContext context) {
		super(context);
		reactContext = context;
	}

	@NonNull
	@Override
	public String getName() {
		return PLUGIN_NAME;
	}

	@Override
	public void initialize() {
		super.initialize();
		SpeedcheckerSDK.init(reactContext);
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
			public void onFetchServerFailed() {

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
	}

	@ReactMethod
	public void startTest() {
		SpeedcheckerSDK.SpeedTest.startTest(reactContext);
	}

	@ReactMethod
	public void stopTest() {
		SpeedcheckerSDK.SpeedTest.interruptTest();
//		WritableMap map = new WritableNativeMap();
//		map.putString("status", "Speed test stopped");
//		reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTestStarted", map);
	}
}
