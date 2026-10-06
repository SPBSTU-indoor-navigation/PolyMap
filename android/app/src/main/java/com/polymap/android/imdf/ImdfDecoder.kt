package com.polymap.android.imdf

import android.content.Context
import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.overlays.Building
import com.polymap.android.map.overlays.Detail
import com.polymap.android.map.overlays.EnviromentUnit
import com.polymap.android.map.overlays.Level
import com.polymap.android.map.overlays.Opening
import com.polymap.android.map.overlays.Unit
import com.polymap.android.map.overlays.Venue
import com.polymap.android.pathfinder.PathFinder
import com.polymap.android.storage.FavoritesStorage
import com.polymap.android.storage.SearchHistoryStorage
import java.io.InputStreamReader
import java.util.UUID

/** Port of IMDFDecoder: reads the IMDF geojson bundle from assets and builds the Venue object graph. */
object ImdfDecoder {
    private const val DIR = "IMDFData"

    fun decode(context: Context): Venue? = decode { name -> context.assets.open("$DIR/$name.geojson") }

    /** Decodes using a custom file opener (used by JVM tests). */
    fun decode(open: (String) -> java.io.InputStream): Venue? {
        val context = open
        val addresses = decodeFeatures(context, "address") { parseAddress(it) }
        val addressesById = addresses.associateBy { it.identifier }

        val venues = decodeFeatures(context, "venue") { parseVenue(it) }
        val imdfBuildings = decodeFeatures(context, "building") { parseBuilding(it) }
        val imdfLevels = decodeFeatures(context, "level") { parseLevel(it) }
        val imdfUnits = decodeFeatures(context, "unit") { parseUnit(it) }
        val imdfOpening = decodeFeatures(context, "opening") { parseOpening(it) }
        val detail = decodeFeatures(context, "detail") { parseDetail(it) }
        val anchor = decodeFeatures(context, "anchor") { parseAnchor(it) }
        val occupant = decodeFeatures(context, "occupant") { parseOccupant(it) }
        val amenitys = decodeFeatures(context, "amenity") { parseAmenity(it) }
        val enviroments = decodeFeatures(context, "enviroment") { parseEnviroment(it) }
        val enviromentAmenitys = decodeFeatures(context, "enviromentAmenity") { parseEnviromentAmenity(it) }
        val attraction = decodeFeatures(context, "attraction") { parseAttraction(it) }
        val navPath = decodeFeatures(context, "navPath") { parseNavPath(it) }
        val navPathAssocieted = decodeFeatures(context, "navPathAssocieted") { parseNavPathAssocieted(it) }

        val venue = venues.firstOrNull() ?: return null

        val anchorById = anchor.associateBy { it.identifier }
        val occupantAnchor = occupant.mapNotNull { occ ->
            anchorById[occ.properties.anchorId]?.let { occ to it }
        }

        val unitsByLevel = imdfUnits.groupBy { it.properties.levelId }
        val openingsByLevel = imdfOpening.groupBy { it.properties.levelId }
        val detailsByLevel = detail.filter { it.properties.levelId != null }.groupBy { it.properties.levelId!! }
        val anchorsByUnit = occupantAnchor.groupBy { it.second.properties.unitId }

        val levelById = LinkedHashMap<UUID, Level>()
        for (level in imdfLevels) {
            val units = unitsByLevel[level.identifier] ?: emptyList()
            val unitIds = units.map { it.identifier }.toHashSet()
            val amenitysFiltred = amenitys.filter { a -> a.properties.unitIds.any { unitIds.contains(it) } }
            val occupants = unitIds.flatMap { anchorsByUnit[it] ?: emptyList() }
            levelById[level.identifier] = Level(
                geometry = level.geometry as? Geometry.Polygon ?: continue,
                id = level.identifier,
                units = units.map { Unit(it.geometry as Geometry.Polygon, it.identifier, it.properties.displayPoint, it.properties) },
                openings = (openingsByLevel[level.identifier] ?: emptyList()).map {
                    Opening(it.geometry as Geometry.LineString, it.identifier, it.properties.unitCategory, it.properties.unitRestriction)
                },
                properties = level.properties,
                amenitys = amenitysFiltred,
                details = (detailsByLevel[level.identifier] ?: emptyList()).map {
                    Detail(it.geometry as Geometry.MultiLineString, it.identifier, it.properties.category)
                },
                occupants = occupants,
                addresses = addressesById
            )
        }

        val buildingById = LinkedHashMap<UUID, Building>()
        for (b in imdfBuildings) {
            buildingById[b.identifier] = Building(
                geometry = b.geometry as? Geometry.Polygon ?: continue,
                id = b.identifier,
                levels = levelById.values.filter { it.properties.buildingIds.contains(b.identifier) },
                attractions = attraction.filter { it.properties.buildingId == b.identifier },
                properties = b.properties
            )
        }

        val result = Venue(
            geometry = venue.geometry as Geometry.Polygon,
            id = venue.identifier,
            buildings = buildingById.values.toList(),
            enviroments = enviroments.map { EnviromentUnit(it.geometry as Geometry.Polygon, it.identifier, it.properties.category) },
            enviromentDetail = detail.filter { it.properties.levelId == null }.map {
                Detail(it.geometry as Geometry.MultiLineString, it.identifier, it.properties.category)
            },
            address = addressesById[venue.properties.addressId],
            amenitys = enviromentAmenitys,
            properties = venue.properties
        )

        val annotationIds = LinkedHashMap<UUID, BaseAnnotation>()
        result.amenitys.forEach { annotationIds[it.imdfID] = it }
        result.buildings.forEach { b -> b.attractions.forEach { annotationIds[it.imdfID] = it } }
        result.buildings.forEach { b -> b.levels.forEach { l -> l.amenitys.forEach { annotationIds[it.imdfID] = it } } }
        result.buildings.forEach { b -> b.levels.forEach { l -> l.occupants.forEach { annotationIds[it.imdfID] = it } } }

        venue.properties.navpathBeginId?.let { result.defaultPathStartPoint = annotationIds[it] }

        PathFinder.shared.setup(navPath, navPathAssocieted, buildingById, levelById, annotationIds)
        FavoritesStorage.shared.setup(annotationIds)
        SearchHistoryStorage.shared.setup(annotationIds)

        return result
    }

