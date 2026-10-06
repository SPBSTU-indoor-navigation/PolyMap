package com.polymap.android.map

import android.content.Context
import androidx.core.content.ContextCompat
import com.google.gson.JsonObject
import com.polymap.android.R
import com.polymap.android.imdf.Coord
import com.polymap.android.imdf.Geometry
import com.polymap.android.imdf.IMDF
import com.polymap.android.imdf.Restriction
import com.polymap.android.map.overlays.PathOverlay
import com.polymap.android.map.overlays.Venue
import org.maplibre.android.maps.Style
import org.maplibre.android.style.expressions.Expression
import org.maplibre.android.style.expressions.Expression.all
import org.maplibre.android.style.expressions.Expression.eq
import org.maplibre.android.style.expressions.Expression.get
import org.maplibre.android.style.expressions.Expression.literal
import org.maplibre.android.style.expressions.Expression.neq
import org.maplibre.android.style.layers.FillLayer
import org.maplibre.android.style.layers.Layer
import org.maplibre.android.style.layers.LineLayer
import org.maplibre.android.style.layers.Property
import org.maplibre.android.style.layers.PropertyFactory.fillAntialias
import org.maplibre.android.style.layers.PropertyFactory.fillColor
import org.maplibre.android.style.layers.PropertyFactory.fillOutlineColor
import org.maplibre.android.style.layers.PropertyFactory.lineCap
import org.maplibre.android.style.layers.PropertyFactory.lineColor
import org.maplibre.android.style.layers.PropertyFactory.lineJoin
import org.maplibre.android.style.layers.PropertyFactory.lineWidth
import org.maplibre.android.style.sources.GeoJsonSource
import org.maplibre.geojson.Feature
import org.maplibre.geojson.FeatureCollection
import org.maplibre.geojson.LineString
import org.maplibre.geojson.MultiLineString
import org.maplibre.geojson.Point
import org.maplibre.geojson.Polygon

/**
 * Builds the MapLibre sources/layers for the venue (the MapKit overlay renderers port) and exposes
 * switches for the currently shown level / building and the visible route overlays.
 */
class MapStyle(private val context: Context, private val style: Style, venue: Venue) {
    private fun c(res: Int) = ContextCompat.getColor(context, res)

    private val pathSource = GeoJsonSource(SRC_PATH, FeatureCollection.fromFeatures(emptyList()))
    private val layerIds = mutableListOf<String>()

    var currentLevelId: String = NONE
        private set
    private var shownBuildingId: String = NONE
    private var shownBuildingHasLevel = false

    init {
        buildVenue(venue)
        buildEnviroment(venue)
        buildEnviromentDetails(venue)
        // outdoor path (inserted below buildings on iOS)
        style.addSource(pathSource)
        addLayer(
            LineLayer(L_PATH_OUTDOOR, SRC_PATH).withProperties(
                lineColor(c(R.color.system_blue)), lineWidth(7f), lineCap(Property.LINE_CAP_ROUND), lineJoin(Property.LINE_JOIN_BEVEL)
            ).withFilter(eq(get("indoor"), literal(false)))
        )
        buildBuildings(venue)
        buildLevels(venue)
        addLayer(
            LineLayer(L_PATH_INDOOR, SRC_PATH).withProperties(
                lineColor(c(R.color.system_blue)), lineWidth(7f), lineCap(Property.LINE_CAP_ROUND), lineJoin(Property.LINE_JOIN_BEVEL)
            ).withFilter(all(eq(get("indoor"), literal(true)), eq(get("level_id"), literal(currentLevelId))))
        )
    }

    private fun addLayer(layer: Layer) {
        style.addLayer(layer)
        layerIds += layer.id
    }

    // ------------------------------------------------------------------ geojson helpers

    private fun pt(c: Coord): Point = Point.fromLngLat(c.lon, c.lat)
    private fun poly(p: Geometry.Polygon): Polygon = Polygon.fromLngLats(p.rings.map { r -> r.map { pt(it) } })
    private fun line(l: List<Coord>): LineString = LineString.fromLngLats(l.map { pt(it) })
    private fun mline(m: Geometry.MultiLineString): MultiLineString = MultiLineString.fromLineStrings(m.lines.map { line(it) })

