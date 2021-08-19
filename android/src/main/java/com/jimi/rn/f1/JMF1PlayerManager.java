package com.jimi.rn.f1;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import com.eafy.zjlog.ZJLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.jimi.jmmonitorview.JMGLMonitor;
import com.jimi.jmordercorekit.JMOrderCamera;
import com.jimi.jmordercorekit.JMOrderCoreKit;
import com.jimi.jmordercorekit.JMOrderCoreKitServerListener;
import com.jimi.jmordercorekit.Listener.OnPlayStatusListener;
import com.jimi.jmordercorekit.Listener.OnPlaybackListener;
import com.jimi.jmsmartmediaplayer.Bean.JMMediaPlayInfo;
import com.jimi.jmsmartmediaplayer.Video.JMMediaNetworkPlayer;
import com.jimi.jmsmartmediaplayer.Video.JMMediaNetworkPlayerListener;
import com.jimi.jmsmartutils.device.JMDevice;
import com.jimi.jmsmartutils.system.JMError;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

import static com.jimi.jimivideoplayer.JMVideoStreamPlayerListener.STREAM_VIDEO_STATUS_ERR_URL_GET;
import static com.jimi.jimivideoplayer.JMVideoStreamPlayerListener.STREAM_VIDEO_STATUS_STOP;
import static com.jimi.rn.f1.JMF1JSConstant.kOnStreamPlayerPlayStatus;
import static com.jimi.rn.f1.JMF1JSConstant.kOnStreamPlayerReceiveDeviceData;
import static com.jimi.rn.f1.JMF1JSConstant.kOnStreamPlayerReceiveFrameInfo;

public class JMF1PlayerManager extends ReactContextBaseJavaModule {

    private ReactApplicationContext mContext;
    private JMOrderCamera mJMOrderCamera1 = null;
    private JMGLMonitor displaySurfaceView;

