package com.polymap.android.map

import android.content.Context
import android.graphics.PointF
import android.graphics.RectF
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import com.polymap.android.imdf.Coord
import com.polymap.android.imdf.MapPoint
import com.polymap.android.imdf.MapRect
import com.polymap.android.imdf.boundingAfterRotation
import com.polymap.android.map.annotations.AmenityAnnotation
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.EnviromentAmenityAnnotation
import com.polymap.android.map.annotations.IndoorAnnotation
import com.polymap.android.map.annotations.OccupantAnnotation
import com.polymap.android.map.annotations.views.BaseAnnotationView
import com.polymap.android.map.overlays.Building
import com.polymap.android.map.overlays.Level
import com.polymap.android.map.overlays.OverlayedMap
import com.polymap.android.map.overlays.PathOverlay
import com.polymap.android.map.overlays.Venue
import com.polymap.android.pathfinder.PathResult
import com.polymap.android.pathfinder.PathResultNode
import org.maplibre.android.camera.CameraPosition
import org.maplibre.android.camera.CameraUpdateFactory
import org.maplibre.android.geometry.LatLng
import org.maplibre.android.geometry.LatLngBounds
import org.maplibre.android.maps.MapLibreMap
import org.maplibre.android.maps.MapLibreMapOptions
import org.maplibre.android.maps.MapView
import org.maplibre.android.maps.Style
import java.util.UUID
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

/**
 * MapView.swift port: MapLibre map + annotation overlay + level switcher, with all the camera/focus logic.
 */
class PolyMapView(context: Context) : FrameLayout(context), OverlayedMap, MapViewDelegate {

    object Constants {
        const val MIN_SHOW_ZOOM = 19.01f   // iOS zoom units
        const val HORIZONTAL_OFFSET = -7f  // dp
        const val MIN_DISTANCE = 100.0
        const val MAX_DISTANCE = 5000.0
    }

    private val density = resources.displayMetrics.density
    private fun dp(v: Float) = v * density

    val mapView: MapView
    lateinit var map: MapLibreMap
        private set
    private var mapReady = false
    private var styleReady = false
    private var mapStyle: MapStyle? = null
    private var pendingVenue: Venue? = null

    val annotationLayer = AnnotationLayer(context)
    private val levelSwitcher = LevelSwitcher(context)

    var mapInfoDelegate: MapInfoDelegate? = null

    var lastZoom: Float = 16f
        private set
    var currentBuilding: Building? = null
        private set

    var venue: Venue? = null
        set(value) {
            field?.hide(this)
            field = value
            pendingVenue = value
            applyVenueIfReady()
        }

    private var zoomByAnimation = false
    private var preventFocus = false
    private var wantSelect: BaseAnnotation? = null
    private var selectedAnnotation: BaseAnnotation? = null
    private val pinnedAnnotations = ArrayList<BaseAnnotation>()
    private val visiblePaths = LinkedHashSet<PathOverlay>()
    private var levelSwitcherShown = false
    private var venueBounds: LatLngBounds? = null

    private val handler = android.os.Handler(android.os.Looper.getMainLooper())

