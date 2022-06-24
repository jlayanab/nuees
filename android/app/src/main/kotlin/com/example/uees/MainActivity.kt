package com.example.uees;

//import android.os.Bundle;
import io.flutter.app.FlutterActivity
//import io.flutter.plugins.GeneratedPluginRegistrant;

class MainActivity: FlutterActivity() {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

  // ...some amount of custom code for your app is here.
}