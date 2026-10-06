package com.polymap.android

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Color
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter

/**
 * Writes uncaught exceptions to files (internal + external app dir) and shows them on the next launch,
 * so crashes can be diagnosed without adb.
 */
object CrashLog {
    private fun file(context: Context) = File(context.filesDir, "last_crash.txt")

    private fun externalFile(context: Context): File? =
        runCatching { context.getExternalFilesDir(null)?.let { File(it, "last_crash.txt") } }.getOrNull()

    fun install(context: Context) {
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, e ->
            write(context, "Thread: ${thread.name}\n${stack(e)}")
            Log.e("PolyMap", "Uncaught exception", e)
            previous?.uncaughtException(thread, e)
        }
    }

    fun stack(e: Throwable): String {
        val sw = StringWriter()
        e.printStackTrace(PrintWriter(sw))
        return sw.toString()
    }

    /** Records a non-fatal error (shown on next launch as well). */
    fun report(context: Context, where: String, e: Throwable) {
        Log.e("PolyMap", where, e)
        write(context, "Non-fatal in $where\n${stack(e)}")
    }

    private fun write(context: Context, text: String) {
        val stamped = "PolyMap ${BuildConfig.VERSION_NAME} / Android ${android.os.Build.VERSION.RELEASE} / ${android.os.Build.MODEL}\n$text"
        runCatching { file(context).writeText(stamped) }
        runCatching { externalFile(context)?.writeText(stamped) }
    }

    fun take(context: Context): String? {
        if (!BuildConfig.CRASH_SCREEN) { runCatching { file(context).delete() }; runCatching { prevStageFile(context).delete() }; return null }
        val header = "PolyMap ${BuildConfig.VERSION_NAME} (${BuildConfig.FLAVOR}, build ${BuildConfig.BUILD_TIME}) / Android ${android.os.Build.VERSION.RELEASE} (API ${android.os.Build.VERSION.SDK_INT}) / ${android.os.Build.MANUFACTURER} ${android.os.Build.MODEL}\n" +
            "abi=${android.os.Build.SUPPORTED_ABIS.joinToString()} textureMode=${prefs(context).getBoolean("map_texture_mode", false)} noMap=${prefs(context).getBoolean("no_map", false)}\n"
        val f = file(context)
        var body: String? = null
        if (f.exists()) {
            body = runCatching { f.readText() }.getOrNull()
            f.delete()
            clearStage(context)
        }
        val prev = prevStageFile(context)
        if (body == null && prev.exists()) {
            val stage = runCatching { prev.readText() }.getOrNull() ?: "?"
            prev.delete()
            body = "Процесс умер без Java-исключения (нативный краш или kill системой) на стадии: $stage\n"
        }
        runCatching { prev.delete() }
        val exit = exitInfoReport(context)
        if (body == null && exit == null) return null
        val text = header + (body ?: "") + "\n" + (exit ?: "ApplicationExitInfo: нет записей о крахе")
        runCatching { externalFile(context)?.writeText(text) }
        return text
    }

    private fun prefs(context: Context) = context.getSharedPreferences("polymap", Context.MODE_PRIVATE)

    /** System-recorded reason of the last process death (Android 11+), incl. the native tombstone strings. */
    private fun exitInfoReport(context: Context): String? {
        if (android.os.Build.VERSION.SDK_INT < 30) return null
        return runCatching {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            val list = am.getHistoricalProcessExitReasons(context.packageName, 0, 5)
            val lastSeen = prefs(context).getLong("last_exit_ts", 0L)
            // real crashes only: background kills by the system (LOW_MEMORY, OTHER/AL_Kill, USER_REQUESTED...) are normal
            val crashReasons = setOf(android.app.ApplicationExitInfo.REASON_CRASH, android.app.ApplicationExitInfo.REASON_CRASH_NATIVE, android.app.ApplicationExitInfo.REASON_ANR, android.app.ApplicationExitInfo.REASON_INITIALIZATION_FAILURE)
            val fresh = list.filter { it.timestamp > lastSeen && (it.reason in crashReasons || (it.reason == android.app.ApplicationExitInfo.REASON_SIGNALED && it.importance <= android.app.ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND)) }
            if (fresh.isEmpty()) return null
            prefs(context).edit().putLong("last_exit_ts", fresh.maxOf { it.timestamp }).apply()
            val sb = StringBuilder("ApplicationExitInfo (последние завершения процесса):\n")
            for (info in fresh) {
                val reason = when (info.reason) {
                    android.app.ApplicationExitInfo.REASON_CRASH -> "CRASH (Java)"
                    android.app.ApplicationExitInfo.REASON_CRASH_NATIVE -> "CRASH_NATIVE"
                    android.app.ApplicationExitInfo.REASON_ANR -> "ANR"
                    android.app.ApplicationExitInfo.REASON_SIGNALED -> "SIGNALED"
                    android.app.ApplicationExitInfo.REASON_LOW_MEMORY -> "LOW_MEMORY"
                    android.app.ApplicationExitInfo.REASON_INITIALIZATION_FAILURE -> "INITIALIZATION_FAILURE"
                    android.app.ApplicationExitInfo.REASON_PERMISSION_CHANGE -> "PERMISSION_CHANGE"
                    android.app.ApplicationExitInfo.REASON_EXCESSIVE_RESOURCE_USAGE -> "EXCESSIVE_RESOURCE_USAGE"
                    android.app.ApplicationExitInfo.REASON_USER_REQUESTED -> "USER_REQUESTED"
                    android.app.ApplicationExitInfo.REASON_USER_STOPPED -> "USER_STOPPED"
                    android.app.ApplicationExitInfo.REASON_DEPENDENCY_DIED -> "DEPENDENCY_DIED"
                    android.app.ApplicationExitInfo.REASON_OTHER -> "OTHER"
                    android.app.ApplicationExitInfo.REASON_EXIT_SELF -> "EXIT_SELF"
                    else -> "reason=${info.reason}"
                }
                sb.append("- ${java.util.Date(info.timestamp)}: $reason status=${info.status} importance=${info.importance} rss=${info.rss / 1024 / 1024}MB\n  desc=${info.description}\n")
                if (info.reason == android.app.ApplicationExitInfo.REASON_CRASH_NATIVE || info.reason == android.app.ApplicationExitInfo.REASON_CRASH || info.reason == android.app.ApplicationExitInfo.REASON_ANR) {
                    runCatching {
                        info.traceInputStream?.use { s ->
                            val bytes = s.readBytes()
                            val strings = extractStrings(bytes)
                            val interesting = strings.filter { t ->
                                t.contains(".so") || t.contains("signal") || t.contains("SIG") || t.contains("abort") || t.contains("fault") ||
                                t.contains("backtrace") || t.startsWith("#") || t.contains("Cause") || t.contains("Abort message") || t.contains("pc ") ||
                                t.contains("at ") || t.contains("Exception") || t.contains("java.") || t.contains("kotlin.")
                            }
                            sb.append("  trace (${bytes.size} bytes), фрагменты:\n")
                            for (t in interesting.take(120)) sb.append("    ").append(t.take(200)).append('\n')
                        }
                    }
                }
            }
            sb.toString()
        }.getOrElse { "ApplicationExitInfo error: $it" }
    }

    private fun extractStrings(bytes: ByteArray, min: Int = 6): List<String> {
        val out = ArrayList<String>()
        val cur = StringBuilder()
        for (b in bytes) {
            val c = b.toInt() and 0xFF
            if (c in 32..126) cur.append(c.toChar()) else { if (cur.length >= min) out += cur.toString(); cur.setLength(0) }
        }
        if (cur.length >= min) out += cur.toString()
        return out
    }

    private fun stageFile(context: Context) = File(context.filesDir, "stage.txt")
    private fun prevStageFile(context: Context) = File(context.filesDir, "prev_stage.txt")

    /** Called first thing in Application.onCreate: moves the stage marker left by a dead process aside. */
    fun preservePreviousStage(context: Context): String? = runCatching {
        val st = stageFile(context)
        if (!st.exists()) return null
        val text = st.readText()
        prevStageFile(context).writeText(text)
        st.delete()
        text
    }.getOrNull()

    /** Marks the current init stage; cleared once the stage completes. */
    fun stage(context: Context, name: String) { runCatching { stageFile(context).writeText(name) } }
    fun clearStage(context: Context) { runCatching { stageFile(context).delete() } }

    /** Full-screen crash report with Copy / Share / Continue / No-map buttons. */
    fun showScreen(activity: Activity, report: String, onContinue: () -> Unit) {
        val d = activity.resources.displayMetrics.density
        val root = LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            setPadding((16 * d).toInt(), (48 * d).toInt(), (16 * d).toInt(), (24 * d).toInt())
        }
        root.addView(TextView(activity).apply {
            text = "Приложение упало при прошлом запуске"
            setTextColor(Color.BLACK)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
        })
        val tv = TextView(activity).apply {
            this.text = report
            setTextColor(Color.DKGRAY)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            setTextIsSelectable(true)
            typeface = android.graphics.Typeface.MONOSPACE
        }
        root.addView(ScrollView(activity).apply { addView(tv) }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        root.addView(TextView(activity).apply {
            text = "Отправь этот текст разработчику: «Поделиться» → Telegram/почта. «Без карты» запускает приложение без MapLibre (для проверки, что падает именно карта)."
            setTextColor(Color.DKGRAY)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            setPadding(0, (8 * d).toInt(), 0, (8 * d).toInt())
        })
        val buttons = LinearLayout(activity).apply { orientation = LinearLayout.HORIZONTAL; gravity = Gravity.END }
        buttons.addView(Button(activity).apply {
            this.text = "Поделиться"
            setOnClickListener {
                val i = android.content.Intent(android.content.Intent.ACTION_SEND).apply { type = "text/plain"; putExtra(android.content.Intent.EXTRA_TEXT, report) }
                runCatching { activity.startActivity(android.content.Intent.createChooser(i, null)) }
            }
        })
        buttons.addView(Button(activity).apply {
            this.text = "Копировать"
            setOnClickListener {
                val cm = activity.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                cm.setPrimaryClip(ClipData.newPlainText("crash", report))
            }
        })
        root.addView(buttons)
        val buttons2 = LinearLayout(activity).apply { orientation = LinearLayout.HORIZONTAL; gravity = Gravity.END }
        buttons2.addView(Button(activity).apply {
            this.text = "Без карты"
            setOnClickListener { prefs(activity).edit().putBoolean("no_map", true).apply(); onContinue() }
        })
        buttons2.addView(Button(activity).apply {
            this.text = "Продолжить"
            setOnClickListener { prefs(activity).edit().putBoolean("no_map", false).apply(); onContinue() }
        })
        root.addView(buttons2)
        activity.setContentView(root)
    }
}
