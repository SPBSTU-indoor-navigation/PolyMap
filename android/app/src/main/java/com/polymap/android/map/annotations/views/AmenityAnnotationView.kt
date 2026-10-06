package com.polymap.android.map.annotations.views

import android.content.Context
import android.graphics.RectF
import android.view.View
import androidx.core.content.ContextCompat
import com.polymap.android.R
import com.polymap.android.map.annotations.AmenityAnnotation
import com.polymap.android.map.annotations.AmenityDetailLevel
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.DetailLevelProcessor
import com.polymap.android.map.annotations.DetailLevelState
import com.polymap.android.map.annotations.EnviromentAmenityAnnotation
import com.polymap.android.ui.AnimProp
import com.polymap.android.ui.Animator
import com.polymap.android.ui.easeIn
import com.polymap.android.ui.easeOut

/** AmenityAnnotationView port (amenities & environment amenities). 30x30 view, 20dp rounded square icon. */
class AmenityAnnotationView(context: Context) : BaseAnnotationView(context, 30f) {

    private var detailLevel = AmenityAnnotation.DetailLevel.MIN

    val background = BubbleView(context).apply {
        cornerRadiusDp = 5f
        tailWidthDp = 6f; tailHeightDp = 2.4f
        iconInsetDp = 3f
        fillColor = color(R.color.system_blue)
        tailColor = color(R.color.system_blue)
    }
    private val miniPoint = View(context).apply {
        background = android.graphics.drawable.GradientDrawable().apply {
            shape = android.graphics.drawable.GradientDrawable.OVAL
            setColor(color(R.color.system_blue))
        }
        scaleX = 0f; scaleY = 0f
        visibility = View.INVISIBLE
    }
    val label = MapLabel(context).apply {
        textColor = color(R.color.label)
        alpha = 0f
        visibility = View.INVISIBLE
    }

    private val bgScale = AnimProp(1f) { background.scaleX = it; background.scaleY = it }
    private val bgTy = AnimProp(0f) { background.translationY = it * density }
    private val bgCorner = AnimProp(5f) { background.cornerRadiusDp = it }
    private val tail = AnimProp(0f) { background.tailProgress = it }
    private val imageAlpha = AnimProp(1f) { background.iconAlpha = it }
    private val viewAlpha = AnimProp(1f) { alpha = it }
    private val miniScale = AnimProp(0f) { miniPoint.scaleX = it; miniPoint.scaleY = it }
    private val labelAlpha = AnimProp(0f) { label.alpha = it }
    private val labelScale = AnimProp(0.5f) { label.scaleX = it; label.scaleY = it }
    private val labelTy = AnimProp(-10f) { label.translationY = it * density }

    init {
        addView(miniPoint, lp(6f, 6f, 0f, 0f))
        addView(label, lpWrap(0f, 3f))
        addView(background, lp(20f, 20f, 0f, 0f))
        label.pivotY = 0f
        setupLabel()

        selectAnim
            .spring(1000, 0, 0.4f) { r ->
                visibility = View.VISIBLE
                label.visibility = View.VISIBLE
                viewAlpha.set(viewOpacity(), r)
                imageAlpha.set(imageOpacity(), r)
                bgCorner.set(backgroundCornerRadius(), r)
                bgScale.set(backgroundScale(), r); bgTy.set(backgroundTy(), r)
                labelAlpha.set(labelOpacity(), r)
                labelScale.set(labelScaleTarget(), r); labelTy.set(labelTyTarget(), r)
            }
            .spring(500, 200, 0.7f) { r ->
                miniPoint.visibility = View.VISIBLE
                miniScale.set(miniPointScale(), r)
            }
            .animate(350, 50) { r -> tail.set(tailTarget(), r) }

        deselectAnim
            .spring(500, 0, 0.7f) { r ->
                viewAlpha.set(viewOpacity(), r)
                bgScale.set(backgroundScale(), r); bgTy.set(backgroundTy(), r)
            }
            .animate(300, 0, completion = { miniPoint.hideIfZeroScale() }) { r ->
                tail.set(tailTarget(), r)
                miniScale.set(miniPointScale(), r)
            }
            .animate(100, 0, easeOut, completion = { label.hideIfZeroAlpha(); hideIfZeroAlpha() }) { r ->
                labelAlpha.set(labelOpacity(), r)
                labelScale.set(labelScaleTarget(), r); labelTy.set(labelTyTarget(), r)
                imageAlpha.set(imageOpacity(), r)
                bgCorner.set(backgroundCornerRadius(), r)
            }
    }

