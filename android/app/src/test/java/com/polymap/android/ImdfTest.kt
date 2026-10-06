package com.polymap.android

import com.polymap.android.imdf.Coord
import com.polymap.android.imdf.ImdfDecoder
import com.polymap.android.imdf.LocalizedName
import com.polymap.android.imdf.MapPoint
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.OccupantAnnotation
import com.polymap.android.map.overlays.Building
import com.polymap.android.map.overlays.Level
import com.polymap.android.map.overlays.OverlayedMap
import com.polymap.android.map.overlays.PathOverlay
import com.polymap.android.map.overlays.Venue
import com.polymap.android.pathfinder.PathFinder
import com.polymap.android.pathfinder.isIndoor
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.BeforeClass
import org.junit.Test
import java.io.File
import kotlin.math.abs

/** Decodes the bundled IMDF data on the JVM and exercises the path finder and route splitting. */
class ImdfTest {
    companion object {
        lateinit var venue: Venue

        @BeforeClass
        @JvmStatic
        fun setup() {
            LocalizedName.preferredLanguagesProvider = { listOf("ru-RU") }
            val dir = File("src/main/assets/IMDFData")
            venue = ImdfDecoder.decode { name -> File(dir, "$name.geojson").inputStream() }!!
        }
    }

    private class FakeMap : OverlayedMap {
        val shownLevels = mutableListOf<Level>()
        val annotations = mutableListOf<BaseAnnotation>()
        val paths = mutableListOf<PathOverlay>()
        override fun showLevel(level: Level) { shownLevels += level }
        override fun hideLevel(level: Level) { shownLevels -= level }
        override fun setBuildingShown(building: Building, shown: Boolean) {}
        override fun addAnnotations(annotations: List<BaseAnnotation>) { this.annotations += annotations }
        override fun removeAnnotations(annotations: List<BaseAnnotation>) { this.annotations -= annotations.toSet() }
        override fun addPathOverlays(overlays: List<PathOverlay>) { paths += overlays }
        override fun removePathOverlays(overlays: List<PathOverlay>) { paths -= overlays.toSet() }
    }

    @Test
    fun decodesVenue() {
        assertEquals(81, venue.buildings.size)
        assertEquals(18, venue.buildings.sumOf { it.levels.size })
        assertEquals(1403, venue.buildings.sumOf { b -> b.levels.sumOf { it.units.size } })
        assertEquals(45, venue.amenitys.size)
        assertEquals(682, venue.enviroments.size)
        assertTrue(venue.enviromentDetail.isNotEmpty())
        val occupants = venue.buildings.sumOf { b -> b.levels.sumOf { it.occupants.size } }
        assertTrue("occupants=$occupants", occupants > 900)
        assertNotNull(venue.defaultPathStartPoint)
        assertEquals("Политех", venue.properties.altName?.bestLocalizedValue)
        assertEquals(5119, PathFinder.shared.nodes.size)
    }

    @Test
    fun mercatorRoundTrip() {
        val c = Coord(60.0072, 30.3721)
        val back = MapPoint.fromCoord(c).toCoord()
        assertTrue(abs(back.lat - c.lat) < 1e-9)
        assertTrue(abs(back.lon - c.lon) < 1e-9)
        assertTrue(abs(Coord(60.0, 30.0).distance(Coord(60.0, 30.0018)) - 100.0) < 1.0)
    }

    @Test
    fun buildingContainsItsOccupants() {
        val b = venue.buildings.first { it.levels.isNotEmpty() && it.levels.any { l -> l.occupants.isNotEmpty() } }
        val occ = b.levels.first { it.occupants.isNotEmpty() }.occupants.first()
        assertTrue(b.polygons.any { it.contains(occ.coordinate) })
    }

    @Test
    fun findsRouteBetweenBuildings() {
        val withLevels = venue.buildings.filter { it.levels.any { l -> l.occupants.isNotEmpty() } }
        assertTrue(withLevels.size >= 2)
        val from = withLevels[0].levels.first { it.occupants.isNotEmpty() }.occupants.first()
        val to = withLevels[1].levels.first { it.occupants.isNotEmpty() }.occupants.first()
        val result = PathFinder.shared.findPath(from, to, emptyList())
        assertNotNull(result)
        result!!
        assertTrue("path too short: ${result.path.size}", result.path.size > 5)
        assertTrue(result.totalDistance > 10)
        assertTrue(result.indoorDistance > 0)
        assertTrue(result.outdoorDistance > 0)
        assertTrue(result.time > result.fastTime)

        // route splitting like Venue.addPath / Level.addPath
        val map = FakeMap()
        val id = venue.addPath(map, result.path)
        assertTrue("outdoor overlays", venue.outdoorPath[id]!!.isNotEmpty())
        val indoorSegments = venue.buildings.flatMap { b -> b.levels.flatMap { l -> l.navPaths[id] ?: emptyList() } }
        assertTrue("indoor segments", indoorSegments.isNotEmpty())
        assertTrue(indoorSegments.all { it.levelId != null })
        assertTrue(map.paths.all { it.levelId == null }) // only outdoor visible while levels hidden
        // show the start level: its indoor segments become visible
        from.level.show(map)
        assertTrue(map.paths.any { it.levelId == from.level.id })
        venue.removePath(map, id)
        assertTrue(map.paths.isEmpty())
    }

    @Test
    fun denyTagsChangeRoute() {
        val from = venue.defaultPathStartPoint!!
        val to = venue.buildings.flatMap { it.attractions }.first { it.building.levels.isNotEmpty() && it !== from }
        val a = PathFinder.shared.findPath(from, to, emptyList())!!
        val b = PathFinder.shared.findPath(from, to, listOf(com.polymap.android.imdf.IMDF.NavPathTag.DIRT, com.polymap.android.imdf.IMDF.NavPathTag.SERVICE))!!
        assertTrue(a.path.isNotEmpty() && b.path.isNotEmpty())
        assertTrue(b.totalCost >= a.totalCost - 0.01f)
    }

    @Test
    fun searchableTitlesLocalized() {
        val s = venue.searchable()
        assertTrue(s.size > 900)
        val attraction = s.filterIsInstance<AttractionAnnotation>().first()
        assertNotNull(attraction.mainTitle)
        val occupant = s.filterIsInstance<OccupantAnnotation>().first()
        assertNotNull(occupant.place)
        assertNotNull(occupant.floor)
    }
}
