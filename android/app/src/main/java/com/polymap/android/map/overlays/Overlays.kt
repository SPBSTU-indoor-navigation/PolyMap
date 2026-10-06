package com.polymap.android.map.overlays

import com.polymap.android.imdf.Coord
import com.polymap.android.imdf.Feature
import com.polymap.android.imdf.Geometry
import com.polymap.android.imdf.IMDF
import com.polymap.android.imdf.MapRect
import com.polymap.android.imdf.polygons
import com.polymap.android.map.annotations.AmenityAnnotation
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.EnviromentAmenityAnnotation
import com.polymap.android.map.annotations.OccupantAnnotation
import com.polymap.android.pathfinder.PathResultNode
import com.polymap.android.pathfinder.isIndoor
import java.util.UUID

/** A polyline drawn for a route segment. levelId == null means outdoor. */
class PathOverlay(val coordinates: List<Coord>, val levelId: UUID?, val buildingId: UUID?) {
    val id: UUID = UUID.randomUUID()
}

/** Abstraction of the MapKit overlay/annotation host (OverlayedMapView analogue). */
interface OverlayedMap {
    fun showLevel(level: Level)
    fun hideLevel(level: Level)
    fun setBuildingShown(building: Building, shown: Boolean)
    fun addAnnotations(annotations: List<BaseAnnotation>)
    fun removeAnnotations(annotations: List<BaseAnnotation>)
    fun addPathOverlays(overlays: List<PathOverlay>)
    fun removePathOverlays(overlays: List<PathOverlay>)
}

abstract class CustomOverlay(val geometry: Geometry, val id: UUID) {
    val boundingRect: MapRect get() = geometry.boundingRect
    val polygons: List<Geometry.Polygon> get() = geometry.polygons()
}

class Unit(
    geometry: Geometry.Polygon,
    id: UUID,
    val displayPoint: Coord?,
    val properties: IMDF.UnitProperties
) : CustomOverlay(geometry, id) {
    val polygon: Geometry.Polygon get() = geometry as Geometry.Polygon
}

class Opening(
    geometry: Geometry.LineString,
    id: UUID,
    val unitCategory: IMDF.UnitCategory?,
    val unitRestriction: com.polymap.android.imdf.Restriction?
) : CustomOverlay(geometry, id) {
    val line: Geometry.LineString get() = geometry as Geometry.LineString
}

class Detail(
    geometry: Geometry.MultiLineString,
    id: UUID,
    val category: IMDF.DetailCategory
) : CustomOverlay(geometry, id) {
    val lines: Geometry.MultiLineString get() = geometry as Geometry.MultiLineString
}

class EnviromentUnit(
    geometry: Geometry.Polygon,
    id: UUID,
    val category: IMDF.EnviromentCategory
) : CustomOverlay(geometry, id) {
    val polygon: Geometry.Polygon get() = geometry as Geometry.Polygon
}

