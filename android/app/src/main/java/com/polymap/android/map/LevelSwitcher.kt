package com.polymap.android.map

import android.content.Context
import android.graphics.Canvas
import android.graphics.Outline
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewOutlineProvider
import android.widget.ImageView
import androidx.core.content.ContextCompat
import com.polymap.android.R
import com.polymap.android.ui.AnimProp
import com.polymap.android.ui.AnimRun
import com.polymap.android.ui.easeOut
import kotlin.math.max
import kotlin.math.min

/** LevelSwitcher port: vertical list of floors with a draggable indicator and a "rotate to building" button. */
class LevelSwitcher(context: Context) : ViewGroup(context) {
    private val density = context.resources.displayMetrics.density
    private fun dp(v: Float) = v * density

    var levels: Map<Int, String> = emptyMap()
        private set
    var onChange: ((Int) -> Unit)? = null
    var onRotate: (() -> Unit)? = null

    private var sortedOrdinals: List<Int> = emptyList()

    private val levelsView = LevelsView()
    private val rotateButton = ImageView(context).apply {
        setImageResource(R.drawable.ic_rotate_building)
        setColorFilter(ContextCompat.getColor(context, R.color.secondary_label))
        scaleType = ImageView.ScaleType.FIT_CENTER
        val pad = dp(8f).toInt()
        setPadding(pad, pad, pad, pad)
        background = android.graphics.drawable.GradientDrawable().apply {
            cornerRadius = dp(8f)
            setColor(ContextCompat.getColor(context, R.color.thick_material))
        }
        elevation = dp(4f)
        outlineProvider = ViewOutlineProvider.BACKGROUND
        isClickable = true
        setOnClickListener { onRotate?.invoke() }
    }

    init {
        clipChildren = false
        clipToPadding = false
        addView(levelsView)
        addView(rotateButton)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val w = dp(44f).toInt()
        val levelsH = (levels.size * dp(45f)).toInt()
        levelsView.measure(MeasureSpec.makeMeasureSpec(w, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(levelsH, MeasureSpec.EXACTLY))
        rotateButton.measure(MeasureSpec.makeMeasureSpec(w, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(w, MeasureSpec.EXACTLY))
        setMeasuredDimension(w, levelsH + dp(8f).toInt() + w)
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val w = measuredWidth
        levelsView.layout(0, 0, w, levelsView.measuredHeight)
        val top = levelsView.measuredHeight + dp(8f).toInt()
        rotateButton.layout(0, top, w, top + w)
    }

    fun updateLevels(levels: Map<Int, String>, selected: Int = 0) {
        this.levels = levels
        sortedOrdinals = levels.keys.sortedDescending()
        val idx = sortedOrdinals.indexOf(selected)
        if (idx >= 0) levelsView.indicatorY.setImmediate(idx * dp(45f) + dp(22.5f))
        requestLayout()
        levelsView.invalidate()
    }

    fun changeLevel(selected: Int, animated: Boolean) {
        val position = sortedOrdinals.indexOf(selected)
        if (position < 0) return
        levelsView.indicatorY.set(position * dp(45f) + dp(22.5f), AnimRun(animated, 150))
        onChange?.invoke(selected)
    }

    private fun onLevelTap(index: Int) {
        val i = index.coerceIn(0, sortedOrdinals.size - 1)
        if (sortedOrdinals.isEmpty()) return
        changeLevel(sortedOrdinals[i], true)
    }

    private inner class LevelsView : View(context) {
        val indicatorY = AnimProp(dp(40f)) { invalidate() }
        val indicatorScale = AnimProp(1f) { invalidate() }
        private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = ContextCompat.getColor(context, R.color.thick_material) }
        private val indicatorPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = ContextCompat.getColor(context, R.color.system_gray3) }
        private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = ContextCompat.getColor(context, R.color.secondary_label)
            textSize = 17f * context.resources.displayMetrics.scaledDensity
            typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
            textAlign = Paint.Align.CENTER
        }
        private val rect = RectF()
        private var moved = false
        private var downY = 0f

        init {
            elevation = dp(4f)
            outlineProvider = object : ViewOutlineProvider() {
                override fun getOutline(view: View, outline: Outline) {
                    outline.setRoundRect(0, 0, view.width, view.height, dp(8f))
                }
            }
            isClickable = true
        }

        override fun onDraw(canvas: Canvas) {
            val w = width.toFloat(); val h = height.toFloat()
            rect.set(0f, 0f, w, h)
            canvas.drawRoundRect(rect, dp(8f), dp(8f), bgPaint)
            // indicator
            val size = w - dp(5f)
            val s = indicatorScale.value
            val cy = indicatorY.value
            rect.set(w / 2 - size / 2 * s, cy - size / 2 * s, w / 2 + size / 2 * s, cy + size / 2 * s)
            canvas.drawRoundRect(rect, dp(6.5f), dp(6.5f), indicatorPaint)
            // labels
            val fm = textPaint.fontMetrics
            val textOffset = -(fm.ascent + fm.descent) / 2
            for ((i, ordinal) in sortedOrdinals.withIndex()) {
                val label = levels[ordinal] ?: "-"
                val centerY = i * dp(45f) + dp(22.5f)
                canvas.drawText(label, w / 2, centerY + textOffset, textPaint)
            }
        }

        override fun onTouchEvent(event: MotionEvent): Boolean {
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downY = event.y
                    val cy = indicatorY.value
                    moved = kotlin.math.abs(event.y - cy) < dp(22.5f)
                    if (moved) indicatorScale.set(0.95f, AnimRun(true, 150))
                    parent?.requestDisallowInterceptTouchEvent(true)
                    return true
                }
                MotionEvent.ACTION_MOVE -> {
                    if (moved) {
                        val pos = event.y
                        val currentPos = indicatorY.target
                        fun move(dir: Int) {
                            var targetPos = currentPos + dp(45f) * dir
                            val minPos = dp(22.5f)
                            val maxPos = dp(45f) * sortedOrdinals.size - dp(22.5f)
                            targetPos = targetPos.coerceIn(minPos, max(minPos, maxPos))
                            indicatorY.set(targetPos, AnimRun(true, 150))
                        }
                        if (pos > currentPos + dp(25f)) move(1)
                        else if (pos < currentPos - dp(25f)) move(-1)
                    }
                    return true
                }
                MotionEvent.ACTION_UP -> {
                    if (moved) {
                        moved = false
                        indicatorScale.set(1f, AnimRun(true, 100, interpolator = easeOut))
                        onLevelTap(max(0, min((event.y / dp(45f)).toInt(), sortedOrdinals.size - 1)))
                    } else {
                        onLevelTap((event.y / dp(45f)).toInt())
                    }
                    performClick()
                    return true
                }
                MotionEvent.ACTION_CANCEL -> {
                    moved = false
                    indicatorScale.set(1f, AnimRun(true, 100))
                    return true
                }
            }
            return super.onTouchEvent(event)
        }

        override fun performClick(): Boolean { super.performClick(); return true }
    }
}
