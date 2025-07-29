package com.example.yandexmap

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MapApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setLocale("ru_RU")
        MapKitFactory.setApiKey("901b438e-f0be-4a2e-9219-af2a0683e453")
    }
}