class Level(
    geometry: Geometry.Polygon,
    id: UUID,
    val units: List<Unit>,
    val openings: List<Opening>,
    val properties: IMDF.LevelProperties,
    amenitys: List<Feature<IMDF.AmenityProperties>>,
    val details: List<Detail>,
    occupants: List<Pair<Feature<IMDF.OccupantProperties>, Feature<IMDF.AnchorProperties>>>,
    addresses: Map<UUID, Feature<IMDF.AddressProperties>>
) : CustomOverlay(geometry, id) {
    var isShow = false
        private set
    lateinit var building: Building
    val amenitys: List<AmenityAnnotation>
    val occupants: List<OccupantAnnotation>
    val navPaths = LinkedHashMap<UUID, List<PathOverlay>>()

    val ordinal: Int get() = properties.ordinal
    val shortName get() = properties.shortName
    val polygon: Geometry.Polygon get() = geometry as Geometry.Polygon

    init {
        this.amenitys = amenitys.map { a ->
            AmenityAnnotation(
                coordinate = (a.geometry as Geometry.Point).coord,
                imdfID = a.identifier,
                properties = a.properties,
                detailLevel = a.properties.detailLevel,
                level = this
            )
        }
        this.occupants = occupants.map { (occ, anchor) ->
            OccupantAnnotation(
                coordinate = (anchor.geometry as Geometry.Point).coord,
                imdfID = occ.identifier,
                properties = occ.properties,
                address = anchor.properties.addressId?.let { addresses[it]?.properties },
                level = this
            )
        }
    }

    /** Level.addPath port: split the route into per-level indoor segments and keep the ones on this level. */
    fun addPath(map: OverlayedMap, path: List<PathResultNode>, id: UUID) {
        val splitByLevel = ArrayList<MutableList<PathResultNode>>()
        var currentPath: MutableList<PathResultNode> = if (path[0].isIndoor) mutableListOf(path[0]) else mutableListOf()
        for (i in 1 until path.size) {
            val prev = path[i - 1]; val cur = path[i]
            val goToOutdoor = prev.isIndoor && !cur.isIndoor
            val goToNextBuilding = prev.isIndoor && cur.isIndoor && prev.building !== cur.building
            val goToNextFloor = prev.isIndoor && cur.isIndoor && prev.level?.ordinal != cur.level?.ordinal

            if (currentPath.isNotEmpty() && (goToOutdoor || goToNextBuilding || goToNextFloor)) {
                splitByLevel.add(currentPath)
                currentPath = mutableListOf()
            }
            if (prev.isIndoor && cur.isIndoor) currentPath.add(cur)
            if (!prev.isIndoor && cur.isIndoor) currentPath.add(cur)
        }
        if (currentPath.isNotEmpty()) splitByLevel.add(currentPath)

        val mine = splitByLevel.filter { it.size >= 2 && it[1].level === this }
        val overlays = mine.map { seg -> PathOverlay(seg.map { it.location }, this.id, building.id) }
        navPaths[id] = overlays
        if (isShow) map.addPathOverlays(overlays)
    }

    fun removePath(map: OverlayedMap, id: UUID) {
        val overlays = navPaths.remove(id) ?: return
        if (isShow) map.removePathOverlays(overlays)
    }

    fun show(map: OverlayedMap) {
        if (isShow) return
        isShow = true
        map.showLevel(this)
        map.addAnnotations(occupants)
        map.addAnnotations(amenitys)
        for ((_, paths) in navPaths) map.addPathOverlays(paths)
    }

    fun hide(map: OverlayedMap) {
        if (!isShow) return
        isShow = false
        map.hideLevel(this)
        map.removeAnnotations(occupants)
        map.removeAnnotations(amenitys)
        for ((_, paths) in navPaths) map.removePathOverlays(paths)
    }
}

class Building(
    geometry: Geometry.Polygon,
    id: UUID,
    val levels: List<Level>,
    attractions: List<Feature<IMDF.AttractionProperties>>,
    val properties: IMDF.BuildingProperties
) : CustomOverlay(geometry, id) {
    val attractions: List<AttractionAnnotation>
    var ordinal: Int
    var isShow = false
        private set

    val rotation: Double? get() = properties.rotation
    val polygon: Geometry.Polygon get() = geometry as Geometry.Polygon

    init {
        this.attractions = attractions.map {
            AttractionAnnotation(
                coordinate = (it.geometry as Geometry.Point).coord,
                imdfID = it.identifier,
                properties = it.properties,
                building = this
            )
        }
        ordinal = levels.minOfOrNull { it.ordinal } ?: -1
        levels.forEach { it.building = this }
    }

    fun addPath(map: OverlayedMap, path: List<PathResultNode>, id: UUID) {
        val indoor = path.filter { it.building === this }
        if (indoor.isEmpty()) return
        levels.forEach { it.addPath(map, path, id) }
    }

    fun removePath(map: OverlayedMap, id: UUID) {
        levels.forEach { it.removePath(map, id) }
    }

    fun changeOrdinal(ordinal: Int, map: OverlayedMap) {
        if (this.ordinal == ordinal) return
        if (isShow) {
            val old = level(this.ordinal)
            val new = level(ordinal)
            if (old != null && new != null) {
                new.show(map)
                old.hide(map)
            }
        }
        this.ordinal = ordinal
        if (isShow) map.setBuildingShown(this, true)
    }

    fun show(map: OverlayedMap) {
        if (isShow) return
        isShow = true
        level(ordinal)?.show(map)
        map.setBuildingShown(this, true)
        map.removeAnnotations(attractions)
    }

    fun hide(map: OverlayedMap) {
        if (!isShow) return
        isShow = false
        level(ordinal)?.hide(map)
        map.setBuildingShown(this, false)
        map.addAnnotations(attractions)
    }

    fun level(byOrdinal: Int): Level? = levels.firstOrNull { it.ordinal == byOrdinal }
    val currentLevel: Level? get() = level(ordinal)
}

