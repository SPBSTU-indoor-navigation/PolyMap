package com.polymap.android.map.annotations.views

import android.content.Context
import android.content.res.Configuration
import android.graphics.RectF
import android.view.View
import android.view.ViewGroup
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.DetailLevelProcessor
import com.polymap.android.map.annotations.DetailLevelState
import com.polymap.android.map.annotations.defaultDetailLevelProcessor
import com.polymap.android.ui.Animator

/**
 * MKAnnotationView analogue. The view itself is a fixed-size square centered on the coordinate;
 * subviews use their own transforms (scale / translation) exactly like the iOS views.
 */
abstract class BaseAnnotationView(context: Context, sizeDp: Float) : ViewGroup(context) {
    protected val density = context.resources.displayMetrics.density
    val sizePx = (sizeDp * density).toInt()

    var annotation: BaseAnnotation? = null
        set(value) { field = value; onAnnotationSet(value) }

    var isSelectedAnnotation = false
        private set
    var isPinned = false
        private set
    var state: DetailLevelState = DetailLevelState.UNDEFINED
        protected set
    var detailLevelRaw: Int = 0

    open val detailLevelProcessor: DetailLevelProcessor<DetailLevelState> get() = defaultDetailLevelProcessor
    open val defaultPriority: Int get() = 500
    var pinnedPriority = 900

    val zPriority: Int get() = when {
        isSelectedAnnotation -> 1000
        isPinned -> pinnedPriority
        else -> defaultPriority
    }

    val selectAnim = Animator()
    val deselectAnim = Animator()

    init {
        clipChildren = false
        clipToPadding = false
        setWillNotDraw(true)
    }

    val isDarkMode: Boolean
        get() = (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES

    protected abstract fun onAnnotationSet(annotation: BaseAnnotation?)

    open fun changeState(state: DetailLevelState, animate: Boolean) { this.state = state }

    /** Bounding box of the visible content relative to the view center (points). */
    open fun boundingBox(): RectF = RectF(-sizePx / 2f, -sizePx / 2f, sizePx / 2f, sizePx / 2f)

    open fun appearanceDidChange() {}

    fun update(mapSize: Float, animate: Boolean) {
        val target = detailLevelProcessor.evaluate(detailLevelRaw, mapSize) ?: DetailLevelState.NORMAL
        if (state != target) changeState(target, animate)
    }

    open fun setSelected(selected: Boolean, animated: Boolean) {
        isSelectedAnnotation = selected
        if (selected) selectAnim.play(animated) else deselectAnim.play(animated)
    }

    open fun setPinned(pinned: Boolean, animated: Boolean) {
        isPinned = pinned
        setSelected(isSelectedAnnotation, animated)
    }

    /** MKAnnotationView.hitTest port: only the view bounds (ignores label overflow), hidden/transparent views miss. */
    fun hitTest(xInView: Float, yInView: Float): Boolean {
        if (visibility != View.VISIBLE || alpha == 0f) return false
        return xInView >= 0 && yInView >= 0 && xInView <= sizePx && yInView <= sizePx
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        for (i in 0 until childCount) {
            val c = getChildAt(i)
            val lp = c.layoutParams as LayoutParams
            c.measure(
                if (lp.width > 0) MeasureSpec.makeMeasureSpec(lp.width, MeasureSpec.EXACTLY) else MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
                if (lp.height > 0) MeasureSpec.makeMeasureSpec(lp.height, MeasureSpec.EXACTLY) else MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
            )
        }
        setMeasuredDimension(sizePx, sizePx)
    }

    /** Layout params: position relative to the view center (cx, cy = center of child), or top anchored. */
    class LayoutParams(width: Int, height: Int, val cx: Float, val cy: Float, val topAnchored: Boolean = false) :
        ViewGroup.LayoutParams(width, height)

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val cx0 = sizePx / 2f; val cy0 = sizePx / 2f
        for (i in 0 until childCount) {
            val c = getChildAt(i)
            val lp = c.layoutParams as LayoutParams
            val w = c.measuredWidth; val h = c.measuredHeight
            val left: Int; val top: Int
            if (lp.topAnchored) {
                left = (cx0 + lp.cx - w / 2f).toInt()
                top = (cy0 + lp.cy).toInt()
            } else {
                left = (cx0 + lp.cx - w / 2f).toInt()
                top = (cy0 + lp.cy - h / 2f).toInt()
            }
            c.layout(left, top, left + w, top + h)
        }
    }

    protected fun lp(wDp: Float, hDp: Float, cxDp: Float, cyDp: Float, topAnchored: Boolean = false) =
        LayoutParams((wDp * density).toInt(), (hDp * density).toInt(), cxDp * density, cyDp * density, topAnchored)

    protected fun lpWrap(cxDp: Float, cyDp: Float, topAnchored: Boolean = true) =
        LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, cxDp * density, cyDp * density, topAnchored)

    /** Rect of a child in view-center-relative coordinates including its current scale/translation. */
    protected fun childRect(c: View): RectF {
        val cx = c.left + c.width / 2f + c.translationX - sizePx / 2f
        val cy = c.top + c.height / 2f + c.translationY - sizePx / 2f
        val hw = c.width * c.scaleX / 2f; val hh = c.height * c.scaleY / 2f
        return RectF(cx - hw, cy - hh, cx + hw, cy + hh)
    }

    fun View.hideIfZeroAlpha() { visibility = if (alpha == 0f) View.INVISIBLE else View.VISIBLE }
    fun View.hideIfZeroScale() { visibility = if (scaleX == 0f && scaleY == 0f) View.INVISIBLE else View.VISIBLE }

    protected fun color(res: Int) = androidx.core.content.ContextCompat.getColor(context, res)
}
