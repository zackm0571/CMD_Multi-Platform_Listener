package com.example.zachmathews.myapplication;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

public class MyActivity extends Activity {


    private SendCMDTask cmdTask;
    private EditText cmdText, paramText, hostText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if(CMDBuilder.isRunningOnGoogleGlass()){
            this.finish();
        }
        setContentView(R.layout.activity_my);

        cmdText = ((EditText) findViewById(R.id.cmdText));
        paramText = ((EditText) findViewById(R.id.paramText));
        hostText = ((EditText) findViewById(R.id.hostText));


        findViewById(R.id.viewScreenButton).requestFocus();
    }


    public void executeCMD(View v) {
        cmdTask = new SendCMDTask();
        cmdTask.execute();

    }

    public void viewRemoteScreen(View v) {
        /************ EXCLUSIVELY TARGETING GOOGLE GLASS FOR NOW ************/
        //remoteViewTask = new RemoteScreenViewer(this, ((ImageView) findViewById(R.id.imageView)));
        //remoteViewTask.execute();
    }

    //Class to send CMD's to remote server, received and parsed by Mac listener
            class SendCMDTask extends AsyncTask {
                private HttpClient client;
                private HttpResponse response;

                @Override
                protected Object doInBackground(Object[] objects) {
                    client = new DefaultHttpClient();
                    HttpGet get = new HttpGet();
                    URI website = null;

                    try {

                        String cmdURL = CMDBuilder.buildCMDURL(hostText.getText().toString(),
                                cmdText.getText().toString(), paramText.getText().toString());

                        website = new URI(cmdURL);
                        get.setURI(website);
                    } catch (URISyntaxException e) {

                        final URISyntaxException temp_e = e;
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                ((TextView) findViewById(R.id.statusText)).setText("Error: Malformed URL");
                            }
                        });

                    }

                    try {
                        response = client.execute(get);
                    } catch (Exception e) {
                        final Exception temp_e = e;
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                ((TextView) findViewById(R.id.statusText)).setText(temp_e.getMessage());
                            }
                        });
                    }
                    if (response != null) {

                        try {
                            String msg = EntityUtils.toString(response.getEntity());

                            final String status = msg;

                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {

                                    String statusOutput = "Status: " + status;


                                    if (status.length() < 3) {
                                        statusOutput = "Successfully sent command";
                                    }
                                    ((TextView) findViewById(R.id.statusText)).setText(statusOutput);

                                }
                            });
                            Log.v("Response:", msg);
                        } catch (IOException e) {
                        }
                    }

                    return null;
                }
            }


        }


