package com.pranta.health_box

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register custom method channels for battery optimization and settings
        BatteryOptimizationChannel(flutterEngine, this)
        AppSettingsChannel(flutterEngine, this)
    }
}
