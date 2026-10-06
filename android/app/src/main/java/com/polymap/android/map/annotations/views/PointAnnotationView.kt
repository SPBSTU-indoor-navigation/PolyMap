package com.polymap.android.map.annotations.views

import android.content.Context
import android.graphics.RectF
import android.view.View
import androidx.core.content.ContextCompat
import com.polymap.android.R
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.DetailLevelProcessor
import com.polymap.android.map.annotations.DetailLevelState
import com.polymap.android.map.annotations.OccupantAnnotation
import com.polymap.android.ui.AnimProp
import com.polymap.android.ui.AnimRun
import com.polymap.android.ui.Animator
import com.polymap.android.ui.easeIn
import com.polymap.android.ui.easeOut

/** PointAnnotationView port (occupants: rooms, auditoriums ...). 30x30 view. */
class PointAnnotationView(context: Context) : BaseAnnotationView(context, 30f) {

    private var detailLevel = OccupantAnnotation.DetailLevel.POINT_SECONDARY
    private var titleLabelColor: Int = 0

    val point = BubbleView(context).apply {
        cornerRadiusDp = 5f
        tailWidthDp = 2f; tailHeightDp = 1f
        borderWidthDp = 0.65f
        iconInsetDp = 2f
        iconAlpha = 0f
        borderColor = color(R.color.system_background)
    }
    private val miniPoint = View(context).apply {
        background = android.graphics.drawable.GradientDrawable().apply { shape = android.graphics.drawable.GradientDrawable.OVAL }
        scaleX = 0f; scaleY = 0f
        visibility = View.INVISIBLE
    }
    val label = MapLabel(context).apply {
        textColor = color(R.color.label)
        strokeColor = color(R.color.ios_stroke)
    }

    // animatable props
    private val pointScale = AnimProp(1f) { point.scaleX = it; point.scaleY = it }
    private val pointTy = AnimProp(0f) { point.translationY = it * density }
    private val pointTail = AnimProp(0f) { point.tailProgress = it }
    private val pointBorderAlpha = AnimProp(1f) { point.borderColor = withAlpha(color(R.color.system_background), it) }
    private val imageAlpha = AnimProp(0f) { point.iconAlpha = it }
    private val miniScale = AnimProp(0f) { miniPoint.scaleX = it; miniPoint.scaleY = it }
    private val labelAlpha = AnimProp(0f) { label.alpha = it }
    private val labelScale = AnimProp(1f) { label.scaleX = it; label.scaleY = it }
    private val labelTy = AnimProp(0f) { label.translationY = it * density }
    private val labelColorMix = AnimProp(0f) { applyLabelColor(it) }

    init {
        addView(miniPoint, lp(6f, 6f, 0f, 0f))
        addView(point, lp(10f, 10f, 0f, 0f))
        addView(label, lpWrap(0f, 5f))
        label.pivotY = 0f
        setupLabel()

        selectAnim
            .spring(1000, 0, 0.4f) { r ->
                pointScale.set(pointScaleTarget(), r); pointTy.set(pointTyTarget(), r)
                imageAlpha.set(1f, r)
            }
            .spring(500, 200, 0.7f) { r ->
                miniPoint.visibility = View.VISIBLE
                miniScale.set(miniPointScale(), r)
            }
            .animate(200, 50) { r ->
                pointTail.set(pointTailTarget(), r)
                labelAlpha.set(labelOpacity(), r)
            }
            .animate(50, 0, easeIn) { r -> pointBorderAlpha.set(borderAlpha(), r) }

        deselectAnim
            .spring(500, 0, 0.7f) { r -> pointScale.set(pointScaleTarget(), r); pointTy.set(pointTyTarget(), r) }
            .animate(100, 0, easeIn) { r ->
                labelAlpha.set(labelOpacity(), r)
                labelScale.set(labelScaleTarget(), r); labelTy.set(labelTyTarget(), r)
            }
            .animate(300, 0, completion = { miniPoint.hideIfZeroScale() }) { r ->
                pointTail.set(pointTailTarget(), r)
                miniScale.set(miniPointScale(), r)
                imageAlpha.set(imageOpacity(), r)
                pointBorderAlpha.set(borderAlpha(), r)
                labelColorMix.set(labelColorMixTarget(), r)
            }
    }

    private fun withAlpha(color: Int, alpha: Float): Int = (color and 0x00FFFFFF) or ((alpha.coerceIn(0f, 1f) * 255).toInt() shl 24)

    private fun setupLabel() {
        val dark = isDarkMode
        label.strokeSize = if (dark) 1.5f else 2.5f
        label.textSizeSp = 12f
        label.bold = dark
        label.strokeColor = color(R.color.ios_stroke)
    }

