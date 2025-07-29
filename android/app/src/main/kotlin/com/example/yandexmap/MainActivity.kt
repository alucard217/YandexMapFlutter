package com.example.yandexmap

import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MapKitFactory.setLocale("ru_RU")
        MapKitFactory.setApiKey("901b438e-f0be-4a2e-9219-af2a0683e453")
        super.configureFlutterEngine(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        MapKitFactory.setApiKey("901b438e-f0be-4a2e-9219-af2a0683e453")
        super.onCreate(savedInstanceState)
    }
}