class Venue(
    geometry: Geometry.Polygon,
    id: UUID,
    val buildings: List<Building>,
    val enviroments: List<EnviromentUnit>,
    val enviromentDetail: List<Detail>,
    val address: Feature<IMDF.AddressProperties>?,
    amenitys: List<Feature<IMDF.EnviromentAmenityProperties>>,
    val properties: IMDF.VenueProperties
) : CustomOverlay(geometry, id) {
    val amenitys: List<EnviromentAmenityAnnotation> = amenitys.map {
        EnviromentAmenityAnnotation(
            coordinate = (it.geometry as Geometry.Point).coord,
            imdfID = it.identifier,
            properties = it.properties,
            detailLevel = it.properties.detailLevel
        )
    }
    val outdoorPath = LinkedHashMap<UUID, List<PathOverlay>>()
    var defaultPathStartPoint: BaseAnnotation? = null
    val polygon: Geometry.Polygon get() = geometry as Geometry.Polygon

    /** Venue.addPath port: outdoor segments (drawn below buildings) + per-building indoor segments. */
    fun addPath(map: OverlayedMap, path: List<PathResultNode>): UUID {
        val id = UUID.randomUUID()
        if (path.size <= 1) return id

        val outdoor = ArrayList<MutableList<PathResultNode>>()
        var temp: MutableList<PathResultNode> = if (path[0].isIndoor) mutableListOf() else mutableListOf(path[0])
        for (i in 1 until path.size - 1) {
            if (path[i - 1].isIndoor && path[i].isIndoor && path[i + 1].isIndoor) {
                if (temp.isNotEmpty()) outdoor.add(temp)
                temp = mutableListOf()
            } else {
                temp.add(path[i])
            }
        }
        if (path.size >= 2) {
            if (!(path[path.size - 2].isIndoor && path[path.size - 1].isIndoor)) {
                temp.add(path[path.size - 1])
                outdoor.add(temp)
            }
        }

        val overlays = outdoor.map { seg -> PathOverlay(seg.map { it.location }, null, null) }
        outdoorPath[id] = overlays
        map.addPathOverlays(overlays)
        buildings.forEach { it.addPath(map, path, id) }
        return id
    }

    fun removePath(map: OverlayedMap, id: UUID) {
        val overlays = outdoorPath.remove(id) ?: return
        map.removePathOverlays(overlays)
        buildings.forEach { it.removePath(map, id) }
    }

    fun show(map: OverlayedMap) {
        map.addAnnotations(amenitys)
        map.addAnnotations(buildings.flatMap { it.attractions })
    }

    fun hide(map: OverlayedMap) {
        map.removeAnnotations(amenitys)
        map.removeAnnotations(buildings.flatMap { it.attractions })
        buildings.forEach { it.hide(map) }
    }

    /** MapViewController.searchable() port */
    fun searchable(): List<com.polymap.android.map.annotations.Searchable> {
        val occupants = buildings.flatMap { b -> b.levels.flatMap { it.occupants } }
        val attraction = buildings.flatMap { it.attractions }
        return occupants + attraction
    }

    companion object {
        /** Draw order of environment categories (Venue.show port). */
        val ENVIROMENT_ORDER = listOf(
            IMDF.EnviromentCategory.FOREST,
            IMDF.EnviromentCategory.GRASS,
            IMDF.EnviromentCategory.GRASS_STADION,
            IMDF.EnviromentCategory.WATER,
            IMDF.EnviromentCategory.SAND,
            IMDF.EnviromentCategory.TREE,
            IMDF.EnviromentCategory.ROAD_DIRT,
            IMDF.EnviromentCategory.ROAD_PEDESTRIAN_SECOND,
            IMDF.EnviromentCategory.ROAD_PEDESTRIAN_MAIN,
            IMDF.EnviromentCategory.ROAD_PEDESTRIAN_TREADMILL,
            IMDF.EnviromentCategory.ROAD_MAIN,
            IMDF.EnviromentCategory.FENCE_MAIN,
            IMDF.EnviromentCategory.FENCE_SECOND
        )
    }
}