    override fun onAnnotationSet(annotation: BaseAnnotation?) {
        val unit = annotation as? OccupantAnnotation
        if (unit != null) {
            detailLevel = unit.detailLevel
            detailLevelRaw = detailLevel.raw
            point.icon = ContextCompat.getDrawable(context, unit.sprite)
            val c = color(unit.backgroundSpriteColor)
            changePointColor(c)
            titleLabelColor = color(unit.titleLabelColor)
        }
        label.text = annotation?.title
        // immediate state (no animation), like the iOS didSet
        imageAlpha.setImmediate(imageOpacity())
        labelAlpha.setImmediate(labelOpacity())
        pointScale.setImmediate(pointScaleTarget()); pointTy.setImmediate(pointTyTarget())
        labelScale.setImmediate(labelScaleTarget()); labelTy.setImmediate(labelTyTarget())
        labelColorMix.setImmediate(labelColorMixTarget())
        point.borderWidthDp = pointBorderWidth()
        pointTail.setImmediate(pointTailTarget())
        miniScale.setImmediate(miniPointScale())
        pointBorderAlpha.setImmediate(borderAlpha())
        requestLayout()
    }

    private fun changePointColor(c: Int) {
        point.fillColor = c
        point.tailColor = c
        (miniPoint.background as android.graphics.drawable.GradientDrawable).setColor(c)
    }

    private fun applyLabelColor(mix: Float) {
        // mix 0 -> titleLabelColor, 1 -> label color
        val a = color(R.color.label)
        label.textColor = if (mix >= 0.999f) a else if (mix <= 0.001f) titleLabelColor else
            androidx.core.graphics.ColorUtils.blendARGB(titleLabelColor, a, mix)
    }

    override val detailLevelProcessor: DetailLevelProcessor<DetailLevelState> get() = OccupantAnnotation.levelProcessor
    override val defaultPriority: Int get() = 500

    override fun changeState(state: DetailLevelState, animate: Boolean) {
        super.changeState(state, animate)
        if (isSelectedAnnotation) return
        Animator().animate(100) { r ->
            labelScale.set(labelScaleTarget(), r); labelTy.set(labelTyTarget(), r)
            labelAlpha.set(labelOpacity(), r)
            pointScale.set(pointScaleTarget(), r); pointTy.set(pointTyTarget(), r)
        }.play(animate)
    }

    override fun boundingBox(): RectF {
        val r = childRect(point)
        if (label.alpha > 0f && !label.isEmpty) r.union(childRect(label))
        return r
    }

    override fun appearanceDidChange() {
        super.appearanceDidChange()
        setupLabel()
        point.borderWidthDp = pointBorderWidth()
        pointBorderAlpha.setImmediate(borderAlpha())
        applyLabelColor(labelColorMixTarget())
    }

    override fun setSelected(selected: Boolean, animated: Boolean) {
        super.setSelected(selected, animated)
        labelColorMix.set(labelColorMixTarget(), AnimRun(animated, 200))
    }

    // ----- transform targets (PointAnnotationView extension port). Translations are scale * offset like CGAffineTransform.

    private val isCircle: Boolean get() = detailLevel == OccupantAnnotation.DetailLevel.CIRCLE_WITHOUT_LABEL

    private fun normalScale(): Float = if (isCircle) {
        when (state) { DetailLevelState.BIG -> 2.0f; else -> 1.6f }
    } else {
        when (state) { DetailLevelState.BIG, DetailLevelState.NORMAL, DetailLevelState.MIN -> 0.8f; else -> 0.6f }
    }

    private fun pointScaleTarget(): Float = when {
        isSelectedAnnotation -> 7.0f
        isPinned -> 3.0f
        else -> normalScale()
    }

    private fun pointTyTarget(): Float = when {
        isSelectedAnnotation -> -6.8f * 7.0f
        isPinned -> -6.8f * 3.0f
        else -> 0f
    }

    private fun miniPointScale(): Float = when {
        isSelectedAnnotation -> 1f
        isPinned -> 0.5f
        else -> 0f
    }

    private fun pointTailTarget(): Float = if (isSelectedAnnotation || isPinned) 1f else 0f

    private fun borderAlpha(): Float = if (isSelectedAnnotation || isPinned) 0f else 1f

    private fun labelOpacity(): Float {
        if (isSelectedAnnotation || isPinned) return 1f
        if (isCircle) return 0f
        return if (state == DetailLevelState.NORMAL || state == DetailLevelState.BIG) 1f else 0f
    }

    private fun labelScaleTarget(): Float = if (!isSelectedAnnotation && !isPinned && isCircle) 0.5f else 1f

    private fun labelTyTarget(): Float = when {
        isSelectedAnnotation -> -0.5f
        isPinned -> -4f
        isCircle -> -12f
        else -> 0f
    }

    private fun imageOpacity(): Float = if (isSelectedAnnotation || isPinned || isCircle) 1f else 0f

    private fun labelColorMixTarget(): Float = if (isSelectedAnnotation || isPinned || isCircle) 1f else 0f

    private fun pointBorderWidth(): Float {
        val dark = isDarkMode
        return if (dark) (if (isCircle) 0.3f else 0.8f) else (if (isCircle) 0.5f else 1.2f)
    }
}
