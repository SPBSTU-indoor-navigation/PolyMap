package com.polymap.android.map.annotations.views

import android.content.Context
import android.graphics.RectF
import android.graphics.Typeface
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.DrawableCompat
import com.polymap.android.R
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.DetailLevelProcessor
import com.polymap.android.map.annotations.DetailLevelState
import com.polymap.android.ui.AnimProp
import com.polymap.android.ui.Animator
import com.polymap.android.ui.easeIn

/** AttractionAnnotationView port (buildings). 40x40 view. */
class AttractionAnnotationView(context: Context) : BaseAnnotationView(context, 40f) {

    val background = BubbleView(context).apply {
        cornerRadiusDp = 20f
        tailWidthDp = 10f; tailHeightDp = 4f
        fillColor = color(R.color.ios_attractionbackground)
        tailColor = color(R.color.ios_attractionborder)
        borderColor = color(R.color.ios_attractionborder)
        borderWidthDp = 2f
    }
    private val labelShort = TextView(context).apply {
        setTextColor(color(R.color.ios_attractionborder))
        gravity = Gravity.CENTER
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 40f)
        scaleX = 0.5f; scaleY = 0.5f
        maxLines = 1
        includeFontPadding = false
    }
    private val indoorPlanContent = BubbleView(context).apply {
        cornerRadiusDp = 3f
        fillColor = color(R.color.ios_attractionborder)
        iconInsetDp = 1.5f
        icon = ContextCompat.getDrawable(context, R.drawable.ic_indoor_plan)
        iconTint = color(R.color.accent)
    }
    private val miniPoint = View(context).apply {
        background = android.graphics.drawable.GradientDrawable().apply {
            shape = android.graphics.drawable.GradientDrawable.OVAL
            setColor(color(R.color.ios_attractionborder))
        }
        scaleX = 0f; scaleY = 0f
        visibility = View.INVISIBLE
    }
    val label = MapLabel(context).apply {
        textColor = color(R.color.ios_attractiontextcolor)
        strokeColor = color(R.color.ios_attractiontextstroke)
        maxWidthDp = 120f
    }

    private val bgScale = AnimProp(0.6f) { v ->
        background.scaleX = v; background.scaleY = v
        labelShort.scaleX = 0.5f * v; labelShort.scaleY = 0.5f * v
        indoorPlanContent.scaleX = v; indoorPlanContent.scaleY = v
    }
    private val bgTy = AnimProp(0f) { v ->
        background.translationY = v * density; labelShort.translationY = v * density
        indoorPlanContent.translationY = v * density
    }
    private val bgTx = AnimProp(0f) { v -> indoorPlanContent.translationX = v * density }
    private val tail = AnimProp(0f) { background.tailProgress = it }
    private val miniScale = AnimProp(0f) { miniPoint.scaleX = it; miniPoint.scaleY = it }
    private val labelAlpha = AnimProp(0f) { label.alpha = it }
    private val labelTy = AnimProp(0f) { label.translationY = it * density }
    private val labelColorMix = AnimProp(0f) { m ->
        label.textColor = androidx.core.graphics.ColorUtils.blendARGB(color(R.color.ios_attractiontextcolor), color(R.color.label), m)
    }

    init {
        addView(miniPoint, lp(6f, 6f, 0f, 0f))
        addView(background, lp(40f, 40f, 0f, 0f))
        addView(labelShort, LayoutParams((55f * density).toInt(), (40f * density).toInt(), 0f, 0f))
        addView(indoorPlanContent, lp(12f, 12f, 20f - 7f, 20f - 7f))
        addView(label, lpWrap(0f, 22f))
        label.pivotY = 0f
        setupLabel()
        detailLevelRaw = 0

        selectAnim
            .spring(1000, 0, 0.4f) { r ->
                bgScale.set(pointScale(), r); bgTy.set(pointTy(), r); bgTx.set(pointTx(), r)
                labelTy.set(labelTyTarget(), r)
                labelColorMix.set(1f, r)
            }
            .spring(500, 200, 0.7f) { r ->
                miniPoint.visibility = View.VISIBLE
                miniScale.set(miniPointScale(), r)
            }
            .animate(200, 50) { r ->
                tail.set(tailTarget(), r)
                labelAlpha.set(labelOpacity(), r)
            }

        deselectAnim
            .spring(500, 0, 0.7f) { r ->
                bgScale.set(pointScale(), r); bgTy.set(pointTy(), r); bgTx.set(pointTx(), r)
                labelTy.set(labelTyTarget(), r)
                labelColorMix.set(0f, r)
            }
            .animate(300, 0, completion = { miniPoint.hideIfZeroScale() }) { r ->
                tail.set(tailTarget(), r)
                miniScale.set(miniPointScale(), r)
                labelAlpha.set(labelOpacity(), r)
            }
    }

    private fun setupLabel() {
        val dark = isDarkMode
        label.strokeSize = if (dark) 1.5f else 3f
        label.textSizeSp = if (dark) 12f else 13f
        label.bold = true
    }

    override fun onAnnotationSet(annotation: BaseAnnotation?) {
        label.text = annotation?.title
        val attraction = annotation as? AttractionAnnotation ?: return
        val sprite = attraction.annotationSprite
        if (sprite != null) {
            background.image = ContextCompat.getDrawable(context, sprite)
            labelShort.visibility = View.GONE
        } else {
            background.image = null
            labelShort.text = attraction.properties.shortName?.bestLocalizedValue ?: "-"
            labelShort.visibility = View.VISIBLE
            fitShortLabel()
        }
        indoorPlanContent.visibility = if (attraction.building.levels.isEmpty()) View.GONE else View.VISIBLE
        requestLayout()
    }

    /** UILabel.adjustsFontSizeToFitWidth analogue for the short title (max width 55dp at 0.5 scale => 110dp virtual). */
    private fun fitShortLabel() {
        var size = 40f
        val paint = android.text.TextPaint(labelShort.paint)
        val maxW = 55f * density * 2f
        val t = labelShort.text.toString()
        while (size > 8f) {
            paint.textSize = size * context.resources.displayMetrics.scaledDensity
            if (paint.measureText(t) <= maxW) break
            size -= 2f
        }
        labelShort.setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
    }

    override val detailLevelProcessor: DetailLevelProcessor<DetailLevelState> get() = stateProcessor
    override val defaultPriority: Int get() = 700

    override fun boundingBox(): RectF {
        val r = childRect(background)
        if (label.alpha > 0f && !label.isEmpty) r.union(childRect(label))
        return r
    }

    override fun changeState(state: DetailLevelState, animate: Boolean) {
        super.changeState(state, animate)
        if (isSelectedAnnotation) return
        Animator().animate(200) { r ->
            labelAlpha.set(labelOpacity(), r)
            bgScale.set(pointScale(), r); bgTy.set(pointTy(), r); bgTx.set(pointTx(), r)
            labelTy.set(labelTyTarget(), r)
        }.play(animate)
    }

    override fun appearanceDidChange() {
        background.tailColor = color(R.color.ios_attractionborder)
        background.borderColor = color(R.color.ios_attractionborder)
        background.fillColor = color(R.color.ios_attractionbackground)
        setupLabel()
    }

    // ----- targets (AttractionAnnotationView extension port)

    private fun pointSize(): Float = when (state) {
        DetailLevelState.BIG -> 1f
        DetailLevelState.NORMAL -> 0.8f
        else -> 0.6f
    }

    private fun pointScale(): Float = when {
        isSelectedAnnotation -> 1.5f
        isPinned -> 1f
        else -> pointSize()
    }

    private fun pointTy(): Float = when {
        isSelectedAnnotation -> -29f * 1.5f
        isPinned -> -29f
        else -> 0f
    }

    /** the indoor-plan badge sits at the bottom-right of the (scaled) 40dp circle */
    private fun pointTx(): Float = (pointScale() - 1f) * 13f

    private fun miniPointScale(): Float = when {
        isSelectedAnnotation -> 1f
        isPinned -> 0.8f
        else -> 0f
    }

    private fun labelTyTarget(): Float = when {
        isSelectedAnnotation -> -18f
        isPinned -> -19f
        else -> (1f - pointSize()) * -20f
    }

    private fun tailTarget(): Float = if (isSelectedAnnotation || isPinned) 1f else 0f

    private fun labelOpacity(): Float {
        if (isSelectedAnnotation || isPinned) return 1f
        return if (state == DetailLevelState.NORMAL || state == DetailLevelState.BIG) 1f else 0f
    }

    companion object {
        val stateProcessor: DetailLevelProcessor<DetailLevelState> = DetailLevelProcessor<DetailLevelState>().apply {
            builder(0)
                .add(0f, DetailLevelState.HIDE)
                .add(15f, DetailLevelState.MIN)
                .add(17.2f, DetailLevelState.NORMAL)
                .add(18f, DetailLevelState.BIG)
        }
    }
}
