package com.reactnative.f1;

import android.content.Context;
import android.widget.FrameLayout;
import android.widget.Toast;

import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.jsx.sdk.JJCarCamera;

/*
 * COPYRIGHT. ShenZhen JiMi Technology Co., Ltd. 2019.
 * ALL RIGHTS RESERVED.
 *
 * No part of this publication may be reproduced, stored in a retrieval system, or transmitted,
 * on any form or by any means, electronic, mechanical, photocopying, recording,
 * or otherwise, without the prior written permission of ShenZhen JiMi Network Technology Co., Ltd.
 *
 * @Description:
 * @Date 2020/2/22
 * @author LeeQiuuu
 * @version 1.0
 */
public class F1VideoManager extends ViewGroupManager<FrameLayout> {
    @Override
    public String getName() {
        return "JMF1VideoView";
    }
    private Context context;
    private ThemedReactContext reactContext;

    public void setContext(Context _context){
        this.context=_context;
    }

    @Override
    protected FrameLayout createViewInstance(ThemedReactContext reactContext) {
        this.reactContext =reactContext;
        return new FrameLayout(reactContext);
    }

    @ReactProp(name = "init")
    public void initVideo(final FrameLayout frameLayout,boolean conn) {
        Toast.makeText(context,"initVideo+++",Toast.LENGTH_LONG).show();
        JJCarCamera.getInstance().connDevice(reactContext.getCurrentActivity(), frameLayout);
    }

    @ReactProp(name = "cachePath")
    public void setFileCachePath(final FrameLayout frameLayout,String path) {
         JJCarCamera.getInstance().setFileFolder(path);
    }

    @ReactProp(name = "start")
    public void start(final FrameLayout frameLayout,boolean start) {
        Toast.makeText(context,"start+++",Toast.LENGTH_LONG).show();
       if (start)
        JJCarCamera.getInstance().startPlay();
        else JJCarCamera.getInstance().stopPlay();
    }
}