    private fun props(vararg pairs: Pair<String, Any?>): JsonObject {
        val o = JsonObject()
        for ((k, v) in pairs) when (v) {
            null -> {}
            is String -> o.addProperty(k, v)
            is Boolean -> o.addProperty(k, v)
            is Number -> o.addProperty(k, v)
            else -> o.addProperty(k, v.toString())
        }
        return o
    }

    // ------------------------------------------------------------------ venue / environment

    private fun buildVenue(venue: Venue) {
        val fc = FeatureCollection.fromFeatures(listOf(Feature.fromGeometry(poly(venue.polygon), props(), venue.id.toString())))
        style.addSource(GeoJsonSource(SRC_VENUE, fc))
        val fill = c(R.color.ios_venuefill)
        addLayer(FillLayer("venue_fill", SRC_VENUE).withProperties(fillColor(fill), fillAntialias(true), fillOutlineColor(fill)))
        addLayer(LineLayer("venue_line", SRC_VENUE).withProperties(lineColor(fill), lineWidth(5f)))
    }

    private fun envColor(cat: IMDF.EnviromentCategory): Int = when (cat) {
        IMDF.EnviromentCategory.ROAD_MAIN -> c(R.color.ios_road_main)
        IMDF.EnviromentCategory.ROAD_DIRT -> c(R.color.ios_road_dirt)
        IMDF.EnviromentCategory.ROAD_PEDESTRIAN_MAIN -> c(R.color.ios_road_pedestrian_main)
        IMDF.EnviromentCategory.ROAD_PEDESTRIAN_SECOND -> c(R.color.ios_road_pedestrian_second)
        IMDF.EnviromentCategory.ROAD_PEDESTRIAN_TREADMILL -> c(R.color.ios_road_pedestrian_treadmill)
        IMDF.EnviromentCategory.GRASS -> c(R.color.ios_grass)
        IMDF.EnviromentCategory.GRASS_STADION -> c(R.color.ios_grass_stadion)
        IMDF.EnviromentCategory.TREE -> c(R.color.ios_tree)
        IMDF.EnviromentCategory.FOREST -> c(R.color.ios_forest)
        IMDF.EnviromentCategory.FENCE_MAIN -> c(R.color.ios_fence_main)
        IMDF.EnviromentCategory.FENCE_SECOND -> c(R.color.ios_default)
        IMDF.EnviromentCategory.SAND -> c(R.color.ios_sand)
        IMDF.EnviromentCategory.WATER -> c(R.color.ios_water)
        IMDF.EnviromentCategory.UNKNOWN -> c(R.color.ios_default)
    }

    private fun buildEnviroment(venue: Venue) {
        val features = venue.enviroments.map { e ->
            Feature.fromGeometry(poly(e.polygon), props("category" to e.category.raw), e.id.toString())
        }
        style.addSource(GeoJsonSource(SRC_ENV, FeatureCollection.fromFeatures(features)))
        val ordered = Venue.ENVIROMENT_ORDER
        for (cat in ordered) {
            val color = envColor(cat)
            addLayer(
                FillLayer("env_${cat.raw}", SRC_ENV)
                    .withProperties(fillColor(color), fillAntialias(true), fillOutlineColor(color))
                    .withFilter(eq(get("category"), literal(cat.raw)))
            )
        }
        val others = IMDF.EnviromentCategory.entries.filter { !ordered.contains(it) }
        val color = c(R.color.ios_default)
        addLayer(
            FillLayer("env_other", SRC_ENV)
                .withProperties(fillColor(color), fillAntialias(true), fillOutlineColor(color))
                .withFilter(Expression.any(*others.map { eq(get("category"), literal(it.raw)) }.toTypedArray()))
        )
    }

