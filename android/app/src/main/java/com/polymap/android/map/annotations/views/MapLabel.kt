package com.polymap.android.map.annotations.views

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.view.View
import kotlin.math.ceil
import kotlin.math.min

/** UILabel with an outline stroke (MapLabel port). Multi-line, centered. */
class MapLabel(context: Context) : View(context) {
    private val density = context.resources.displayMetrics.density

    var text: String? = null
        set(value) { if (field != value) { field = value; rebuild() } }
    var textColor: Int = 0xFF000000.toInt()
        set(value) { field = value; invalidate() }
    var strokeColor: Int = 0xCC000000.toInt()
        set(value) { field = value; invalidate() }
    var strokeSize: Float = 1.5f
        set(value) { field = value; rebuild() }
    var textSizeSp: Float = 12f
        set(value) { field = value; rebuild() }
    var bold: Boolean = false
        set(value) { field = value; rebuild() }
    var maxWidthDp: Float = 120f
        set(value) { field = value; rebuild() }
    var singleLine: Boolean = false
        set(value) { field = value; rebuild() }

    private val paint = TextPaint(Paint.ANTI_ALIAS_FLAG)
    private var layout: StaticLayout? = null
    private var layoutWidth = 0

    val isEmpty: Boolean get() = text.isNullOrEmpty()

    private fun rebuild() {
        val t = text
        if (t.isNullOrEmpty()) { layout = null; requestLayout(); invalidate(); return }
        paint.textSize = textSizeSp * context.resources.displayMetrics.scaledDensity
        paint.typeface = if (bold) Typeface.create(Typeface.DEFAULT, Typeface.BOLD) else Typeface.create("sans-serif-medium", Typeface.NORMAL)
        val maxW = (maxWidthDp * density).toInt()
        val measured = ceil(paint.measureText(t)).toInt()
        layoutWidth = if (singleLine) measured else min(measured, maxW)
        layout = StaticLayout.Builder.obtain(t, 0, t.length, paint, layoutWidth.coerceAtLeast(1))
            .setAlignment(Layout.Alignment.ALIGN_CENTER)
            .setIncludePad(false)
            .setMaxLines(if (singleLine) 1 else 4)
            .build()
        requestLayout(); invalidate()
    }

    private val pad: Int get() = ceil(strokeSize * density).toInt() + 1

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val l = layout
        if (l == null) { setMeasuredDimension(0, 0); return }
        setMeasuredDimension(l.width + pad * 2, l.height + pad * 2)
    }

    override fun onDraw(canvas: Canvas) {
        val l = layout ?: return
        canvas.save()
        canvas.translate(pad.toFloat(), pad.toFloat())
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = strokeSize * density
        paint.strokeJoin = Paint.Join.ROUND
        paint.color = strokeColor
        l.draw(canvas)
        paint.style = Paint.Style.FILL
        paint.color = textColor
        l.draw(canvas)
        canvas.restore()
    }
}
