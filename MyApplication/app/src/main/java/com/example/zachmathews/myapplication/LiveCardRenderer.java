package com.example.zachmathews.myapplication;

import com.google.android.glass.timeline.DirectRenderingCallback;
import com.parse.Parse;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.os.PowerManager;
import android.os.SystemClock;
import android.view.SurfaceHolder;
import android.view.View;

//Class to asynchronously grab remote desktop feed and render it to screen
public class LiveCardRenderer implements DirectRenderingCallback {

    /** The duration, in millisconds, of one frame. */
    private static final long FRAME_TIME_MILLIS = 40;

    /** "Hello world" text size. */
    private static final float TEXT_SIZE = 70f;

    /** Alpha variation per frame. */
    private static final int ALPHA_INCREMENT = 5;

    /** Max alpha value. */
    private static final int MAX_ALPHA = 256;

    private final Paint mPaint;
    private final String mText;

    private int mCenterX;
    private int mCenterY;

    private SurfaceHolder mHolder;
    private boolean mRenderingPaused;

    private RenderThread mRenderThread;

    private Bitmap bmp;

    private PowerManager.WakeLock wakeLock;
    public LiveCardRenderer(Context context) {
        mPaint = new Paint();
        mPaint.setStyle(Paint.Style.FILL);
        mPaint.setColor(Color.WHITE);
        mPaint.setAntiAlias(true);
        mPaint.setTextSize(TEXT_SIZE);
        mPaint.setTextAlign(Paint.Align.CENTER);
        mPaint.setTypeface(Typeface.create("sans-serif-thin", Typeface.NORMAL));
        mPaint.setAlpha(0);

        mText = context.getResources().getString(R.string.hello_world);

        //Initializes Parse
        Parse.initialize(context, "ql1EXOKcWlZuBU0zFHAHASu2n47msNpn2Dtx84AH", "OoEidgV5KgyaIOOg7lk3SzeqQ09ouBlEzKHvEhhH");
        ParseACL defaultACL = new ParseACL();
        defaultACL.setPublicReadAccess(true);
        defaultACL.setPublicWriteAccess(true); //objects created are writable
        ParseACL.setDefaultACL(defaultACL, true);

        //Sets wakelock so screen doesn't shut off while in remote desktop view
        PowerManager pm = (PowerManager)context.getSystemService(Context.POWER_SERVICE);
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "REMOTE_DESKTOP_WAKE");


    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        mCenterX = width / 2;
        mCenterY = height / 2;
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        mHolder = holder;
        mRenderingPaused = false;
        wakeLock.acquire(100);
        updateRenderingState();

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        mHolder = null;
        updateRenderingState();
    }

    @Override
    public void renderingPaused(SurfaceHolder holder, boolean paused) {
        mRenderingPaused = paused;
        updateRenderingState();
    }


    private void updateRenderingState() {
        boolean shouldRender = (mHolder != null) && !mRenderingPaused;
        boolean isRendering = (mRenderThread != null);

        if (shouldRender != isRendering) {
            if (shouldRender) {
                mRenderThread = new RenderThread();
                mRenderThread.start();
            } else {
                mRenderThread.quit();
                mRenderThread = null;
            }
        }
    }

    /**
     * Draws the remote desktop image in the SurfaceHolder's canvas.
     */
    private void draw() {
        Canvas canvas;
        try {
            canvas = mHolder.lockCanvas();
        } catch (Exception e) {
            return;
        }
        if (canvas != null) {
            canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);
            mPaint.setAlpha((mPaint.getAlpha() + ALPHA_INCREMENT) % MAX_ALPHA);
                //If current buffer is not null draw it to the screen
              if(bmp != null) {
                  canvas.drawBitmap(bmp, new Rect(0, 0, bmp.getWidth(), bmp.getHeight()), mHolder.getSurfaceFrame(), null);
                }

               mHolder.unlockCanvasAndPost(canvas);
        }



    }

    /**
     * Redraws the {@link View} in the background.
     * REMOTE DESKTOP STREAM LOGIC
     */
    private class RenderThread extends Thread {
        //Should stop render toggle
        private boolean mShouldRun;

        //Latency tolerance
        private long MAX_LATENCY = 150;

        //Server column constants
        private String SERVER_CLASS_CONST = "Screen";
        private String TIMELONG_SERVER_CONST = "timeLong";
        private String RECIEVED_SERVER_CONST = "recieved";
        private String IMG_SERVER_CONST = "screen";

        public RenderThread() {
            mShouldRun = true;
        }


        private synchronized boolean shouldRun() {
            return mShouldRun;
        }


        public synchronized void quit() {
            mShouldRun = false;
        }

        @Override
        public void run() {
            while (shouldRun()) {
                long frameStart = SystemClock.elapsedRealtime();
                draw();
                long frameLength = SystemClock.elapsedRealtime() - frameStart;

                long sleepTime = FRAME_TIME_MILLIS - frameLength;

                /*************************** REMOTE DESKTOP STREAM LOGIC ***************************/

                //Creates query to retrieve tuple (ParseObject) sorting by oldest created where latency is less than than threshold
                //and has not been marked as viewed
                ParseObject screen = null;
                ParseQuery query = new ParseQuery(SERVER_CLASS_CONST);

                query.addAscendingOrder(TIMELONG_SERVER_CONST);
                query.whereLessThan(TIMELONG_SERVER_CONST, System.currentTimeMillis() - MAX_LATENCY);

                query.whereEqualTo(RECIEVED_SERVER_CONST, false);

                try{
                    screen = query.getFirst();
                } catch (ParseException e) {
                    e.printStackTrace();
                }

                if (screen != null) {
                    //Grabs file from server if not null
                    ParseFile fileObject = (ParseFile) screen.get(IMG_SERVER_CONST);
                    byte[] data;
                    try {
                        //Gets image data as a byte array
                         data = fileObject.getData();

                        //Marks screen as viewed
                         screen.put(RECIEVED_SERVER_CONST, true);
                            if (data != null) {

                                //If data is not null create a Bitmap as a buffer
                                bmp=BitmapFactory.decodeByteArray(data, 0, data.length);

                                //Save changes to tuple (screen)
                                screen.saveInBackground();
                            }
                        } catch (ParseException e) {
                            e.printStackTrace();
                        }
                    }



                if (sleepTime > 0) {
                    SystemClock.sleep(sleepTime);
                }



            }
        }
    }

}