    private fun detailColor(cat: IMDF.DetailCategory): Int = when (cat) {
        IMDF.DetailCategory.CROSSWALK -> c(R.color.ios_crosswalk)
        IMDF.DetailCategory.ROAD_MARKING_MAIN -> c(R.color.ios_crosswalk)
        IMDF.DetailCategory.PARKING_MARKING -> c(R.color.ios_crosswalk)
        IMDF.DetailCategory.PARKING_BIG -> c(R.color.ios_crosswalk)
        IMDF.DetailCategory.FENCE_MAIN -> c(R.color.ios_fence_main)
        IMDF.DetailCategory.FENCE_HEIGTH -> c(R.color.ios_fence_heigth)
        IMDF.DetailCategory.STEPS -> c(R.color.ios_steps)
        IMDF.DetailCategory.INDOOR_STEPS -> c(R.color.ios_indoor_steps_fill)
        IMDF.DetailCategory.INDOOR_STAIRS -> c(R.color.ios_indoor_stairs)
        IMDF.DetailCategory.TREADMILL_MARKING -> c(R.color.ios_treadmill_marking)
        IMDF.DetailCategory.STADION_GRASS_MARKING -> c(R.color.ios_stadion_grass_marking)
        IMDF.DetailCategory.UNKNOWN -> c(R.color.ios_crosswalk)
    }

    private fun detailColorExpr(): Expression = Expression.match(
        get("category"), Expression.color(c(R.color.ios_crosswalk)),
        *IMDF.DetailCategory.entries.map { Expression.stop(it.raw, Expression.color(detailColor(it))) }.toTypedArray()
    )

    private fun detailWidthExpr(): Expression = Expression.match(
        get("category"), literal(1f),
        *IMDF.DetailCategory.entries.map { Expression.stop(it.raw, literal(it.lineWidth)) }.toTypedArray()
    )

    private fun buildEnviromentDetails(venue: Venue) {
        val features = venue.enviromentDetail.map { d ->
            Feature.fromGeometry(mline(d.lines), props("category" to d.category.raw), d.id.toString())
        }
        style.addSource(GeoJsonSource(SRC_ENV_DETAIL, FeatureCollection.fromFeatures(features)))
        addLayer(
            LineLayer("envdetail_line", SRC_ENV_DETAIL).withProperties(
                lineColor(detailColorExpr()), lineWidth(detailWidthExpr()), lineCap(Property.LINE_CAP_BUTT), lineJoin(Property.LINE_JOIN_MITER)
            )
        )
    }

    // ------------------------------------------------------------------ buildings & levels

    private fun buildBuildings(venue: Venue) {
        val features = venue.buildings.map { b ->
            Feature.fromGeometry(poly(b.polygon), props("id" to b.id.toString(), "has_levels" to b.levels.isNotEmpty()), b.id.toString())
        }
        style.addSource(GeoJsonSource(SRC_BUILDINGS, FeatureCollection.fromFeatures(features)))
        addLayer(
            FillLayer(L_BUILDINGS_FILL, SRC_BUILDINGS)
                .withProperties(fillColor(c(R.color.ios_buildingfill)), fillAntialias(true), fillOutlineColor(c(R.color.ios_buildingline)))
                .withFilter(neq(get("id"), literal(shownBuildingId)))
        )
        addLayer(
            FillLayer(L_BUILDINGS_SHOWN_FILL, SRC_BUILDINGS)
                .withProperties(fillColor(c(R.color.ios_buildingunderlevel)), fillAntialias(true), fillOutlineColor(c(R.color.ios_buildingunderlevel)))
                .withFilter(eq(get("id"), literal(shownBuildingId)))
        )
        addLayer(
            LineLayer(L_BUILDINGS_LINE, SRC_BUILDINGS)
                .withProperties(lineColor(c(R.color.ios_buildingline)), lineWidth(1f))
                .withFilter(neq(get("id"), literal(shownBuildingId)))
        )
    }

    private fun unitFillExpr(): Expression = Expression.switchCase(
        eq(get("restricted"), literal(true)), Expression.color(c(R.color.ios_restricted_fill)),
        eq(get("restroom"), literal(true)), Expression.color(c(R.color.ios_restroom_fill)),
        Expression.match(
            get("category"), Expression.color(c(R.color.ios_default)),
            Expression.stop("elevator", Expression.color(c(R.color.ios_elevator_fill))),
            Expression.stop("stairs", Expression.color(c(R.color.ios_stairs_fill))),
            Expression.stop("walkway", Expression.color(c(R.color.ios_walkway_fill))),
            Expression.stop("steps", Expression.color(c(R.color.ios_indoor_steps_fill)))
        )
    )

