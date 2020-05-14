package ir.amohseni.sharifonline;

import android.content.Context;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.os.PowerManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterView;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
        PowerManager.WakeLock wakeLock = pm.newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK|PowerManager.ON_AFTER_RELEASE, "my:DoNotSleep");

        //GeneratedPluginRegistrant.registerWith(this);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),"my.method.channel.fortest").setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        if(methodCall.method.equals("turnon")){


                            // this acquires the wake lock
                            if(wakeLock.isHeld()){
                                wakeLock.release();
                                String ggg="False";
                                //String greetings = testok();
                                result.success(ggg);

                            }else  {
                                wakeLock.acquire();
                                String ggg="True";
                                //String greetings = testok();
                                result.success(ggg);
                            }
                        };
                    }

                    private String testok() {
                        return "Test is ok";
                    }
                }
        );

            // Note: this method is invoked on the main thread.
            // TODO
        }
    }
