package com.polymap.android.imdf

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.asin
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.ln
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.tan

/** WGS84 coordinate (latitude/longitude in degrees). Mirrors CLLocationCoordinate2D. */
data class Coord(val lat: Double, val lon: Double) {
    /** Haversine distance in meters (CLLocation.distance analogue). */
    fun distance(other: Coord): Double {
        val r = 6371008.8
        val dLat = Math.toRadians(other.lat - lat)
        val dLon = Math.toRadians(other.lon - lon)
        val a = sin(dLat / 2) * sin(dLat / 2) +
            cos(Math.toRadians(lat)) * cos(Math.toRadians(other.lat)) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * r * asin(min(1.0, sqrt(a)))
    }

    fun toMapPoint(): MapPoint = MapPoint.fromCoord(this)
}

/**
 * Web-mercator point in a normalized [0, WORLD) space — analogue of MKMapPoint.
 * WORLD is chosen so values are close to MKMapPoint scale (2^28).
 */
data class MapPoint(val x: Double, val y: Double) {
    fun distance(other: MapPoint): Double = sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y))

    fun toCoord(): Coord {
        val lon = x / WORLD * 360.0 - 180.0
        val n = PI - 2.0 * PI * y / WORLD
        val lat = Math.toDegrees(atan2(0.5 * (Math.exp(n) - Math.exp(-n)), 1.0))
        return Coord(lat, lon)
    }

    companion object {
        const val WORLD = 268435456.0 // 2^28, like MKMapSize.world.width

        fun fromCoord(c: Coord): MapPoint {
            val x = (c.lon + 180.0) / 360.0 * WORLD
            val latRad = Math.toRadians(c.lat.coerceIn(-85.05112878, 85.05112878))
            val y = (1.0 - ln(tan(latRad) + 1.0 / cos(latRad)) / PI) / 2.0 * WORLD
            return MapPoint(x, y)
        }
    }
}

/** Axis aligned rect in MapPoint space — analogue of MKMapRect. */
data class MapRect(val minX: Double, val minY: Double, val maxX: Double, val maxY: Double) {
    val width get() = maxX - minX
    val height get() = maxY - minY
    val midX get() = (minX + maxX) / 2
    val midY get() = (minY + maxY) / 2
    val isNull get() = minX > maxX || minY > maxY

    fun union(other: MapRect): MapRect {
        if (isNull) return other
        if (other.isNull) return this
        return MapRect(min(minX, other.minX), min(minY, other.minY), max(maxX, other.maxX), max(maxY, other.maxY))
    }

    fun center(): Coord = MapPoint(midX, midY).toCoord()

    companion object {
        val NULL = MapRect(1.0, 1.0, 0.0, 0.0)

        fun of(points: Iterable<MapPoint>): MapRect {
            var minX = Double.MAX_VALUE; var minY = Double.MAX_VALUE
            var maxX = -Double.MAX_VALUE; var maxY = -Double.MAX_VALUE
            var any = false
            for (p in points) {
                any = true
                minX = min(minX, p.x); minY = min(minY, p.y)
                maxX = max(maxX, p.x); maxY = max(maxY, p.y)
            }
            return if (any) MapRect(minX, minY, maxX, maxY) else NULL
        }

        fun ofCoords(coords: Iterable<Coord>): MapRect = of(coords.map { it.toMapPoint() })

        fun point(c: Coord, size: Double = 20.0): MapRect {
            val p = c.toMapPoint()
            return MapRect(p.x, p.y, p.x + size, p.y + size)
        }
    }
}

sealed class Geometry {
    abstract val boundingRect: MapRect

    class Point(val coord: Coord) : Geometry() {
        override val boundingRect by lazy { MapRect.point(coord, 0.0) }
    }

    class LineString(val points: List<Coord>) : Geometry() {
        override val boundingRect by lazy { MapRect.ofCoords(points) }
    }

    class MultiLineString(val lines: List<List<Coord>>) : Geometry() {
        override val boundingRect by lazy { MapRect.ofCoords(lines.flatten()) }
    }

    /** rings[0] is the outer ring, others are holes. */
    class Polygon(val rings: List<List<Coord>>) : Geometry() {
        val outer: List<Coord> get() = rings.firstOrNull() ?: emptyList()
        override val boundingRect by lazy { MapRect.ofCoords(outer) }
        private val outerMapPoints by lazy { outer.map { it.toMapPoint() } }

