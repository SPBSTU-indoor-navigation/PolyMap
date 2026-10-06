package com.polymap.android.bottomsheet

import android.content.Context
import android.graphics.Outline
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.view.ViewOutlineProvider
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.core.content.ContextCompat
import com.polymap.android.R
import com.polymap.android.map.HorizontalSize

/** BottomSheetPage / BluredBackgroundBottomSheetPage port. */
abstract class BottomSheetPage(context: Context) : FrameLayout(context) {
    protected val density = context.resources.displayMetrics.density
    protected fun dp(v: Float) = v * density
    protected fun color(res: Int) = ContextCompat.getColor(context, res)

    var container: BottomSheetContainer? = null

    /** the rounded "blurred" background */
    val background: FrameLayout = FrameLayout(context).apply {
        setBackgroundColor(color(R.color.thick_material))
        clipToOutline = true
        outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View, outline: Outline) {
                val r = dp(11f)
                outline.setRoundRect(0, 0, view.width, (view.height + r).toInt(), r)
            }
        }
        elevation = dp(10f)
    }

    val line: View = View(context).apply {
        background = GradientDrawable().apply {
            cornerRadius = dp(2.5f)
            setColor(color(R.color.system_gray2) and 0x00FFFFFF or (0xCC shl 24))
        }
    }

    init {
        clipChildren = false
        clipToPadding = false
        super.addView(background, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        background.addView(line, LayoutParams(dp(35f).toInt(), dp(5f).toInt(), Gravity.CENTER_HORIZONTAL or Gravity.TOP).apply { topMargin = dp(6f).toInt() })
    }

    open fun onStateChange(verticalSize: BottomSheetContainer.VerticalSize) {}
    open fun onStateChange(horizontalSize: HorizontalSize) {
        // rounded corners only at the top when the sheet spans the width
    }
    open fun onBottomSheetScroll(progress: Float) {}
    open fun onPageWillBeginScroll() {}
    open fun onPageWillEndScroll() {}
    open fun setContentBottomInset(px: Int) {}
    /** Called before the page is popped (RouteDetailVC.beforeClose etc.) */
    open fun beforeClose() {}
}

/** NavbarBottomSheetPage port: a navbar area on top of the content with an optional close button. */
abstract class NavbarBottomSheetPage(context: Context, val closable: Boolean = false, private val maximizationByNavbarClick: Boolean = true) : BottomSheetPage(context) {

    var navbarHeightDp: Float = 70f
        set(value) {
            field = value
            navbar.layoutParams = (navbar.layoutParams as LayoutParams).apply { height = dp(value).toInt() }
            (contentView.layoutParams as LayoutParams).topMargin = dp(value).toInt()
            requestLayout()
        }

    val navbar: FrameLayout = FrameLayout(context).apply { clipChildren = false }
    val contentView: FrameLayout = FrameLayout(context)
    val navbarSeparator: View = View(context).apply { setBackgroundColor(color(R.color.separator)); alpha = 0f }
    val closeButton: ImageView = ImageView(context).apply {
        setImageResource(R.drawable.ic_sf_xmark)
        setColorFilter(color(R.color.secondary_label))
        val pad = dp(7f).toInt()
        setPadding(pad, pad, pad, pad)
        background = GradientDrawable().apply { shape = GradientDrawable.OVAL; setColor(color(R.color.system_gray5)) }
        isClickable = true; isFocusable = true
        setOnClickListener { close() }
    }

    private var lastProgress = 0f

    init {
        background.addView(contentView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT).apply { topMargin = dp(navbarHeightDp).toInt() })
        background.addView(navbar, LayoutParams(LayoutParams.MATCH_PARENT, dp(navbarHeightDp).toInt()))
        navbar.addView(navbarSeparator, LayoutParams(LayoutParams.MATCH_PARENT, dp(1f).toInt(), Gravity.BOTTOM))
        if (closable) {
            navbar.addView(closeButton, LayoutParams(dp(30f).toInt(), dp(30f).toInt(), Gravity.END or Gravity.CENTER_VERTICAL).apply { marginEnd = dp(15f).toInt() })
        }
        if (maximizationByNavbarClick) {
            navbar.isClickable = true
            navbar.setOnClickListener { navbarTap() }
        }
        background.bringChildToFront(line)
    }

    fun update(progress: Float) {
        lastProgress = progress
        navbarSeparator.alpha = progress.coerceIn(0f, 1f) * contentView.alpha
    }

    open fun nextStateAfterTap(current: BottomSheetContainer.VerticalSize): BottomSheetContainer.VerticalSize? = when (current) {
        BottomSheetContainer.VerticalSize.SMALL -> BottomSheetContainer.VerticalSize.MEDIUM
        BottomSheetContainer.VerticalSize.MEDIUM -> BottomSheetContainer.VerticalSize.BIG
        else -> null
    }

    private fun navbarTap() {
        val c = container ?: return
        val vs = c.verticalSize()
        val target = nextStateAfterTap(vs)
        if (target != null && target != vs) c.change(target, true)
    }

    open fun close() {
        beforeClose()
        onClose?.invoke() ?: container?.pop(true)
    }

    /** MapInfo overrides page popping; set to intercept close. */
    var onClose: (() -> Unit)? = null

    override fun onBottomSheetScroll(progress: Float) {
        super.onBottomSheetScroll(progress)
        val limit = 0.9f
        if (progress > limit) {
            changeContentAlpha(1 - (progress - limit) / (1 - limit))
            update(lastProgress)
        } else if (contentView.alpha != 1f) {
            changeContentAlpha(1f)
            update(lastProgress)
        }
    }

    open fun changeContentAlpha(alpha: Float) {
        contentView.alpha = alpha.coerceIn(0f, 1f)
    }
}
