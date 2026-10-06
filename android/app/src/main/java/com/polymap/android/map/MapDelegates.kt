package com.polymap.android.map

import android.graphics.RectF
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.pathfinder.PathResult
import java.util.UUID

enum class FocusVariant { AUTO, CENTER, SAFE_AREA }

enum class HorizontalSize { BIG, SMALL, ULTRA_SMALL }

/** MapViewDelegate port: what the bottom sheet pages can ask the map to do. */
interface MapViewDelegate {
    fun focusAndSelect(annotation: BaseAnnotation, focusVariant: FocusVariant = FocusVariant.AUTO): Boolean
    fun focus(annotation: BaseAnnotation, focusVariant: FocusVariant = FocusVariant.AUTO)
    fun focus(attraction: AttractionAnnotation)
    fun focus(pathResult: PathResult)
    fun deselectAnnotation(annotation: BaseAnnotation?, animated: Boolean)
    fun pinAnnotation(annotation: BaseAnnotation, animated: Boolean)
    fun unpinAnnotation(annotation: BaseAnnotation, animated: Boolean)
    fun addPath(path: List<com.polymap.android.pathfinder.PathResultNode>): UUID
    fun removePath(id: UUID)
}

/** MapInfoDelegate port: what the map tells the bottom sheet. */
interface MapInfoDelegate {
    /** Pan on the map: translation since gesture start and touch location, both in map view coordinates. */
    fun panAction(translationY: Float, locationY: Float)
    fun zoomMap(zoom: Float, animated: Boolean)
    fun mkDidSelect(annotation: BaseAnnotation?)
    fun mkDidDeselect(annotation: BaseAnnotation?)
    fun select(annotation: BaseAnnotation?)
    /** Area of the map not covered by the sheet, in map view coordinates. */
    fun getSafeZone(): RectF
    fun getHorizontalSize(): HorizontalSize
}
