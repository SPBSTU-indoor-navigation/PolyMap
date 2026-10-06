package com.polymap.android.map

import android.graphics.PointF
import com.polymap.android.imdf.Coord
import com.polymap.android.imdf.MapPoint
import com.polymap.android.imdf.MapRect
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.ln
import kotlin.math.log2
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.tan

/**
 * Conversions between MapKit-style camera values (altitude/"centerCoordinateDistance", iOS zoom levels)
 * and MapLibre camera values (512px tile zoom).
 *
 *  iOS zoom (as computed by MapView.getZoom on iOS)  = MapLibre zoom + 2
 */
object MapMath {
    private const val EARTH_CIRCUMFERENCE = 40075016.686
    /** MapKit's effective vertical field of view is ~30 degrees. */
    private val TAN_HALF_FOV = tan(Math.toRadians(15.0))

    const val IOS_ZOOM_OFFSET = 2.0

    fun iosZoom(mlZoom: Double): Float = (mlZoom + IOS_ZOOM_OFFSET).toFloat()
    fun mlZoom(iosZoom: Float): Double = iosZoom - IOS_ZOOM_OFFSET

    /** world size in device pixels at a MapLibre zoom */
    fun worldPx(mlZoom: Double, density: Float): Double = 512.0 * 2.0.pow(mlZoom) * density

    fun metersPerPx(mlZoom: Double, lat: Double, density: Float): Double =
        EARTH_CIRCUMFERENCE * cos(Math.toRadians(lat)) / worldPx(mlZoom, density)

    /** MapLibre zoom that shows [distance] meters of camera altitude on a view of [viewHeightPx]. */
    fun zoomForDistance(distance: Double, lat: Double, viewHeightPx: Float, density: Float): Double {
        val visibleMeters = 2.0 * distance * TAN_HALF_FOV
        val scale = EARTH_CIRCUMFERENCE * cos(Math.toRadians(lat)) * viewHeightPx / (512.0 * density * visibleMeters)
        return log2(scale)
    }

    fun distanceForZoom(mlZoom: Double, lat: Double, viewHeightPx: Float, density: Float): Double {
        val visibleMeters = metersPerPx(mlZoom, lat, density) * viewHeightPx
        return visibleMeters / (2.0 * TAN_HALF_FOV)
    }

    /** Rotate a screen vector into world (mercator) direction. bearing in degrees clockwise from north. */
    fun screenToWorldVector(dx: Double, dy: Double, bearingDeg: Double): Pair<Double, Double> {
        val a = Math.toRadians(bearingDeg)
        val c = cos(a); val s = sin(a)
        return Pair(dx * c - dy * s, dx * s + dy * c)
    }

    fun worldToScreenVector(wx: Double, wy: Double, bearingDeg: Double): Pair<Double, Double> {
        val a = Math.toRadians(-bearingDeg)
        val c = cos(a); val s = sin(a)
        return Pair(wx * c - wy * s, wx * s + wy * c)
    }

    /** Coordinate that is [dx],[dy] screen pixels away from [from] at the given camera. */
    fun offsetCoord(from: Coord, dx: Double, dy: Double, mlZoom: Double, bearingDeg: Double, density: Float): Coord {
        val (wx, wy) = screenToWorldVector(dx, dy, bearingDeg)
        val pxPerMapPoint = worldPx(mlZoom, density) / MapPoint.WORLD
        val p = from.toMapPoint()
        return MapPoint(p.x + wx / pxPerMapPoint, p.y + wy / pxPerMapPoint).toCoord()
    }

    /** Screen position of [coord] for a camera centered at [center] (view center at cx, cy). */
    fun project(coord: Coord, center: Coord, mlZoom: Double, bearingDeg: Double, density: Float, cx: Float, cy: Float): PointF {
        val pxPerMapPoint = worldPx(mlZoom, density) / MapPoint.WORLD
        val p = coord.toMapPoint(); val c = center.toMapPoint()
        val wx = (p.x - c.x) * pxPerMapPoint; val wy = (p.y - c.y) * pxPerMapPoint
        val (sx, sy) = worldToScreenVector(wx, wy, bearingDeg)
        return PointF((cx + sx).toFloat(), (cy + sy).toFloat())
    }

    /**
     * MKMapView.setVisibleMapRect(rect, edgePadding:) analogue for a north-up camera:
     * returns (center, mlZoom) that fits [rect] inside the view minus padding.
     */
    fun fitRect(rect: MapRect, viewW: Float, viewH: Float, padL: Float, padT: Float, padR: Float, padB: Float, density: Float): Pair<Coord, Double> {
        val availW = (viewW - padL - padR).coerceAtLeast(1f)
        val availH = (viewH - padT - padB).coerceAtLeast(1f)
        val w = rect.width.coerceAtLeast(1.0); val h = rect.height.coerceAtLeast(1.0)
        val scale = minOf(availW / w, availH / h) // px per map point
        val zoom = log2(scale * MapPoint.WORLD / (512.0 * density))
        // rect center sits at the padded-area center; the true center is offset by the padding asymmetry
        val cxShift = (padR - padL) / 2.0 // screen px, +x right
        val cyShift = (padB - padT) / 2.0
        val center = MapPoint(rect.midX + cxShift / scale, rect.midY + cyShift / scale).toCoord()
        return Pair(center, zoom)
    }
}