    private BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String name = intent.getAction();
            if (name == "com.jimi.rn.kJMSmartAppEngineExit") {
                new Thread(new Runnable() {
                    public void run() {
                        deInitialize();
                        displaySurfaceView = null;
                        JMF1JMMonitorManager.removeGLMonitor();
                    }
                });
            }
        }
    };

    @Override
    public String getName() {
        return "JMF1PlayerManager";
    }

    public JMF1PlayerManager(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.jimi.rn.kJMSmartAppEngineExit");
        reactContext.registerReceiver(mBroadcastReceiver, intentFilter);

        reactContext.addLifecycleEventListener(mLifecycleEventListener);
    }

    private final LifecycleEventListener mLifecycleEventListener = new LifecycleEventListener() {
        @Override
        public void onHostResume() {
            JMF1JMMonitorManager.setIsResume(true);
        }

        @Override
        public void onHostPause() {
            JMF1JMMonitorManager.setIsResume(false);
        }

        @Override
        public void onHostDestroy() {
            JMF1JMMonitorManager.setIsResume(false);
            if (mContext != null && mBroadcastReceiver != null) {
                mContext.unregisterReceiver(mBroadcastReceiver);
                mBroadcastReceiver = null;
            }
        }
    };

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        return JMF1JSConstant.constantsToExport();
    }

    @ReactMethod
    public void initialize(String key, String secret, String imei, String userId, String serverIp) {
        initOrderCoreKit(key, secret, imei, userId, serverIp);
    }

    @ReactMethod
    public void deInitialize() {
        if (mJMOrderCamera1 != null) {
            mJMOrderCamera1.setMediaNetworkPlayerListener(null);
            mJMOrderCamera1.deattachMonitor();
            mJMOrderCamera1.stop();
            mJMOrderCamera1.release();
            mJMOrderCamera1 = null;
        }
    }

    @ReactMethod
    public void startPlayLive() {
        if (mJMOrderCamera1 != null) {
            Log.e("JMF1PlayerManager", "startPlayLive");
            mJMOrderCamera1.startPlay(new OnPlayStatusListener() {
                @Override
                public void onStatus(boolean success, JMError error) {
                    ZJLog.d("startPlayLive success:");
                    WritableMap event = Arguments.createMap();
                    if (!success) {
                        event.putInt("status", 4);
                        event.putInt("errCode", (int) error.errCode);
                        event.putString("errMsg", error.errMsg);
                        mContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                                .emit(kOnStreamPlayerPlayStatus, event);
                    }
                }
            });
            JMF1JMMonitorManager.setIsResume(true);
        }
    }

    @ReactMethod
    public void stopPlay() {
        if (mJMOrderCamera1 != null) {
            mJMOrderCamera1.stopPlay();
        }
    }

    @ReactMethod
    public void stop() {
        if (mJMOrderCamera1 != null) {
            mJMOrderCamera1.stop();
        }
    }

    //初始化
    @SuppressLint("MissingPermission")
    private void initOrderCoreKit(String key, String secret, String iMei, String userId, String serverIp) {
        Log.e("initOrderCoreKit", "initOrderCoreKit");

        if (JMOrderCoreKit.initialize() == 0) {
            JMOrderCoreKit.configDeveloper(key, secret, userId);
            if (!serverIp.isEmpty()) {
                JMOrderCoreKit.configServer(serverIp);
            }
            JMOrderCoreKit.configUserInfo("A" + JMDevice.getIMEI(mContext));
            JMOrderCoreKit.getSingleton().setServerListener(mJMOrderCoreKitServerListener);
            JMOrderCoreKit.getSingleton().connect();
            if (mJMOrderCamera1 == null) {
                mJMOrderCamera1 = new JMOrderCamera(mContext, iMei, 0);
                displaySurfaceView = JMF1JMMonitorManager.getGLMonitor(mContext);
                mJMOrderCamera1.attachGLMonitor(displaySurfaceView);
            }
            mJMOrderCamera1.setMediaNetworkPlayerListener(new JMMediaNetworkPlayerListener() {
                @Override
                public void didJMMediaNetworkPlayerPlay(JMMediaNetworkPlayer player, int status, JMError error) {
                    ZJLog.d("didJMMediaNetworkPlayerPlay->status:" + status + ",error" + error.errMsg);
                    WritableMap event = Arguments.createMap();
                    if (status <= STREAM_VIDEO_STATUS_STOP) {
                        event.putInt("status", status);
                    } else {
                        event.putInt("status", status);
                        event.putInt("errCode", status);
                        if (status == STREAM_VIDEO_STATUS_ERR_URL_GET) {
                            event.putString("errMsg", error.errMsg);
                        }
                    }
                    mContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit(kOnStreamPlayerPlayStatus, event);
                }

                @Override
                public void didJMMediaNetworkPlayerRecord(JMMediaNetworkPlayer player, int status, String filePath, JMError error) {

                }

                @Override
                public void didJMMediaNetworkPlayerPlayInfo(JMMediaNetworkPlayer player, JMMediaPlayInfo framInfo) {
                    ZJLog.d("didJMMediaNetworkPlayerPlayInfo->JMMediaPlayInfo:" + framInfo.getOnlineCount());
                    WritableMap event = Arguments.createMap();
                    event.putInt("width", framInfo.videoWidth);
                    event.putInt("height", framInfo.videoHeight);
                    event.putInt("videoBps", framInfo.videoBps);
                    event.putInt("audioBPS", framInfo.audioBps);
                    event.putInt("timestamp", (int) framInfo.timestamp);
                    event.putInt("totalFrameCount", framInfo.totalFrameCount);
                    event.putInt("onlineCount", framInfo.onlineCount);
                    mContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit(kOnStreamPlayerReceiveFrameInfo, event);
                }
            });
        }
    }

    private JMOrderCoreKitServerListener mJMOrderCoreKitServerListener = new JMOrderCoreKitServerListener() {

        @Override
        public void didJMOrderCoreKitWithError(JMError error) {
            ZJLog.d("didJMOrderCoreKitWithError->errorCode:" + error.errCode + " ,errStr:" + error.errMsg);
            if (error.errCode != 0) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(mContext, error.errMsg, Toast.LENGTH_SHORT).show();
                    }
                });
            }
        }

        @Override
        public void didJMOrderCoreKitConnectWithStatus(int state) {
            ZJLog.d("didJMOrderCoreKitConnectWithStatus->state:" + state);
            if (state == JM_SERVER_CONNET_STATE_CONNECTED) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        startPlayLive();
                        Toast.makeText(mContext, "Server connected successfully!!!!!!!!!", Toast.LENGTH_SHORT).show();
                    }
                });
            } else if (state >= JM_SERVER_CONNET_STATE_FAILED) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(mContext, "Failed to connect server!", Toast.LENGTH_SHORT).show();
                    }
                });
            }
        }

        @Override
        public void didJMOrderCoreKitReceiveDeviceData(int mode, String imei, final String data) {
            ZJLog.d("didJMOrderCoreKitReceiveDeviceData->data:" + data);
            getCurrentActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(mContext, data, Toast.LENGTH_SHORT).show();
                }
            });
            mContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(kOnStreamPlayerReceiveDeviceData, data);
        }
    };
}
