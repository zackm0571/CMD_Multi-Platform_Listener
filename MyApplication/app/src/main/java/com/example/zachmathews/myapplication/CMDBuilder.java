package com.example.zachmathews.myapplication;

import android.os.Build;

/**
 * Created by zachmathews on 8/18/14.
 *
 * Helper class to build CMD url and check if running on Google Glass
 */
public class CMDBuilder {


    public static String buildCMDURL(String baseURL, String cmd, String param){
        return baseURL + "?cmd=" + cmd + "&param=" + param;
    }

    public static boolean isRunningOnGoogleGlass(){
        return  "Google".equalsIgnoreCase(Build.MANUFACTURER) && Build.MODEL.startsWith("Glass");
    }
}