    private fun setupLabel() {
        val dark = isDarkMode
        label.strokeSize = if (dark) 1.5f else 2.5f
        label.textSizeSp = 12f
        label.bold = dark
        label.strokeColor = color(R.color.ios_stroke)
    }

    override fun onAnnotationSet(annotation: BaseAnnotation?) {
        when (annotation) {
            is AmenityAnnotation -> background.icon = ContextCompat.getDrawable(context, annotation.sprite)
            is EnviromentAmenityAnnotation -> background.icon = ContextCompat.getDrawable(context, annotation.sprite)
            else -> {}
        }
        label.text = annotation?.title
        detailLevel = (annotation as? AmenityDetailLevel)?.detailLevel ?: AmenityAnnotation.DetailLevel.MIN
        detailLevelRaw = detailLevel.raw
        requestLayout()
    }

    override val detailLevelProcessor: DetailLevelProcessor<DetailLevelState> get() = AmenityAnnotation.levelProcessor
    override val defaultPriority: Int get() = 600

    override fun boundingBox(): RectF {
        val r = childRect(background)
        if (label.alpha > 0f && !label.isEmpty) r.union(childRect(label))
        return r
    }

    override fun changeState(state: DetailLevelState, animate: Boolean) {
        super.changeState(state, animate)
        if (isSelectedAnnotation) return
        Animator().animate(300, completion = { hideIfZeroAlpha() }) { r ->
            bgScale.set(backgroundScale(), r); bgTy.set(backgroundTy(), r)
            imageAlpha.set(imageOpacity(), r)
            bgCorner.set(backgroundCornerRadius(), r)
            viewAlpha.set(viewOpacity(), r)
            if (visibility != View.VISIBLE && viewOpacity() > 0f) visibility = View.VISIBLE
        }.play(animate)
    }

    override fun appearanceDidChange() {
        super.appearanceDidChange()
        background.tailColor = color(R.color.system_blue)
        background.fillColor = color(R.color.system_blue)
        setupLabel()
    }

    // ----- targets

    private fun labelOpacity(): Float = if (isSelectedAnnotation || isPinned) 1f else 0f

    private fun viewOpacity(): Float = if (isSelectedAnnotation || isPinned || state != DetailLevelState.HIDE) 1f else 0f

    private fun miniPointScale(): Float = when {
        isSelectedAnnotation -> 1f
        isPinned -> 0.5f
        else -> 0f
    }

    private fun labelScaleTarget(): Float = if (isSelectedAnnotation || isPinned) 1f else 0.5f
    private fun labelTyTarget(): Float = when {
        isSelectedAnnotation -> 0f
        isPinned -> -2f
        else -> -10f * 0.5f
    }

    private fun imageOpacity(): Float {
        if (isSelectedAnnotation || isPinned) return 1f
        return if (state == DetailLevelState.BIG || state == DetailLevelState.NORMAL) 1f else 0f
    }

    private fun tailTarget(): Float = if (isSelectedAnnotation || isPinned) 1f else 0f

    private fun stateSize(): Float = when (state) {
        DetailLevelState.BIG -> 1.2f
        DetailLevelState.NORMAL -> 0.8f
        else -> 0.3f
    }

    private fun backgroundScale(): Float = when {
        isSelectedAnnotation -> 2.5f
        isPinned -> 1.2f
        else -> stateSize()
    }

    private fun backgroundTy(): Float = when {
        isSelectedAnnotation -> -15.5f * 2.5f
        isPinned -> -15.5f * 1.2f
        else -> 0f
    }

    private fun backgroundCornerRadius(): Float {
        if (isSelectedAnnotation || isPinned) return 5f
        return if (state == DetailLevelState.BIG || state == DetailLevelState.NORMAL) 5f else 10f
    }
}