    // ---------------------------------------------------------------- parsing helpers

    private fun <P> decodeFeatures(open: (String) -> java.io.InputStream, name: String, props: (JsonObject) -> P): List<Feature<P>> {
        val root = open(name).use { input ->
            JsonParser.parseReader(InputStreamReader(input, Charsets.UTF_8)).asJsonObject
        }
        val features = root.getAsJsonArray("features") ?: JsonArray()
        val result = ArrayList<Feature<P>>(features.size())
        for (el in features) {
            val f = el.asJsonObject
            val id = UUID.fromString(f.get("id").asString)
            val geometry = f.get("geometry")?.takeIf { !it.isJsonNull }?.let { parseGeometry(it.asJsonObject) }
            val propsObj = f.get("properties")?.takeIf { it.isJsonObject }?.asJsonObject ?: JsonObject()
            result += Feature(id, geometry, props(propsObj))
        }
        return result
    }

    fun parseGeometry(g: JsonObject): Geometry? {
        val coords = g.get("coordinates") ?: return null
        return when (g.get("type").asString) {
            "Point" -> Geometry.Point(coord(coords.asJsonArray))
            "LineString" -> Geometry.LineString(coordList(coords.asJsonArray))
            "MultiLineString" -> Geometry.MultiLineString(coords.asJsonArray.map { coordList(it.asJsonArray) })
            "Polygon" -> Geometry.Polygon(coords.asJsonArray.map { coordList(it.asJsonArray) })
            "MultiPolygon" -> Geometry.MultiPolygon(coords.asJsonArray.map { p -> Geometry.Polygon(p.asJsonArray.map { coordList(it.asJsonArray) }) })
            else -> null
        }
    }

    private fun coord(a: JsonArray) = Coord(a[1].asDouble, a[0].asDouble)
    private fun coordList(a: JsonArray) = a.map { coord(it.asJsonArray) }

    private fun JsonObject.str(key: String): String? = get(key)?.takeIf { it.isJsonPrimitive }?.asString
    private fun JsonObject.int(key: String): Int? = get(key)?.takeIf { it.isJsonPrimitive }?.asInt
    private fun JsonObject.dbl(key: String): Double? = get(key)?.takeIf { it.isJsonPrimitive }?.asDouble
    private fun JsonObject.bool(key: String): Boolean = get(key)?.takeIf { it.isJsonPrimitive }?.asBoolean ?: false
    private fun JsonObject.uuid(key: String): UUID? = str(key)?.let { runCatching { UUID.fromString(it) }.getOrNull() }
    private fun JsonObject.obj(key: String): JsonObject? = get(key)?.takeIf { it.isJsonObject }?.asJsonObject
    private fun JsonObject.arr(key: String): JsonArray? = get(key)?.takeIf { it.isJsonArray }?.asJsonArray
    private fun JsonObject.name(key: String): LocalizedName? = obj(key)?.let { parseLocalized(it) }
    private fun JsonObject.uuids(key: String): List<UUID> = arr(key)?.mapNotNull { runCatching { UUID.fromString(it.asString) }.getOrNull() } ?: emptyList()
    private fun JsonObject.point(key: String): Coord? = obj(key)?.arr("coordinates")?.let { coord(it) }

    private fun parseLocalized(o: JsonObject): LocalizedName {
        val map = LinkedHashMap<String, String>()
        for ((k, v) in o.entrySet()) if (v.isJsonPrimitive) map[k] = v.asString
        return LocalizedName(map)
    }

    private fun parseAddress(o: JsonObject) = IMDF.AddressProperties(
        o.str("address"), o.str("unit"), o.str("locality"), o.str("province"), o.str("country"),
        o.str("postal_code"), o.str("postal_code_ext"), o.str("postal_code_vanity")
    )

