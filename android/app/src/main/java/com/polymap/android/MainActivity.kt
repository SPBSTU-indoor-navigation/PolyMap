package com.polymap.android

import android.content.Intent
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.DrawableCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.polymap.android.bottomsheet.BottomSheetContainer
import com.polymap.android.imdf.ImdfDecoder
import com.polymap.android.map.FocusVariant
import com.polymap.android.map.HorizontalSize
import com.polymap.android.map.PolyMapView
import com.polymap.android.map.overlays.Venue
import com.polymap.android.pages.MapInfo
import com.polymap.android.pages.cells.dpi
import com.polymap.android.pages.cells.style
import com.polymap.android.pathfinder.PathFinder
import com.polymap.android.storage.RouteParameters
import com.polymap.android.storage.Storage
import com.polymap.android.timetable.GroupsAndTeacherStorage
import com.polymap.android.timetable.TimetableActivity
import com.polymap.android.ui.Sheets
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.UUID

/** MapViewController + SceneDelegate port. */
class MainActivity : AppCompatActivity() {
    private lateinit var root: FrameLayout
    private lateinit var mapView: PolyMapView
    private lateinit var sheet: BottomSheetContainer
    private lateinit var mapInfo: MapInfo
    private lateinit var timeTableButton: TextView
    private lateinit var timeTableSmallButton: TextView
    private var pendingIntent: Intent? = null
    private var safeBottom = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        val crash = CrashLog.take(this)
        if (crash != null) {
            CrashLog.showScreen(this, crash) { buildUi(savedInstanceState) }
        } else {
            buildUi(savedInstanceState)
        }
    }

    private fun buildUi(savedInstanceState: Bundle?) {
        try {
            setupUi(savedInstanceState)
        } catch (e: Throwable) {
            CrashLog.report(this, "MainActivity.setupUi", e)
            CrashLog.showScreen(this, CrashLog.stack(e)) { }
        }
    }

    private fun setupUi(savedInstanceState: Bundle?) {
        GroupsAndTeacherStorage.init(this)
        root = FrameLayout(this)
        root.setBackgroundColor(ContextCompat.getColor(this, R.color.secondary_system_background))

        val noMap = getSharedPreferences("polymap", MODE_PRIVATE).getBoolean("no_map", false)
        if (!noMap) {
            CrashLog.stage(this, "map.create (PolyMapView / MapLibre MapView)")
            mapView = PolyMapView(this)
            CrashLog.stage(this, "map.onCreate")
            mapView.onCreate(savedInstanceState)
            CrashLog.stage(this, "map.waitStyle (native init / style load)")
            root.addView(mapView, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        } else {
            root.addView(TextView(this).apply {
                text = "Режим без карты (диагностика). Чтобы вернуть карту: закрой приложение из недавних и открой снова, на экране ошибки нажми «Продолжить»."
                style(15f, R.color.label); gravity = Gravity.CENTER; setPadding(dpi(24f), dpi(120f), dpi(24f), 0)
            }, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            CrashLog.stage(this, "ui.noMap")
        }

        // big timetable button (bottom right, shown when the sheet is a full-width phone sheet is NOT big... see onSizeChange)
        timeTableButton = roundButton(R.string.timetable_title, big = true)
        root.addView(timeTableButton, FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.BOTTOM or Gravity.END).apply { marginEnd = dpi(10f); bottomMargin = dpi(10f) })

        // small timetable button (just above the sheet, right aligned; hidden behind the sheet when it is expanded)
        timeTableSmallButton = roundButton(R.string.timetable_title, big = false)
        root.addView(timeTableSmallButton, FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, dpi(35f), Gravity.TOP or Gravity.END).apply { marginEnd = dpi(7f) })

        sheet = BottomSheetContainer(this)
        sheet.dimView.elevation = dpi(5f).toFloat()
        sheet.elevation = dpi(6f).toFloat()
        root.addView(sheet.dimView, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        root.addView(sheet, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))

        mapInfo = MapInfo(this, sheet)
        if (!noMap) {
            mapInfo.mapViewDelegate = mapView
            mapView.mapInfoDelegate = mapInfo
        }
        sheet.delegate = object : BottomSheetContainer.Delegate {
            override fun onSizeChange(from: HorizontalSize?, to: HorizontalSize) {
                timeTableSmallButton.visibility = if (to != HorizontalSize.BIG) View.GONE else View.VISIBLE
                timeTableButton.visibility = if (to == HorizontalSize.BIG) View.GONE else View.VISIBLE
            }
        }
        sheet.onSheetMoved = { positionSmallButton() }

        setContentView(root)

        ViewCompat.setOnApplyWindowInsetsListener(root) { _, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            safeBottom = bars.bottom
            if (hasMap) mapView.post { mapView.setTopInset(bars.top) }
            sheet.safeTop = bars.top
            sheet.safeBottom = bars.bottom
            com.polymap.android.ui.Sheets.navBarBottomPx = bars.bottom
            sheet.imeBottom = (insets.getInsets(WindowInsetsCompat.Type.ime()).bottom - bars.bottom).coerceAtLeast(0)
            (timeTableButton.layoutParams as FrameLayout.LayoutParams).bottomMargin = bars.bottom + dpi(10f)
            timeTableButton.requestLayout()
            root.post { positionSmallButton() }
            insets
        }

        loadIMDF()
        if (savedInstanceState == null) pendingIntent = intent
    }

    private fun roundButton(textRes: Int, big: Boolean): TextView = TextView(this).apply {
        text = getString(textRes)
        style(if (big) 16f else 15f, if (big) R.color.accent else R.color.secondary_label)
        gravity = Gravity.CENTER
        compoundDrawablePadding = dpi(6f)
        val icon = ContextCompat.getDrawable(context, R.drawable.ic_sf_calendar)?.mutate()?.also {
            DrawableCompat.setTint(it, ContextCompat.getColor(context, if (big) R.color.accent else R.color.secondary_label))
            it.setBounds(0, 0, dpi(20f), dpi(20f))
        }
        setCompoundDrawables(icon, null, null, null)
        background = GradientDrawable().apply {
            cornerRadius = dpi(if (big) 22f else 8f).toFloat()
            setColor(ContextCompat.getColor(context, if (big) R.color.chrome_material else R.color.thick_material))
        }
        elevation = dpi(4f).toFloat()
        val ph = dpi(if (big) 14f else 8f); val pv = dpi(if (big) 11f else 0f)
        setPadding(ph, pv, ph, pv)
        isClickable = true; isFocusable = true
        setOnClickListener { openTimetable() }
    }

    /** timeTableSmallButton sits just above the sheet (bottom = sheet top - 7dp), never above the medium position. */
    private fun positionSmallButton() {
        val lp = timeTableSmallButton.layoutParams as FrameLayout.LayoutParams
        val sheetTop = sheet.sheetTop
        val mediumTop = sheet.position(BottomSheetContainer.VerticalSize.MEDIUM)
        val bottom = maxOf(sheetTop, mediumTop) - dpi(7f)
        lp.topMargin = (bottom - dpi(35f)).toInt().coerceAtLeast(0)
        timeTableSmallButton.layoutParams = lp
    }

    private fun loadIMDF() {
        MainScope().launch {
            val venue = withContext(Dispatchers.Default) {
                runCatching { ImdfDecoder.decode(this@MainActivity) }
                    .onFailure { Log.e("PolyMap", "IMDF decode failed", it) }
                    .getOrNull()
            }
            currentVenue = venue
            try {
                if (hasMap) mapView.venue = venue
                mapInfo.searchable = venue?.searchable() ?: emptyList()
                if (!hasMap) CrashLog.clearStage(this@MainActivity)
            } catch (e: Throwable) {
                CrashLog.report(this@MainActivity, "apply venue", e)
                android.widget.Toast.makeText(this@MainActivity, "Ошибка карты: $e", android.widget.Toast.LENGTH_LONG).show()
            }
            val intent = pendingIntent
            pendingIntent = null
            if (intent != null && intent.action == Intent.ACTION_VIEW && intent.data != null) {
                handleUrl(intent.data!!)
            } else {
                helloOpen()
            }
        }
    }

    private fun helloOpen() {
        if (!Storage.contains("firstOpen")) {
            Storage.set("firstOpen", true)
            Sheets.showHello(this)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val url = intent.data ?: return
        if (currentVenue == null) pendingIntent = intent else handleUrl(url)
    }

    /** ParseUserActivity port: /share/route, /share/annotation, /l/<id> */
    private fun handleUrl(url: Uri) {
        val path = url.path ?: return
        when {
            path == "/share/route" -> openRoute(url)
            path == "/share/annotation" -> openAnnotation(url)
            path.length > 4 && path.startsWith("/l/") -> Sheets.showOpenUrl(this, path.substring(3))
        }
    }

    private fun queryItems(url: Uri): Map<String, String> =
        url.queryParameterNames.associate { it.lowercase() to (url.getQueryParameter(it) ?: "").lowercase() }

    private fun parseBool(s: String?): Boolean? = when (s?.lowercase()) { "true" -> true; "false" -> false; else -> null }

    private fun openRoute(url: Uri) {
        val p = queryItems(url)
        val from = p["from"]?.let { runCatching { UUID.fromString(it) }.getOrNull() } ?: return
        val to = p["to"]?.let { runCatching { UUID.fromString(it) }.getOrNull() } ?: return
        val params = RouteParameters(parseBool(p["asphalt"]) ?: false, parseBool(p["serviceroute"]) ?: false)
        val fromA = PathFinder.shared.annotationById[from] ?: return
        val toA = PathFinder.shared.annotationById[to] ?: return
        root.post { MapInfo.routeDetail?.setup(fromA, toA, params) }
    }

    private fun openAnnotation(url: Uri) {
        val p = queryItems(url)
        val id = p["annotation"]?.let { runCatching { UUID.fromString(it) }.getOrNull() } ?: return
        val annotation = PathFinder.shared.annotationById[id] ?: return
        root.post { if (hasMap) mapView.focusAndSelect(annotation, FocusVariant.CENTER) }
    }

    private fun openTimetable() {
        startActivity(Intent(this, TimetableActivity::class.java))
    }

    private val hasMap get() = ::mapView.isInitialized
    override fun onStart() { super.onStart(); if (hasMap) mapView.onStart() }
    override fun onResume() { super.onResume(); if (hasMap) mapView.onResume() }
    override fun onPause() { super.onPause(); if (hasMap) mapView.onPause() }
    override fun onStop() { super.onStop(); if (hasMap) mapView.onStop() }
    override fun onLowMemory() { super.onLowMemory(); if (hasMap) mapView.onLowMemory() }
    override fun onDestroy() { super.onDestroy(); if (hasMap) mapView.onDestroy() }
    override fun onSaveInstanceState(outState: Bundle) { super.onSaveInstanceState(outState); if (hasMap) mapView.onSaveInstanceState(outState) }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        if (::sheet.isInitialized && sheet.pages.size > 1) { mapInfo.pop(true); return }
        @Suppress("DEPRECATION")
        super.onBackPressed()
    }

    companion object {
        var currentVenue: Venue? = null
    }
}
