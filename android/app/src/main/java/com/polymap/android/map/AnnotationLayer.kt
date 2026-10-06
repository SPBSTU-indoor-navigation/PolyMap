package com.polymap.android.map

import android.content.Context
import android.graphics.PointF
import android.view.View
import android.view.ViewGroup
import com.polymap.android.imdf.Coord
import com.polymap.android.map.annotations.AmenityAnnotation
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.EnviromentAmenityAnnotation
import com.polymap.android.map.annotations.OccupantAnnotation
import com.polymap.android.map.annotations.views.AmenityAnnotationView
import com.polymap.android.map.annotations.views.AttractionAnnotationView
import com.polymap.android.map.annotations.views.BaseAnnotationView
import com.polymap.android.map.annotations.views.PointAnnotationView

/**
 * Hosts annotation views on top of the MapLibre map, positioning each one at its projected
 * screen coordinate (the MKMapView annotation container analogue).
 */
class AnnotationLayer(context: Context) : ViewGroup(context) {
    private val views = LinkedHashMap<BaseAnnotation, BaseAnnotationView>()
    var onAnnotationAdd: ((BaseAnnotation) -> Unit)? = null
    private var lastProject: ((Coord) -> PointF?)? = null

    init {
        clipChildren = false
        clipToPadding = false
    }

    val annotations: Collection<BaseAnnotation> get() = views.keys

    fun viewFor(annotation: BaseAnnotation?): BaseAnnotationView? = annotation?.let { views[it] }

    fun contains(annotation: BaseAnnotation) = views.containsKey(annotation)

    fun add(annotation: BaseAnnotation, pinned: Boolean, mapSize: Float): BaseAnnotationView {
        views[annotation]?.let { return it }
        val view = when (annotation) {
            is OccupantAnnotation -> PointAnnotationView(context)
            is AmenityAnnotation, is EnviromentAmenityAnnotation -> AmenityAnnotationView(context)
            is AttractionAnnotation -> AttractionAnnotationView(context)
            else -> PointAnnotationView(context)
        }
        view.annotation = annotation
        view.setPinned(pinned, false)
        view.update(mapSize, false)
        views[annotation] = view
        addView(view, insertIndex(view.zPriority))
        lastProject?.let { p -> position(view, annotation, p) }
        onAnnotationAdd?.invoke(annotation)
        return view
    }

    fun remove(annotation: BaseAnnotation) {
        val v = views.remove(annotation) ?: return
        removeView(v)
    }

    private fun insertIndex(priority: Int): Int {
        var idx = childCount
        for (i in 0 until childCount) {
            val c = getChildAt(i) as BaseAnnotationView
            if (c.zPriority > priority) { idx = i; break }
        }
        return idx
    }

    /** Re-inserts the view according to its z priority (after select/pin changes). */
    fun reorder(view: BaseAnnotationView) {
        if (view.parent !== this) return
        removeViewInLayout(view)
        addViewInLayout(view, insertIndex(view.zPriority), view.layoutParams ?: generateDefaultLayoutParams(), true)
        invalidate()
    }

    fun updatePositions(project: (Coord) -> PointF?) {
        lastProject = project
        for ((annotation, view) in views) position(view, annotation, project)
    }

    private fun position(view: BaseAnnotationView, annotation: BaseAnnotation, project: (Coord) -> PointF?) {
        val p = project(annotation.coordinate) ?: return
        view.translationX = p.x - view.sizePx / 2f
        view.translationY = p.y - view.sizePx / 2f
    }

    /** Topmost annotation view whose bounds contain the point (QuickSelectMapView.hitTest analogue). */
    fun hitTest(x: Float, y: Float): BaseAnnotationView? {
        for (i in childCount - 1 downTo 0) {
            val c = getChildAt(i) as BaseAnnotationView
            val lx = x - c.translationX
            val ly = y - c.translationY
            // enlarge the hit area a little to match finger precision of MKAnnotationView
            val slop = 6f * resources.displayMetrics.density
            if (c.visibility == View.VISIBLE && c.alpha > 0f &&
                lx >= -slop && ly >= -slop && lx <= c.sizePx + slop && ly <= c.sizePx + slop
            ) return c
        }
        return null
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        for (i in 0 until childCount) {
            getChildAt(i).measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
        }
        setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        for (i in 0 until childCount) {
            val c = getChildAt(i)
            c.layout(0, 0, c.measuredWidth, c.measuredHeight)
        }
    }

    override fun shouldDelayChildPressedState() = false

    fun forEachView(block: (BaseAnnotationView) -> Unit) {
        for (v in views.values) block(v)
    }

    fun appearanceDidChange() = forEachView { it.appearanceDidChange() }
}