    private fun parseVenue(o: JsonObject) = IMDF.VenueProperties(
        o.name("name"), o.name("alt_name"), o.str("category") ?: "", o.str("hours"), o.str("phone"), o.str("website"),
        o.uuid("address_id"), o.uuid("navpath_begin_id")
    )

    private fun parseBuilding(o: JsonObject) = IMDF.BuildingProperties(
        o.name("name"), o.name("alt_name"), o.str("category") ?: "", Restriction.from(o.str("restriction")),
        o.uuid("address_id"), o.dbl("rotation"), o.point("display_point")
    )

    private fun parseLevel(o: JsonObject) = IMDF.LevelProperties(
        o.name("name"), o.name("short_name"), o.int("ordinal") ?: 0, o.bool("outdoor"), o.str("category") ?: "",
        Restriction.from(o.str("restriction")), o.uuid("address_id"), o.uuids("building_ids"), o.point("display_point")
    )

    private fun parseUnit(o: JsonObject) = IMDF.UnitProperties(
        o.name("name"), o.name("alt_name"), o.uuid("level_id") ?: UUID(0, 0), IMDF.UnitCategory.from(o.str("category")),
        Restriction.from(o.str("restriction")), o.point("display_point")
    )

    private fun parseOpening(o: JsonObject) = IMDF.OpeningProperties(
        o.name("name"), o.name("alt_name"), o.uuid("level_id") ?: UUID(0, 0), o.str("category"),
        o.str("unit_categoty")?.let { c -> IMDF.UnitCategory.entries.firstOrNull { it.raw == c } },
        Restriction.from(o.str("unit_restriction")),
        o.obj("door")?.let { IMDF.Door(it.str("type"), it.str("material"), it.bool("automatic")) },
        o.point("display_point")
    )

    private fun parseDetail(o: JsonObject) = IMDF.DetailProperties(IMDF.DetailCategory.from(o.str("category")), o.uuid("level_id"))

    private fun parseAnchor(o: JsonObject) = IMDF.AnchorProperties(o.uuid("unit_id") ?: UUID(0, 0), o.uuid("address_id"))

    private fun parseOccupant(o: JsonObject) = IMDF.OccupantProperties(
        o.name("name"), o.name("shortName"), IMDF.OccupantCategory.from(o.str("category")), o.uuid("anchor_id") ?: UUID(0, 0),
        o.str("hours"), o.str("phone"), o.str("email"), o.str("website"), o.uuid("correlation_id")
    )

    private fun parseAmenity(o: JsonObject) = IMDF.AmenityProperties(
        o.name("name"), o.name("alt_name"), o.uuids("unit_ids"), IMDF.AmenityCategory.from(o.str("category")),
        o.int("detailLevel") ?: 0, o.str("hours"), o.str("phone"), o.str("website"), o.uuid("address_id")
    )

    private fun parseEnviroment(o: JsonObject) = IMDF.EnviromentUnitProperties(
        o.name("name"), o.name("alt_name"), IMDF.EnviromentCategory.from(o.str("category")), o.point("display_point")
    )

    private fun parseEnviromentAmenity(o: JsonObject) = IMDF.EnviromentAmenityProperties(
        o.name("name"), o.name("alt_name"), IMDF.EnviromentAmenityCategory.from(o.str("category")), o.int("detailLevel") ?: 0
    )

    private fun parseAttraction(o: JsonObject): IMDF.AttractionProperties {
        val authors = o.obj("authors")?.let { a ->
            val d = a.obj("detail")
            val shortInfo = a.name("short_info")
            if (d != null && shortInfo != null) {
                IMDF.Author(
                    shortInfo,
                    IMDF.AuthorDetail(
                        d.name("title") ?: LocalizedName(emptyMap()),
                        d.name("description") ?: LocalizedName(emptyMap()),
                        d.name("authors_title") ?: LocalizedName(emptyMap()),
                        d.arr("authors")?.map { parseLocalized(it.asJsonObject) } ?: emptyList()
                    )
                )
            } else null
        }
        return IMDF.AttractionProperties(
            o.name("name"), o.name("alt_name"), o.name("short_name"), o.uuid("building_id") ?: UUID(0, 0),
            o.str("category") ?: "building", o.str("image"), authors
        )
    }

    private fun parseNavPath(o: JsonObject) = IMDF.NavPathProperties(
        o.uuid("builing_id"), o.uuid("level_id"), o.uuids("neighbours"), o.dbl("weight")?.toFloat() ?: 1f,
        o.arr("tags")?.mapNotNull { IMDF.NavPathTag.from(it.asString) } ?: emptyList()
    )

    private fun parseNavPathAssocieted(o: JsonObject) = IMDF.NavPathAssocietedProperties(
        o.uuid("pathNode_id") ?: UUID(0, 0), o.uuid("associeted_id") ?: UUID(0, 0)
    )
}
