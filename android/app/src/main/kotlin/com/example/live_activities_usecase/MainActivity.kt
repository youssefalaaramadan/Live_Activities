package com.example.live_activities_usecase

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.live_activities.LiveActivityManagerHolder   // plugin import

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // This line is required
        LiveActivityManagerHolder.instance = CustomLiveActivityManager(this)
    }
}