    init {
        val isDark = (resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) ==
            android.content.res.Configuration.UI_MODE_NIGHT_YES
        val options = MapLibreMapOptions.createFromAttributes(context)
            .compassEnabled(true)
            .compassFadesWhenFacingNorth(true)
            .compassGravity(Gravity.TOP or Gravity.END)
            .compassMargins(intArrayOf(0, dp(4f).toInt(), dp(44f + 10f + 7f).toInt(), 0))
            .logoEnabled(false)
            .attributionEnabled(true)
            .attributionGravity(Gravity.BOTTOM or Gravity.START)
            .tiltGesturesEnabled(false)
            .rotateGesturesEnabled(true)
            .textureMode(context.getSharedPreferences("polymap", Context.MODE_PRIVATE).getBoolean("map_texture_mode", true))
        mapView = MapView(context, options)
        addView(mapView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        addView(annotationLayer, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        addView(levelSwitcher, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.TOP or Gravity.END))
        levelSwitcher.translationX = dp(50f)
        levelSwitcher.onChange = { onLevelChange(it) }
        levelSwitcher.onRotate = { onRotate() }
        annotationLayer.onAnnotationAdd = { onAnnotationAdd(it) }


        // pan gesture forwarding for the bottom sheet (OverlayedMapView.onPan)
        mapView.setOnTouchListener(object : OnTouchListener {
            var downY = 0f
            override fun onTouch(v: View, e: MotionEvent): Boolean {
                when (e.actionMasked) {
                    MotionEvent.ACTION_DOWN -> downY = e.y
                    MotionEvent.ACTION_MOVE -> if (e.pointerCount == 1) mapInfoDelegate?.panAction(e.y - downY, e.y)
                }
                return false
            }
        })
    }

    private var topInset = 0

    /** top inset (status bar) for the level switcher */
    fun setTopInset(px: Int) {
        topInset = px
        (levelSwitcher.layoutParams as LayoutParams).topMargin = px
        levelSwitcher.requestLayout()
        if (mapReady) map.uiSettings.setCompassMargins(0, px + dp(4f).toInt(), dp(44f + 10f + 7f).toInt(), 0)
    }

    // ------------------------------------------------------------------ lifecycle passthrough
    fun onCreate(savedInstanceState: Bundle?) {
        mapView.onCreate(savedInstanceState)
        val isDark = (resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) ==
            android.content.res.Configuration.UI_MODE_NIGHT_YES
        val primaryStyle = if (isDark) "https://tiles.openfreemap.org/styles/fiord" else "https://tiles.openfreemap.org/styles/bright"
        val fallbackStyle = "asset://" + (if (isDark) "map_style_dark.json" else "map_style_light.json")
        var fallbackUsed = false
        mapView.addOnDidFailLoadingMapListener { error ->
            Log.w("PolyMap", "style load failed: $error")
            if (!fallbackUsed && mapReady && !styleReady) {
                fallbackUsed = true
                map.setStyle(Style.Builder().fromUri(fallbackStyle)) { onStyleLoaded(it) }
            }
        }
        mapView.getMapAsync { m ->
            map = m
            mapReady = true
            setupMap()
            map.setStyle(Style.Builder().fromUri(primaryStyle)) { onStyleLoaded(it) }
        }
    }

    private fun onStyleLoaded(style: Style) {
        com.polymap.android.CrashLog.clearStage(context)
        // MKMapView.pointOfInterestFilter = .excludingAll analogue: hide POI symbol layers of the base style
        for (layer in style.layers) {
            if (layer.id.startsWith("poi")) layer.setProperties(org.maplibre.android.style.layers.PropertyFactory.visibility(org.maplibre.android.style.layers.Property.NONE))
        }
        styleReady = true
        applyVenueIfReady()
    }
    fun onStart() = mapView.onStart()
    fun onResume() = mapView.onResume()
    fun onPause() = mapView.onPause()
    fun onStop() = mapView.onStop()
    fun onLowMemory() = mapView.onLowMemory()
    fun onDestroy() = mapView.onDestroy()
    fun onSaveInstanceState(outState: Bundle) = mapView.onSaveInstanceState(outState)

    // ------------------------------------------------------------------ setup

    private fun setupMap() {
        map.uiSettings.isTiltGesturesEnabled = false
        map.uiSettings.isCompassEnabled = true
        map.uiSettings.setCompassFadeFacingNorth(true)
        map.uiSettings.setCompassMargins(0, topInset + dp(4f).toInt(), dp(44f + 10f + 7f).toInt(), 0)
        map.addOnCameraMoveListener { onCameraChanged() }
        map.addOnCameraIdleListener { onCameraChanged() }
        map.addOnMapClickListener { latLng ->
            val p = map.projection.toScreenLocation(latLng)
            val hit = annotationLayer.hitTest(p.x, p.y)
            val a = hit?.annotation
            if (a != null) {
                selectAnnotation(a, animated = true, preventFocus = false)
            } else {
                selectedAnnotation?.let { deselectAnnotation(it, true) }
            }
            true
        }
        updateZoomLimits()
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        if (mapReady) updateZoomLimits()
    }

    private fun updateZoomLimits() {
        val h = height.takeIf { it > 0 } ?: return
        val lat = venue?.boundingRect?.center()?.lat ?: 60.0
        map.setMinZoomPreference(MapMath.zoomForDistance(Constants.MAX_DISTANCE, lat, h.toFloat(), density))
        map.setMaxZoomPreference(MapMath.zoomForDistance(Constants.MIN_DISTANCE, lat, h.toFloat(), density))
    }

    private fun applyVenueIfReady() {
        val v = pendingVenue ?: return
        if (!mapReady || !styleReady || width == 0) {
            if (width == 0) post { applyVenueIfReady() }
            return
        }
        pendingVenue = null
        val style = map.style ?: return
        try {
            mapStyle = MapStyle(context, style, v)
        } catch (e: Throwable) {
            com.polymap.android.CrashLog.report(context, "MapStyle", e)
        }
        visiblePaths.clear()
        try {
            v.show(this)
        } catch (e: Throwable) {
            com.polymap.android.CrashLog.report(context, "Venue.show", e)
        }

        val rect = v.boundingRect
        val bounds = LatLngBounds.from(
            MapPoint(rect.minX, rect.minY).toCoord().lat, MapPoint(rect.maxX, rect.maxY).toCoord().lon,
            MapPoint(rect.maxX, rect.maxY).toCoord().lat, MapPoint(rect.minX, rect.minY).toCoord().lon
        )
        venueBounds = bounds
        updateZoomLimits()
        val pad = dp(20f).toInt()
        map.getCameraForLatLngBounds(bounds, intArrayOf(pad, pad, pad, pad))?.let { map.moveCamera(CameraUpdateFactory.newCameraPosition(it)) }
        map.setLatLngBoundsForCameraTarget(bounds)
        onCameraChanged()
    }

    // ------------------------------------------------------------------ camera tracking

    fun getZoom(): Float = if (mapReady) MapMath.iosZoom(map.cameraPosition.zoom) else lastZoom

    private fun viewCenterCoord(): Coord = coordAt(width / 2f, height / 2f)

    private fun coordAt(x: Float, y: Float): Coord {
        val ll = map.projection.fromScreenLocation(PointF(x, y))
        return Coord(ll.latitude, ll.longitude)
    }

    private fun screenPoint(c: Coord): PointF = map.projection.toScreenLocation(LatLng(c.lat, c.lon))

    private var cameraErrorReported = false

    private fun onCameraChanged() {
        if (!mapReady || !styleReady || venue == null) return
        try {
            val zoom = getZoom()
            updateMap(viewCenterCoord(), zoom)
            updateMap(zoom)
            annotationLayer.updatePositions { c -> screenPoint(c) }
        } catch (e: Throwable) {
            if (!cameraErrorReported) { cameraErrorReported = true; com.polymap.android.CrashLog.report(context, "onCameraChanged", e) }
        }
    }

    /** MapView.updateMap(zoomLevel:) */
    private fun updateMap(zoomLevel: Float) {
        if (abs(lastZoom - zoomLevel) < 0.001f) return
        mapInfoDelegate?.zoomMap(zoomLevel, zoomByAnimation)
        lastZoom = zoomLevel

        currentBuilding?.let { b ->
            if (zoomLevel > Constants.MIN_SHOW_ZOOM) {
                b.show(this)
                showLevelSwitcher(b)
            } else {
                b.hide(this)
                hideLevelSwitcher()
            }
        }
        annotationLayer.forEachView { it.update(zoomLevel, true) }
    }

    /** MapView.updateMap(nearestBuilding:zoomLevel:) */
    private fun updateMap(nearestBuilding: Building?, zoomLevel: Float) {
        if (currentBuilding !== nearestBuilding) {
            currentBuilding?.hide(this)
            if (nearestBuilding != null) {
                if (zoomLevel > Constants.MIN_SHOW_ZOOM) {
                    nearestBuilding.show(this)
                    showLevelSwitcher(nearestBuilding)
                }
            } else {
                hideLevelSwitcher()
            }
            currentBuilding = nearestBuilding
        }
    }

    private fun updateMap(centerPosition: Coord, zoomLevel: Float) {
        val nearest = nearestBuilding(centerPosition)
        if (nearest !== currentBuilding) updateMap(nearest, zoomLevel)
    }

    /** MapView.nearestBuilding(position:) port */
    private fun nearestBuilding(position: Coord): Building? {
        val venue = venue ?: return null
        val buildings = venue.buildings.filter { it.levels.isNotEmpty() }
        val centerPoint = position.toMapPoint()

        for (b in buildings) for (polygon in b.polygons) if (polygon.contains(position)) return b

        val w = width.toFloat(); val h = height.toFloat()
        val topLeft = coordAt(0f, 0f)
        val maxDistance = topLeft.toMapPoint().distance(centerPoint)
        var nearest: Building? = null
        var nearestDistance = maxDistance
        for (b in buildings) for (polygon in b.polygons) {
            val pts = polygon.mapPoints
            for (i in pts.indices) {
                val d = pts[i].distance(centerPoint)
                if (d < nearestDistance) {
                    val sp = screenPoint(polygon.outer[i])
                    if (sp.x >= 0 && sp.y >= 0 && sp.x <= w && sp.y <= h) {
                        nearestDistance = d
                        nearest = b
                    }
                }
            }
        }
        if (nearest != null) return nearest

        val inset = dp(50f)
        val minX = inset; val minY = inset; val maxX = w - inset; val maxY = h - inset
        val corners = listOf(PointF(minX, maxY), PointF(maxX, maxY), PointF(minX, minY), PointF(maxX, minY))
        for (corner in corners) {
            val point = coordAt(corner.x, corner.y)
            for (b in buildings) for (polygon in b.polygons) if (polygon.contains(point)) return b
        }

        val midX = (minX + maxX) / 2; val midY = (minY + maxY) / 2
        val vertical = coordAt(midX, maxY).toMapPoint() to coordAt(midX, minY).toMapPoint()
        val horizontal = coordAt(minX, midY).toMapPoint() to coordAt(maxX, midY).toMapPoint()
        val diag1 = coordAt(minX, minY).toMapPoint() to coordAt(maxX, maxY).toMapPoint()
        val diag2 = coordAt(minX, maxY).toMapPoint() to coordAt(maxX, minY).toMapPoint()
        for (b in buildings) for (polygon in b.polygons) {
            if (polygon.intersection(vertical.first, vertical.second)) return b
            if (polygon.intersection(horizontal.first, horizontal.second)) return b
            if (polygon.intersection(diag1.first, diag1.second)) return b
            if (polygon.intersection(diag2.first, diag2.second)) return b
        }
        return nearest
    }

    // ------------------------------------------------------------------ level switcher

    private fun onLevelChange(ordinal: Int) {
        currentBuilding?.changeOrdinal(ordinal, this)
    }

    private fun onRotate() {
        val rotation = currentBuilding?.rotation ?: return
        if (abs(map.cameraPosition.bearing - rotation) > 0.1) {
            val cam = CameraPosition.Builder(map.cameraPosition).bearing(rotation).build()
            map.easeCamera(CameraUpdateFactory.newCameraPosition(cam), 300)
        }
    }

    private fun showLevelSwitcher(building: Building) {
        levelSwitcher.updateLevels(building.levels.associate { it.ordinal to (it.shortName?.bestLocalizedValue ?: "-") }, building.ordinal)
        updateLevelSwitcher(Constants.HORIZONTAL_OFFSET)
    }

    private fun hideLevelSwitcher() = updateLevelSwitcher(50f)

    private fun updateLevelSwitcher(posDp: Float) {
        val shown = posDp < 0
        if (levelSwitcherShown == shown && levelSwitcher.translationX == dp(posDp)) return
        levelSwitcherShown = shown
        levelSwitcher.animate().translationX(dp(posDp)).setDuration(150).start()
    }

    // ------------------------------------------------------------------ OverlayedMap (overlay host)

    override fun showLevel(level: Level) {
        mapStyle?.setCurrentLevel(level.id.toString())
    }

    override fun hideLevel(level: Level) {
        // Building.changeOrdinal shows the new level first and hides the old one afterwards:
        // only clear the level filter when the level being hidden is still the current one.
        val ms = mapStyle ?: return
        if (ms.currentLevelId == level.id.toString()) ms.setCurrentLevel(null)
    }

    override fun setBuildingShown(building: Building, shown: Boolean) {
        mapStyle?.setShownBuilding(if (shown) building.id.toString() else null, building.currentLevel != null)
    }

    override fun addAnnotations(annotations: List<BaseAnnotation>) {
        val zoom = getZoom()
        for (a in annotations) {
            annotationLayer.add(a, pinnedAnnotations.any { it === a }, zoom)
        }
    }

    override fun removeAnnotations(annotations: List<BaseAnnotation>) {
        for (a in annotations) {
            if (selectedAnnotation === a) {
                selectedAnnotation = null
                mapInfoDelegate?.mkDidDeselect(a)
            }
            annotationLayer.remove(a)
        }
    }

    override fun addPathOverlays(overlays: List<PathOverlay>) {
        visiblePaths.addAll(overlays)
        mapStyle?.setPaths(visiblePaths)
    }

    override fun removePathOverlays(overlays: List<PathOverlay>) {
        visiblePaths.removeAll(overlays.toSet())
        mapStyle?.setPaths(visiblePaths)
    }

    private fun onAnnotationAdd(annotation: BaseAnnotation) {
        if (annotation === wantSelect) selectAnnotation(annotation, animated = true, preventFocus = true)
    }

    // ------------------------------------------------------------------ selection

    fun selectAnnotation(annotation: BaseAnnotation, animated: Boolean, preventFocus: Boolean) {
        this.preventFocus = preventFocus
        val view = annotationLayer.viewFor(annotation) ?: return
        val old = selectedAnnotation
        if (old != null && old !== annotation) {
            annotationLayer.viewFor(old)?.let { ov ->
                ov.setSelected(false, animated)
                annotationLayer.reorder(ov)
            }
            selectedAnnotation = null
            handler.post { mapInfoDelegate?.mkDidDeselect(old) }
        }
        if (old === annotation) {
            // already selected: still notify like MKMapView does on re-select
        } else {
            selectedAnnotation = annotation
            view.setSelected(true, animated)
            annotationLayer.reorder(view)
        }
        // MKMapViewDelegate.mapView(_:didSelect:)
        wantSelect = null
        mapInfoDelegate?.mkDidSelect(annotation)
        if (this.preventFocus) {
            this.preventFocus = false
        } else {
            mapFocusSafeArea(annotation.coordinate, view.boundingBox(), null)
        }
    }

    override fun deselectAnnotation(annotation: BaseAnnotation?, animated: Boolean) {
        val a = annotation ?: return
        if (selectedAnnotation !== a) return
        selectedAnnotation = null
        annotationLayer.viewFor(a)?.let { v ->
            v.setSelected(false, animated)
            annotationLayer.reorder(v)
        }
        mapInfoDelegate?.mkDidDeselect(a)
    }

    private fun selectAnnotationAfterAdding(annotation: BaseAnnotation) {
        if (annotationLayer.contains(annotation)) {
            selectAnnotation(annotation, animated = true, preventFocus = true)
        } else {
            wantSelect = annotation
        }
    }

    override fun pinAnnotation(annotation: BaseAnnotation, animated: Boolean) {
        if (pinnedAnnotations.none { it === annotation }) {
            pinnedAnnotations += annotation
            annotationLayer.viewFor(annotation)?.let { it.setPinned(true, animated); annotationLayer.reorder(it) }
        }
    }

    override fun unpinAnnotation(annotation: BaseAnnotation, animated: Boolean) {
        if (pinnedAnnotations.any { it === annotation }) {
            pinnedAnnotations.removeAll { it === annotation }
            annotationLayer.viewFor(annotation)?.let { it.setPinned(false, animated); annotationLayer.reorder(it) }
        }
    }

    // ------------------------------------------------------------------ focus (camera)

    private fun currentDistance(): Double =
        MapMath.distanceForZoom(map.cameraPosition.zoom, map.cameraPosition.target?.latitude ?: 60.0, height.toFloat(), density)

    private fun safeZone(): RectF = mapInfoDelegate?.getSafeZone() ?: RectF(0f, 0f, width.toFloat(), height.toFloat())

    private fun ease(target: Coord, zoom: Double?, bearing: Double?, durationMs: Int, completion: (() -> Unit)?) {
        val b = CameraPosition.Builder(map.cameraPosition).target(LatLng(target.lat, target.lon))
        zoom?.let { b.zoom(it) }
        bearing?.let { b.bearing(it) }
        map.easeCamera(CameraUpdateFactory.newCameraPosition(b.build()), durationMs, object : MapLibreMap.CancelableCallback {
            override fun onCancel() { completion?.invoke() }
            override fun onFinish() { completion?.invoke() }
        })
    }

    /** MapView.mapFocusCenter port: place [point] at the safe-zone center with the given camera distance. */
    private fun mapFocusCenter(point: Coord, distance: Double, completion: (() -> Unit)?) {
        val cur = currentDistance()
        val shouldUseCam = abs(cur - distance) > 0.1
        val zoom = if (shouldUseCam) MapMath.zoomForDistance(distance, point.lat, height.toFloat(), density) else map.cameraPosition.zoom
        val sz = safeZone()
        val shift = if (mapInfoDelegate?.getHorizontalSize() != HorizontalSize.BIG) height / 20f else 0f
        val dx = width / 2f - sz.centerX()
        val dy = height / 2f - sz.centerY() + shift
        val targetCenter = MapMath.offsetCoord(point, dx.toDouble(), dy.toDouble(), zoom, map.cameraPosition.bearing, density)
        ease(targetCenter, if (shouldUseCam) zoom else null, null, 300, completion)
    }

    /** MapView.mapFocusSafeArea port: pan just enough for the annotation to be inside the safe zone. */
    private fun mapFocusSafeArea(point: Coord, boundingBox: RectF, completion: (() -> Unit)?) {
        val mapSafe = safeZone()
        val centerCG = PointF(width / 2f, height / 2f)
        val annotationCG = screenPoint(point)

        // inset by the annotation bounding box, then by (10, 10, 50, 10)
        val target = RectF(
            mapSafe.left + (-boundingBox.left) + dp(10f),
            mapSafe.top + (-boundingBox.top) + dp(10f),
            mapSafe.right - boundingBox.right - dp(10f),
            mapSafe.bottom - boundingBox.bottom - dp(50f)
        )

        var dx = 0f; var dy = 0f
        if (!target.contains(annotationCG.x, annotationCG.y)) {
            if (annotationCG.y < target.top) dy = annotationCG.y - target.top
            else if (annotationCG.y > target.bottom) dy = annotationCG.y - target.bottom
            if (annotationCG.x < target.left) dx = annotationCG.x - target.left
            else if (annotationCG.x > target.right) dx = annotationCG.x - target.right
            val newCenter = coordAt(centerCG.x + dx, centerCG.y + dy)
            ease(newCenter, null, null, 300, completion)
        } else {
            completion?.invoke()
        }
    }

    override fun focusAndSelect(annotation: BaseAnnotation, focusVariant: FocusVariant): Boolean {
        selectAnnotationAfterAdding(annotation)
        focus(annotation, focusVariant)
        return selectedAnnotation !== annotation
    }

    override fun focus(annotation: BaseAnnotation, focusVariant: FocusVariant) {
        var targetZoom = currentDistance()
        when (annotation) {
            is OccupantAnnotation -> targetZoom = 150.0
            is AmenityAnnotation -> targetZoom = 200.0
            is AttractionAnnotation -> if (targetZoom > 1000 || lastZoom > Constants.MIN_SHOW_ZOOM) targetZoom = 800.0
            is EnviromentAmenityAnnotation -> if (500 < targetZoom || targetZoom < 200) targetZoom = 400.0
        }
        if (annotation is IndoorAnnotation) {
            if (currentBuilding === annotation.building) {
                levelSwitcher.changeLevel(annotation.level.ordinal, true)
            }
            annotation.building.ordinal = annotation.level.ordinal
        }
        zoomByAnimation = true
        val view = annotationLayer.viewFor(annotation)
        val boundingBox = view?.boundingBox() ?: RectF()

        var centering = focusVariant == FocusVariant.CENTER
        if (focusVariant == FocusVariant.AUTO) {
            centering = if (view != null) {
                val p = screenPoint(annotation.coordinate)
                val frame = RectF(p.x + boundingBox.left, p.y + boundingBox.top, p.x + boundingBox.right, p.y + boundingBox.bottom)
                !RectF.intersects(RectF(0f, 0f, width.toFloat(), height.toFloat()), frame)
            } else true
        }
        val done = { zoomByAnimation = false }
        if (centering) mapFocusCenter(annotation.coordinate, targetZoom, done)
        else mapFocusSafeArea(annotation.coordinate, boundingBox, done)
    }

    /** MapView.focus(on attraction:) port: rotate to the building and fit it. */
    override fun focus(attraction: AttractionAnnotation) {
        val rotation = attraction.building.rotation ?: map.cameraPosition.bearing
        val pivot = attraction.coordinate.toMapPoint()
        val bounding = boundingAfterRotation(attraction.building.geometry, -rotation * Math.PI / 180.0, pivot)
        val (pos, zoomFit) = MapMath.fitRect(bounding, width.toFloat(), height.toFloat(), dp(10f), dp(10f), dp(10f), dp(100f), density)
        val posP = pos.toMapPoint()
        val angle = rotation * Math.PI / 180.0
        val c = Math.cos(angle); val s = Math.sin(angle)
        val dX = pivot.x - posP.x; val dY = pivot.y - posP.y
        val center = MapPoint(pivot.x - (dX * c - dY * s), pivot.y - (dX * s + dY * c)).toCoord()
        var zoom = zoomFit
        if (MapMath.distanceForZoom(zoom, center.lat, height.toFloat(), density) > 400) {
            zoom = MapMath.zoomForDistance(400.0, center.lat, height.toFloat(), density)
        }
        zoomByAnimation = true
        ease(center, zoom, rotation, 500) { zoomByAnimation = false }
    }

    /** MapView.focus(on pathResult:) port */
    override fun focus(pathResult: PathResult) {
        val sz = safeZone()
        val w = width.toFloat(); val h = height.toFloat()
        val pathRect = pathResult.mapRect
        var (center, zoom) = MapMath.fitRect(pathRect, w, h, sz.left + dp(50f), sz.top + dp(50f), w - sz.right + dp(50f), h - sz.bottom + dp(50f), density)

        val distance = MapMath.distanceForZoom(zoom, center.lat, h, density)
        if (distance > 500 && pathResult.outdoorDistance < 200 && pathResult.indoorDistance > 50 && pathResult.indoorDistance > pathResult.outdoorDistance) {
            val centerRect = MapPoint(pathRect.midX, pathRect.midY).toCoord()
            // keep the rect center at the same screen position while zooming to 500m
            val centerRectScreen = MapMath.project(centerRect, center, zoom, 0.0, density, w / 2, h / 2)
            val centerMapScreen = PointF(w / 2, h / 2)
            zoom = MapMath.zoomForDistance(500.0, center.lat, h, density)
            val screenDelta = PointF(centerRectScreen.x - centerMapScreen.x, centerRectScreen.y - centerMapScreen.y)
            // new camera centered on centerRect, then shifted so centerRect stays at its screen spot
            center = MapMath.offsetCoord(centerRect, -screenDelta.x.toDouble(), -screenDelta.y.toDouble(), zoom, 0.0, density)

            val annotationCG = MapMath.project(pathResult.from.coordinate, center, zoom, 0.0, density, w / 2, h / 2)
            val target = RectF(sz.left + dp(50f), sz.top + dp(50f), sz.right - dp(50f), sz.bottom - dp(50f))
            var dx = 0f; var dy = 0f
            if (!target.contains(annotationCG.x, annotationCG.y)) {
                if (annotationCG.y < target.top) dy = annotationCG.y - target.top
                else if (annotationCG.y > target.bottom) dy = annotationCG.y - target.bottom
                if (annotationCG.x < target.left) dx = annotationCG.x - target.left
                else if (annotationCG.x > target.right) dx = annotationCG.x - target.right
                center = MapMath.offsetCoord(center, dx.toDouble(), dy.toDouble(), zoom, 0.0, density)
            }
        }

        val cam = map.cameraPosition
        val curTarget = cam.target
        if (curTarget != null && abs(MapMath.distanceForZoom(cam.zoom, curTarget.latitude, h, density) - MapMath.distanceForZoom(zoom, center.lat, h, density)) < 1 &&
            abs(cam.bearing) < 0.1 && Coord(curTarget.latitude, curTarget.longitude).distance(center) < 1
        ) return
        zoomByAnimation = true
        ease(center, zoom, 0.0, 500) { zoomByAnimation = false }
    }

    override fun addPath(path: List<PathResultNode>): UUID = venue?.addPath(this, path) ?: UUID.randomUUID()

    override fun removePath(id: UUID) { venue?.removePath(this, id) }

    fun appearanceDidChange() = annotationLayer.appearanceDidChange()
}