    private fun openingColorExpr(): Expression = Expression.switchCase(
        eq(get("restricted"), literal(true)), Expression.color(c(R.color.ios_restricted_fill)),
        Expression.match(
            get("unit_category"), Expression.color(c(R.color.ios_default)),
            Expression.stop("stairs", Expression.color(c(R.color.ios_stairs_fill))),
            Expression.stop("elevator", Expression.color(c(R.color.ios_elevator_fill))),
            Expression.stop("walkway", Expression.color(c(R.color.ios_walkway_fill))),
            Expression.stop("restroom", Expression.color(c(R.color.ios_restroom_fill))),
            Expression.stop("restroom.female", Expression.color(c(R.color.ios_restroom_fill))),
            Expression.stop("restroom.male", Expression.color(c(R.color.ios_restroom_fill)))
        )
    )

    private fun buildLevels(venue: Venue) {
        val levelFeatures = ArrayList<Feature>()
        val unitFeatures = ArrayList<Feature>()
        val openingFeatures = ArrayList<Feature>()
        val detailFeatures = ArrayList<Feature>()
        for (b in venue.buildings) for (l in b.levels) {
            val lid = l.id.toString()
            levelFeatures += Feature.fromGeometry(poly(l.polygon), props("id" to lid, "building_id" to b.id.toString(), "ordinal" to l.ordinal), lid)
            for (u in l.units) {
                val restricted = u.properties.restriction == Restriction.EMPLOYEES_ONLY || u.properties.restriction == Restriction.RESTRICTED
                unitFeatures += Feature.fromGeometry(
                    poly(u.polygon),
                    props(
                        "id" to u.id.toString(), "level_id" to lid, "category" to u.properties.category.raw,
                        "restricted" to restricted, "restroom" to u.properties.category.isRestroom,
                        "walkway" to (u.properties.category == IMDF.UnitCategory.WALKWAY)
                    ),
                    u.id.toString()
                )
            }
            for (o in l.openings) {
                openingFeatures += Feature.fromGeometry(
                    line(o.line.points),
                    props(
                        "id" to o.id.toString(), "level_id" to lid,
                        "unit_category" to (o.unitCategory?.raw ?: ""),
                        "restricted" to (o.unitRestriction == Restriction.RESTRICTED)
                    ),
                    o.id.toString()
                )
            }
            for (d in l.details) {
                detailFeatures += Feature.fromGeometry(mline(d.lines), props("id" to d.id.toString(), "level_id" to lid, "category" to d.category.raw), d.id.toString())
            }
        }
        style.addSource(GeoJsonSource(SRC_LEVELS, FeatureCollection.fromFeatures(levelFeatures)))
        style.addSource(GeoJsonSource(SRC_UNITS, FeatureCollection.fromFeatures(unitFeatures)))
        style.addSource(GeoJsonSource(SRC_OPENINGS, FeatureCollection.fromFeatures(openingFeatures)))
        style.addSource(GeoJsonSource(SRC_DETAILS, FeatureCollection.fromFeatures(detailFeatures)))

        val levelFilter = eq(get("level_id"), literal(currentLevelId))
        // walkways first, then all other units on top
        addLayer(
            FillLayer(L_UNITS_WALKWAY, SRC_UNITS)
                .withProperties(fillColor(unitFillExpr()), fillAntialias(true))
                .withFilter(all(levelFilter, eq(get("walkway"), literal(true))))
        )
        addLayer(
            FillLayer(L_UNITS_FILL, SRC_UNITS)
                .withProperties(fillColor(unitFillExpr()), fillAntialias(true))
                .withFilter(all(levelFilter, eq(get("walkway"), literal(false))))
        )
        // Unit.configurate(renderer:mapSize:) lineWidth = max(1, iosZoom - 20)  =>  max(1, mlZoom - 18)
        addLayer(
            LineLayer(L_UNITS_LINE, SRC_UNITS)
                .withProperties(
                    lineColor(c(R.color.ios_defaultline)),
                    lineWidth(Expression.interpolate(Expression.linear(), Expression.zoom(), Expression.stop(19f, 1f), Expression.stop(23f, 5f)))
                )
                .withFilter(levelFilter)
        )
        // Opening lineWidth = max(2, (iosZoom - 20) * 1.5) => max(2, (mlZoom - 18) * 1.5)
        addLayer(
            LineLayer(L_OPENINGS, SRC_OPENINGS)
                .withProperties(
                    lineColor(openingColorExpr()),
                    lineCap(Property.LINE_CAP_BUTT),
                    lineWidth(Expression.interpolate(Expression.linear(), Expression.zoom(), Expression.stop(19.333f, 2f), Expression.stop(23f, 7.5f)))
                )
                .withFilter(levelFilter)
        )
        addLayer(
            LineLayer(L_DETAILS, SRC_DETAILS)
                .withProperties(lineColor(detailColorExpr()), lineWidth(detailWidthExpr()), lineCap(Property.LINE_CAP_BUTT))
                .withFilter(levelFilter)
        )
        addLayer(
            LineLayer(L_LEVEL_LINE, SRC_LEVELS)
                .withProperties(lineColor(c(R.color.ios_levelline)), lineWidth(2f))
                .withFilter(eq(get("id"), literal(currentLevelId)))
        )
    }