        /** Ray casting point-in-polygon on the outer ring (holes ignored like the iOS renderer path test). */
        fun contains(c: Coord): Boolean {
            val ring = outer
            if (ring.size < 3) return false
            var inside = false
            var j = ring.size - 1
            for (i in ring.indices) {
                val pi = ring[i]; val pj = ring[j]
                if ((pi.lat > c.lat) != (pj.lat > c.lat) &&
                    c.lon < (pj.lon - pi.lon) * (c.lat - pi.lat) / (pj.lat - pi.lat) + pi.lon
                ) inside = !inside
                j = i
            }
            if (!inside) return false
            // holes
            for (h in 1 until rings.size) {
                if (ringContains(rings[h], c)) return false
            }
            return true
        }

        private fun ringContains(ring: List<Coord>, c: Coord): Boolean {
            if (ring.size < 3) return false
            var inside = false
            var j = ring.size - 1
            for (i in ring.indices) {
                val pi = ring[i]; val pj = ring[j]
                if ((pi.lat > c.lat) != (pj.lat > c.lat) &&
                    c.lon < (pj.lon - pi.lon) * (c.lat - pi.lat) / (pj.lat - pi.lat) + pi.lon
                ) inside = !inside
                j = i
            }
            return inside
        }

        /** Segment p0-p1 intersects any edge of the outer ring (MKPolygon.intersection port). */
        fun intersection(p0: MapPoint, p1: MapPoint): Boolean {
            val pts = outerMapPoints
            if (pts.size <= 2) return false
            if (segIntersect(p0, p1, pts[0], pts[pts.size - 1])) return true
            for (i in 1 until pts.size) if (segIntersect(p0, p1, pts[i - 1], pts[i])) return true
            return false
        }

        val mapPoints: List<MapPoint> get() = outerMapPoints

        private fun segIntersect(p0: MapPoint, p1: MapPoint, p2: MapPoint, p3: MapPoint): Boolean {
            var denominator = (p3.x - p2.x) * (p1.y - p0.y) - (p3.y - p2.y) * (p1.x - p0.x)
            var ua = (p3.y - p2.y) * (p0.x - p2.x) - (p3.x - p2.x) * (p0.y - p2.y)
            var ub = (p1.y - p0.y) * (p0.x - p2.x) - (p1.x - p0.x) * (p0.y - p2.y)
            if (denominator < 0) { ua = -ua; ub = -ub; denominator = -denominator }
            return ua >= 0.0 && ua <= denominator && ub >= 0.0 && ub <= denominator && denominator != 0.0
        }
    }

    class MultiPolygon(val polygons: List<Polygon>) : Geometry() {
        override val boundingRect by lazy { polygons.fold(MapRect.NULL) { r, p -> r.union(p.boundingRect) } }
    }
}

fun Geometry.polygons(): List<Geometry.Polygon> = when (this) {
    is Geometry.Polygon -> listOf(this)
    is Geometry.MultiPolygon -> polygons
    else -> emptyList()
}

fun Geometry.firstPoint(): Coord = when (this) {
    is Geometry.Point -> coord
    is Geometry.LineString -> points.first()
    is Geometry.MultiLineString -> lines.first().first()
    is Geometry.Polygon -> outer.first()
    is Geometry.MultiPolygon -> polygons.first().outer.first()
}

/** Bounding rect of a polygon after rotating its points by [angleRad] around [around]. */
fun boundingAfterRotation(shape: Geometry, angleRad: Double, around: MapPoint? = null): MapRect {
    val polygon = shape.polygons().firstOrNull() ?: return shape.boundingRect
    val points = polygon.mapPoints
    if (points.isEmpty()) return shape.boundingRect
    val sumX = points.sumOf { it.x }; val sumY = points.sumOf { it.y }
    val center = around ?: MapPoint(sumX / points.size, sumY / points.size)
    val c = cos(angleRad); val s = sin(angleRad)
    val rotated = points.map { p ->
        val x = p.x - center.x; val y = p.y - center.y
        MapPoint(center.x + x * c - y * s, center.y + x * s + y * c)
    }
    return MapRect.of(rotated)
}

fun Double.clamp(a: Double, b: Double) = this.coerceIn(min(a, b), max(a, b))
fun Float.clamp(a: Float, b: Float) = this.coerceIn(min(a, b), max(a, b))
fun absDelta(a: Double, b: Double) = abs(a - b)
