package com.polymap.android

import android.app.Application
import com.polymap.android.storage.Storage
import org.maplibre.android.MapLibre

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        instance = this
        CrashLog.install(this)
        // The previous run may have died natively (no Java exception): its last stage marker is still on disk.
        // Move it aside before we write our own markers, so MainActivity can show it.
        val stageBefore = CrashLog.preservePreviousStage(this)
        if (stageBefore != null && stageBefore.startsWith("map")) {
            // the previous run died while creating the map: switch the renderer to TextureView mode
            getSharedPreferences("polymap", MODE_PRIVATE).edit().putBoolean("map_texture_mode", true).apply()
        }
        Storage.init(this)
        CrashLog.stage(this, "app.onCreate: MapLibre.getInstance (native lib load)")
        MapLibre.getInstance(this)
        CrashLog.stage(this, "app.onCreate: OkHttp client")
        org.maplibre.android.module.http.HttpRequestUtil.setOkHttpClient(
            okhttp3.OkHttpClient.Builder()
                .addInterceptor { chain -> chain.proceed(chain.request().newBuilder().header("User-Agent", "PolyMap-Android/${BuildConfig.VERSION_NAME}").build()) }
                .build()
        )
        CrashLog.clearStage(this)
    }

    companion object {
        lateinit var instance: App
            private set
    }
}