    // ------------------------------------------------------------------ runtime switches

    fun setCurrentLevel(levelId: String?) {
        currentLevelId = levelId ?: NONE
        val levelFilter = eq(get("level_id"), literal(currentLevelId))
        (style.getLayer(L_UNITS_WALKWAY) as? FillLayer)?.setFilter(all(levelFilter, eq(get("walkway"), literal(true))))
        (style.getLayer(L_UNITS_FILL) as? FillLayer)?.setFilter(all(levelFilter, eq(get("walkway"), literal(false))))
        (style.getLayer(L_UNITS_LINE) as? LineLayer)?.setFilter(levelFilter)
        (style.getLayer(L_OPENINGS) as? LineLayer)?.setFilter(levelFilter)
        (style.getLayer(L_DETAILS) as? LineLayer)?.setFilter(levelFilter)
        (style.getLayer(L_LEVEL_LINE) as? LineLayer)?.setFilter(eq(get("id"), literal(currentLevelId)))
        (style.getLayer(L_PATH_INDOOR) as? LineLayer)?.setFilter(all(eq(get("indoor"), literal(true)), eq(get("level_id"), literal(currentLevelId))))
    }

    fun setShownBuilding(buildingId: String?, hasLevel: Boolean) {
        shownBuildingId = buildingId ?: NONE
        shownBuildingHasLevel = hasLevel
        (style.getLayer(L_BUILDINGS_FILL) as? FillLayer)?.setFilter(neq(get("id"), literal(shownBuildingId)))
        (style.getLayer(L_BUILDINGS_LINE) as? LineLayer)?.setFilter(neq(get("id"), literal(shownBuildingId)))
        (style.getLayer(L_BUILDINGS_SHOWN_FILL) as? FillLayer)?.let {
            it.setFilter(eq(get("id"), literal(shownBuildingId)))
            it.setProperties(fillColor(c(if (hasLevel) R.color.ios_buildingunderlevel else R.color.ios_buildingfill)))
        }
    }

    fun setPaths(paths: Collection<PathOverlay>) {
        val features = paths.filter { it.coordinates.size >= 2 }.map { p ->
            Feature.fromGeometry(
                line(p.coordinates),
                props("indoor" to (p.levelId != null), "level_id" to (p.levelId?.toString() ?: "")),
                p.id.toString()
            )
        }
        pathSource.setGeoJson(FeatureCollection.fromFeatures(features))
    }

    companion object {
        const val NONE = "none"
        const val SRC_VENUE = "pm_venue"
        const val SRC_ENV = "pm_env"
        const val SRC_ENV_DETAIL = "pm_envdetail"
        const val SRC_BUILDINGS = "pm_buildings"
        const val SRC_LEVELS = "pm_levels"
        const val SRC_UNITS = "pm_units"
        const val SRC_OPENINGS = "pm_openings"
        const val SRC_DETAILS = "pm_details"
        const val SRC_PATH = "pm_path"

        const val L_PATH_OUTDOOR = "path_outdoor"
        const val L_PATH_INDOOR = "path_indoor"
        const val L_BUILDINGS_FILL = "buildings_fill"
        const val L_BUILDINGS_SHOWN_FILL = "buildings_shown_fill"
        const val L_BUILDINGS_LINE = "buildings_line"
        const val L_UNITS_WALKWAY = "units_walkway"
        const val L_UNITS_FILL = "units_fill"
        const val L_UNITS_LINE = "units_line"
        const val L_OPENINGS = "openings_line"
        const val L_DETAILS = "details_indoor_line"
        const val L_LEVEL_LINE = "level_line"
    }
}
