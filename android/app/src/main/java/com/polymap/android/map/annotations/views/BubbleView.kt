package com.polymap.android.map.annotations.views

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.drawable.Drawable
import android.view.View
import androidx.core.graphics.drawable.DrawableCompat

/**
 * Rounded rectangle "pin" body with an optional tail (the CAShapeLayer path in the iOS annotation views),
 * a border, and an optional tinted icon inset. Everything is drawn in one View so scale transforms
 * apply to the whole pin like the iOS `background`/`point` view hierarchy.
 */
class BubbleView(context: Context) : View(context) {
    private val density = context.resources.displayMetrics.density

    var fillColor: Int = 0xFF007AFF.toInt()
        set(value) { field = value; invalidate() }
    var borderColor: Int = 0
        set(value) { field = value; invalidate() }
    var borderWidthDp: Float = 0f
        set(value) { field = value; invalidate() }
    var cornerRadiusDp: Float = 5f
        set(value) { field = value; invalidate() }
    /** tail width / height in dp at scale 1 */
    var tailWidthDp: Float = 2f
    var tailHeightDp: Float = 1f
    /** 0..1: scaleY of the tail (iOS `shape.transform`). */
    var tailProgress: Float = 0f
        set(value) { field = value; invalidate() }
    var tailColor: Int? = null
    var icon: Drawable? = null
        set(value) {
            field = value?.mutate()?.also { DrawableCompat.setTint(it, iconTint) }
            iconCache.clear()
            invalidate()
        }
    var iconTint: Int = 0xFFFFFFFF.toInt()
        set(value) { field = value; icon?.let { DrawableCompat.setTint(it, value) }; iconCache.clear(); invalidate() }
    var iconInsetDp: Float = 3f
        set(value) { field = value; invalidate() }
    var iconAlpha: Float = 1f
        set(value) { field = value; invalidate() }
    /** Circle clipped image drawn over the whole body (attraction photos). */
    var image: Drawable? = null
        set(value) { field = value; invalidate() }

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val iconCache = HashMap<Int, android.graphics.Bitmap>()
    private var iconCacheKey: Drawable? = null
    private val iconRect = RectF()
    private val bitmapPaint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
    private val path = Path()
    private val rect = RectF()

    override fun onDraw(canvas: Canvas) {
        val w = width.toFloat(); val h = height.toFloat()
        val r = cornerRadiusDp * density
        rect.set(0f, 0f, w, h)

        // tail (drawn first, below body)
        if (tailProgress > 0.001f) {
            val tw = tailWidthDp * density
            val th = tailHeightDp * density * tailProgress
            path.reset()
            path.moveTo(w / 2 - tw / 2, h - r / 2)
            path.quadTo(w / 2 - tw / 4, h - r / 2 + th * 0.55f, w / 2, h + th)
            path.quadTo(w / 2 + tw / 4, h - r / 2 + th * 0.55f, w / 2 + tw / 2, h - r / 2)
            path.close()
            paint.style = Paint.Style.FILL
            paint.color = tailColor ?: fillColor
            canvas.drawPath(path, paint)
        }

        paint.style = Paint.Style.FILL
        paint.color = fillColor
        canvas.drawRoundRect(rect, r, r, paint)

        image?.let { img ->
            canvas.save()
            path.reset(); path.addRoundRect(rect, r, r, Path.Direction.CW)
            canvas.clipPath(path)
            img.setBounds(0, 0, width, height)
            img.draw(canvas)
            canvas.restore()
        }

        icon?.let { ic ->
            if (iconAlpha > 0.001f) {
                val inset = iconInsetDp * density
                val iw = ic.intrinsicWidth.toFloat(); val ih = ic.intrinsicHeight.toFloat()
                val aw = w - inset * 2; val ah = h - inset * 2
                val scale = minOf(aw / iw, ah / ih)
                val dw = iw * scale; val dh = ih * scale
                val left = (w - dw) / 2; val top = (h - dh) / 2
                // The selected pin is scaled x2.5 via View.scale; a VectorDrawable rasterizes at its unscaled
                // bounds and the GPU then upscales that bitmap (blurry). Pre-render the icon at the on-screen scale
                // into our own bitmap and draw it filtered, so the scaled pin stays crisp.
                // Rasterize at the size the icon actually occupies on screen (view scale, quantized to 1/4 steps,
                // at least 1x), so at the rest states (x1, x1.2, x2.5) texels map 1:1 to pixels.
                val vs = (kotlin.math.ceil(maxOf(scaleX, scaleY, 1f) * 4f) / 4f).coerceAtMost(4f)
                val bw = (dw * vs).toInt().coerceAtLeast(1); val bh = (dh * vs).toInt().coerceAtLeast(1)
                if (iconCacheKey !== ic) { iconCache.clear(); iconCacheKey = ic }
                val bmp = iconCache.getOrPut(bw * 10000 + bh) {
                    if (iconCache.size > 8) iconCache.clear()
                    android.graphics.Bitmap.createBitmap(bw, bh, android.graphics.Bitmap.Config.ARGB_8888).also { b ->
                        val c2 = Canvas(b)
                        ic.setBounds(0, 0, bw, bh); ic.alpha = 255; ic.draw(c2)
                    }
                }
                iconRect.set(left, top, left + dw, top + dh)
                bitmapPaint.colorFilter = android.graphics.PorterDuffColorFilter(iconTint, android.graphics.PorterDuff.Mode.SRC_IN)
                bitmapPaint.alpha = (iconAlpha * 255).toInt()
                canvas.drawBitmap(bmp, null, iconRect, bitmapPaint)
            }
        }

        if (borderWidthDp > 0f && (borderColor ushr 24) != 0) {
            paint.style = Paint.Style.STROKE
            paint.strokeWidth = borderWidthDp * density
            paint.color = borderColor
            val hw = paint.strokeWidth / 2
            rect.set(hw, hw, w - hw, h - hw)
            canvas.drawRoundRect(rect, r - hw, r - hw, paint)
        }
    }
}
