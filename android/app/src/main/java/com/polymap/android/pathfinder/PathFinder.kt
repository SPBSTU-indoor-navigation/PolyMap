package com.polymap.android.pathfinder

import com.polymap.android.imdf.Coord
import com.polymap.android.imdf.Feature
import com.polymap.android.imdf.IMDF
import com.polymap.android.imdf.MapRect
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.overlays.Building
import com.polymap.android.map.overlays.Level
import java.util.PriorityQueue
import java.util.UUID

interface PathResultNode {
    val location: Coord
    val building: Building?
    val level: Level?
}

val PathResultNode.isIndoor: Boolean get() = building != null

class PathResult(
    val path: List<PathResultNode>,
    val from: BaseAnnotation,
    val to: BaseAnnotation,
    val totalCost: Float
) {
    val indoorDistance: Double = distance(path) { _, b -> b.building != null }
    val outdoorDistance: Double = distance(path) { _, b -> b.building == null }
    val time: Float = ((outdoorDistance / 4.0 + indoorDistance / 2.0) * 3.6).toFloat()
    val fastTime: Float = ((outdoorDistance / 5.0 + indoorDistance / 3.0) * 3.6).toFloat()

    val totalDistance: Double get() = indoorDistance + outdoorDistance

    val mapRect: MapRect
        get() = MapRect.ofCoords(path.map { it.location })
            .union(MapRect.point(from.coordinate))
            .union(MapRect.point(to.coordinate))

    companion object {
        fun distance(path: List<PathResultNode>, filter: (PathResultNode, PathResultNode) -> Boolean): Double {
            if (path.isEmpty()) return 0.0
            var result = 0.0
            for (i in 1 until path.size) {
                if (filter(path[i - 1], path[i])) result += path[i].location.distance(path[i - 1].location)
            }
            return result
        }
    }
}

class PathNode(
    override val location: Coord,
    val weight: Float,
    val tags: List<IMDF.NavPathTag>
) : PathResultNode {
    var connectedNodes: List<PathNode> = emptyList()
    override var building: Building? = null
    override var level: Level? = null
    private var extraWeight: Float = 0f

    /** GKGraphNode.cost(to:) port: cost of the edge from this node. */
    fun cost(to: PathNode): Float = (to.location.distance(location)).toFloat() * weight + extraWeight

    fun applyDenyTags(deny: List<IMDF.NavPathTag>) {
        extraWeight = if (tags.any { deny.contains(it) }) 1000f else 0f
    }
}

/** Port of PathFinder (Dijkstra — GKGraphNode.estimatedCost returned 0 on iOS). */
class PathFinder private constructor() {
    var nodes: List<PathNode> = emptyList()
        private set
    private var associeted: List<Pair<BaseAnnotation, PathNode>> = emptyList()
    var annotationById: Map<UUID, BaseAnnotation> = emptyMap()
        private set

    private var indexOf: Map<PathNode, Int> = emptyMap()

    fun pathNode(by: BaseAnnotation): List<PathNode> = associeted.filter { it.first === by }.map { it.second }

    fun nearestPathNode(to: BaseAnnotation): PathNode? =
        nodes.minByOrNull { it.location.distance(to.coordinate) }

    fun setup(
        navPath: List<Feature<IMDF.NavPathProperties>>,
        associeted: List<Feature<IMDF.NavPathAssocietedProperties>>,
        buildings: Map<UUID, Building>,
        levels: Map<UUID, Level>,
        annotations: Map<UUID, BaseAnnotation>
    ) {
        val converted = LinkedHashMap<UUID, Pair<Feature<IMDF.NavPathProperties>, PathNode>>()
        for (f in navPath) {
            val point = (f.geometry as? com.polymap.android.imdf.Geometry.Point)?.coord ?: continue
            converted[f.identifier] = f to PathNode(point, f.properties.weight, f.properties.tags)
        }
        for ((_, pair) in converted) {
            val (feature, node) = pair
            node.connectedNodes = feature.properties.neighbours.mapNotNull { converted[it]?.second }
            feature.properties.buildingId?.let { id -> buildings[id]?.let { node.building = it } }
            feature.properties.levelId?.let { id -> levels[id]?.let { node.level = it } }
        }
        this.associeted = associeted
            .filter { annotations[it.properties.associetedId] != null && converted[it.properties.pathNodeId] != null }
            .map { annotations[it.properties.associetedId]!! to converted[it.properties.pathNodeId]!!.second }
        nodes = converted.values.map { it.second }
        indexOf = nodes.withIndex().associate { it.value to it.index }
        annotationById = annotations
    }

    fun findPath(from: BaseAnnotation, to: BaseAnnotation, denyTags: List<IMDF.NavPathTag>): PathResult? {
        var fromAssociated = pathNode(from)
        var toAssociated = pathNode(to)
        if (fromAssociated.isEmpty()) fromAssociated = listOf(nearestPathNode(from) ?: return null)
        if (toAssociated.isEmpty()) toAssociated = listOf(nearestPathNode(to) ?: return null)

        nodes.forEach { it.applyDenyTags(denyTags) }

        var shortestPath: List<PathNode> = emptyList()
        var shortestCost = Float.MAX_VALUE
        for (f in fromAssociated) {
            for (t in toAssociated) {
                val path = dijkstra(f, t) ?: continue
                if (path.isEmpty()) continue
                val cost = cost(path)
                if (cost < shortestCost) {
                    shortestCost = cost
                    shortestPath = path
                }
            }
        }
        return PathResult(shortestPath, from, to, shortestCost)
    }

    private fun cost(path: List<PathNode>): Float {
        if (path.isEmpty()) return 0f
        var result = 0f
        for (i in 1 until path.size) result += path[i - 1].cost(path[i])
        return result
    }

    private fun dijkstra(from: PathNode, to: PathNode): List<PathNode>? {
        if (from === to) return listOf(from)
        val n = nodes.size
        val dist = FloatArray(n) { Float.MAX_VALUE }
        val prev = IntArray(n) { -1 }
        val done = BooleanArray(n)
        val start = indexOf[from] ?: return null
        val goal = indexOf[to] ?: return null
        dist[start] = 0f
        val queue = PriorityQueue<Pair<Int, Float>>(compareBy { it.second })
        queue.add(start to 0f)
        while (queue.isNotEmpty()) {
            val (u, d) = queue.poll()
            if (done[u]) continue
            done[u] = true
            if (u == goal) break
            val node = nodes[u]
            for (nb in node.connectedNodes) {
                val v = indexOf[nb] ?: continue
                if (done[v]) continue
                val nd = d + node.cost(nb)
                if (nd < dist[v]) {
                    dist[v] = nd
                    prev[v] = u
                    queue.add(v to nd)
                }
            }
        }
        if (dist[goal] == Float.MAX_VALUE) return null
        val path = ArrayList<PathNode>()
        var cur = goal
        while (cur != -1) {
            path.add(nodes[cur])
            cur = prev[cur]
        }
        path.reverse()
        return path
    }

    companion object {
        val shared = PathFinder()
    }
}
