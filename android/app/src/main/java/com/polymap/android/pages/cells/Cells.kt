package com.polymap.android.pages.cells

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.text.util.Linkify
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.DrawableCompat
import com.polymap.android.R
import com.polymap.android.map.annotations.AmenityAnnotation
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.EnviromentAmenityAnnotation
import com.polymap.android.map.annotations.OccupantAnnotation
import com.polymap.android.map.annotations.Searchable

fun Context.dp(v: Float): Float = v * resources.displayMetrics.density
fun Context.dpi(v: Float): Int = (v * resources.displayMetrics.density).toInt()
fun Context.col(res: Int): Int = ContextCompat.getColor(this, res)

fun TextView.style(sizeSp: Float, colorRes: Int = R.color.label, bold: Boolean = false, medium: Boolean = false) {
    setTextSize(TypedValue.COMPLEX_UNIT_SP, sizeSp)
    setTextColor(context.col(colorRes))
    typeface = when {
        bold -> Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        medium -> Typeface.create("sans-serif-medium", Typeface.NORMAL)
        else -> Typeface.DEFAULT
    }
}

enum class RowPos { SINGLE, FIRST, MIDDLE, LAST, NONE }

/** Rounded card background for inset-grouped rows. */
fun groupedBackground(context: Context, pos: RowPos, colorRes: Int = R.color.ios_bottomsheetgroupped): GradientDrawable {
    val r = context.dp(10f)
    return GradientDrawable().apply {
        setColor(context.col(colorRes))
        cornerRadii = when (pos) {
            RowPos.SINGLE -> floatArrayOf(r, r, r, r, r, r, r, r)
            RowPos.FIRST -> floatArrayOf(r, r, r, r, 0f, 0f, 0f, 0f)
            RowPos.LAST -> floatArrayOf(0f, 0f, 0f, 0f, r, r, r, r)
            RowPos.MIDDLE, RowPos.NONE -> floatArrayOf(0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f)
        }
        if (pos == RowPos.NONE) setColor(0)
    }
}

/** Thin bottom separator line drawn inside a row (UITableView separator). */
class SeparatorView(context: Context) : View(context) {
    init { setBackgroundColor(context.col(R.color.separator)) }
}

// ------------------------------------------------------------------ searchable icons

/** OccupantSearchIcon / AmenitySearchIcon port: a colored circle (or rounded square) with the sprite at 60%. */
class OccupantSearchIcon(context: Context, private val rounded: Boolean = false) : View(context) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private var icon: android.graphics.drawable.Drawable? = null
    var backgroundColorInt: Int = context.col(R.color.system_blue)
        set(value) { field = value; invalidate() }
    private val rect = RectF()

    fun configure(searchable: Searchable) {
        icon = searchable.annotationSprite?.let { ContextCompat.getDrawable(context, it)?.mutate()?.also { d -> DrawableCompat.setTint(d, 0xFFFFFFFF.toInt()) } }
        backgroundColorInt = context.col(searchable.backgroundSpriteColor)
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        val w = width.toFloat(); val h = height.toFloat()
        paint.color = backgroundColorInt
        rect.set(0f, 0f, w, h)
        val r = if (rounded) w / 4 else w / 2
        canvas.drawRoundRect(rect, r, r, paint)
        icon?.let {
            val iw = it.intrinsicWidth.toFloat(); val ih = it.intrinsicHeight.toFloat()
            val aw = w * 0.6f; val ah = h * 0.6f
            val s = minOf(aw / iw, ah / ih)
            val dw = iw * s; val dh = ih * s
            it.setBounds(((w - dw) / 2).toInt(), ((h - dh) / 2).toInt(), ((w + dw) / 2).toInt(), ((h + dh) / 2).toInt())
            it.draw(canvas)
        }
    }
}

/** AttractionSearchIcon port: circle with the building image or the short name, with a border. */
class AttractionSearchIcon(context: Context) : View(context) {
    var borderDp = 1f
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD); textAlign = Paint.Align.CENTER
        color = context.col(R.color.ios_attractionborder)
    }
    private var image: android.graphics.drawable.Drawable? = null
    private var shortTitle: String? = null
    private val rect = RectF()
    private val path = android.graphics.Path()

    fun configure(searchable: Searchable) {
        image = searchable.annotationSprite?.let { ContextCompat.getDrawable(context, it) }
        shortTitle = searchable.additionalTitle
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        val w = width.toFloat(); val h = height.toFloat()
        paint.style = Paint.Style.FILL; paint.color = context.col(R.color.ios_attractionbackground)
        canvas.drawOval(0f, 0f, w, h, paint)
        image?.let {
            canvas.save()
            path.reset(); path.addOval(0f, 0f, w, h, android.graphics.Path.Direction.CW); canvas.clipPath(path)
            it.setBounds(0, 0, width, height); it.draw(canvas)
            canvas.restore()
        } ?: run {
            textPaint.textSize = h / 2
            val fm = textPaint.fontMetrics
            canvas.drawText(shortTitle ?: "", w / 2, h / 2 - (fm.ascent + fm.descent) / 2, textPaint)
        }
        paint.style = Paint.Style.STROKE; paint.strokeWidth = context.dp(borderDp); paint.color = context.col(R.color.ios_attractionborder)
        val hw = paint.strokeWidth / 2
        canvas.drawOval(hw, hw, w - hw, h - hw, paint)
    }
}

fun createSearchIcon(context: Context, searchable: Searchable): View = when (searchable) {
    is OccupantAnnotation -> OccupantSearchIcon(context).also { it.configure(searchable) }
    is AttractionAnnotation -> AttractionSearchIcon(context).also { it.configure(searchable) }
    is AmenityAnnotation, is EnviromentAmenityAnnotation -> OccupantSearchIcon(context, rounded = true).also { it.configure(searchable) }
    else -> OccupantSearchIcon(context).also { it.configure(searchable) }
}

// ------------------------------------------------------------------ searchable cells

abstract class BaseSearchCell(context: Context) : FrameLayout(context) {
    val separator = SeparatorView(context)
    var separatorVisible: Boolean
        get() = separator.visibility == View.VISIBLE
        set(v) { separator.visibility = if (v) View.VISIBLE else View.INVISIBLE }

    abstract fun configure(searchable: Searchable)
}

/** OccupantSearchCell / AmenitySearchCell port: 35dp icon, title + "place • floor" subtitle. */
class OccupantSearchCell(context: Context, rounded: Boolean = false) : BaseSearchCell(context) {
    private val icon = OccupantSearchIcon(context, rounded)
    private val title = TextView(context).apply { style(17f); maxLines = 2 }
    private val subTitle = TextView(context).apply { style(15f, R.color.secondary_label); maxLines = 1 }

    init {
        val d = context.dpi(10f)
        addView(icon, LayoutParams(context.dpi(35f), context.dpi(35f), Gravity.START or Gravity.CENTER_VERTICAL).apply { marginStart = d })
        val col = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(title, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(subTitle, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = context.dpi(2f) })
        }
        addView(col, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL).apply {
            marginStart = context.dpi(55f); marginEnd = context.dpi(4f); topMargin = d; bottomMargin = d
        })
        addView(separator, LayoutParams(LayoutParams.MATCH_PARENT, maxOf(1, context.dpi(0.5f)), Gravity.BOTTOM).apply { marginStart = context.dpi(55f) })
        minimumHeight = context.dpi(64f)
    }

    override fun configure(searchable: Searchable) {
        title.text = searchable.mainTitle
        val longPlace = searchable.place ?: searchable.shortPlace ?: ""
        val shortPlace = searchable.shortPlace ?: longPlace
        val bestPlace = if (longPlace.length < 30) longPlace else shortPlace
        subTitle.text = "$bestPlace • ${searchable.floor ?: ""}"
        icon.configure(searchable)
    }
}

/** AttractionSearchCell / EnviromentAmenitySearchCell port: icon + single title. */
class AttractionSearchCell(context: Context, private val amenity: Boolean = false) : BaseSearchCell(context) {
    private val iconView: View = if (amenity) OccupantSearchIcon(context, rounded = true) else AttractionSearchIcon(context)
    private val title = TextView(context).apply { style(17f); maxLines = 2 }

    init {
        val d = context.dpi(10f)
        addView(iconView, LayoutParams(context.dpi(35f), context.dpi(35f), Gravity.START or Gravity.CENTER_VERTICAL).apply { marginStart = d; topMargin = d; bottomMargin = d })
        addView(title, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL).apply { marginStart = context.dpi(55f); marginEnd = context.dpi(4f) })
        addView(separator, LayoutParams(LayoutParams.MATCH_PARENT, maxOf(1, context.dpi(0.5f)), Gravity.BOTTOM).apply { marginStart = context.dpi(55f) })
        minimumHeight = context.dpi(55f)
    }

    override fun configure(searchable: Searchable) {
        title.text = searchable.mainTitle
        (iconView as? AttractionSearchIcon)?.configure(searchable)
        (iconView as? OccupantSearchIcon)?.configure(searchable)
    }
}

fun createSearchCell(context: Context, searchable: Searchable): BaseSearchCell = when (searchable) {
    is OccupantAnnotation -> OccupantSearchCell(context)
    is AttractionAnnotation -> AttractionSearchCell(context)
    is AmenityAnnotation -> OccupantSearchCell(context, rounded = true)
    is EnviromentAmenityAnnotation -> AttractionSearchCell(context, amenity = true)
    else -> OccupantSearchCell(context)
}

// ------------------------------------------------------------------ headers

/** SearchHeaderView: title 15sp semibold secondary + bottom separator. */
class SearchHeaderView(context: Context) : FrameLayout(context) {
    val title = TextView(context).apply { style(15f, R.color.secondary_label, medium = true) }
    private val separator = SeparatorView(context)

    init {
        addView(title, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply { marginStart = context.dpi(10f); topMargin = context.dpi(5f); bottomMargin = context.dpi(5f) })
        addView(separator, LayoutParams(LayoutParams.MATCH_PARENT, maxOf(1, context.dpi(0.5f)), Gravity.BOTTOM).apply { marginStart = context.dpi(10f) })
    }
}

/** SearchGroupedHeaderView: title without separator (grouped sections). */
class SearchGroupedHeaderView(context: Context) : FrameLayout(context) {
    val title = TextView(context).apply { style(15f, R.color.secondary_label, medium = true) }

    init {
        addView(title, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply { topMargin = context.dpi(5f); bottomMargin = context.dpi(10f) })
    }
}

/** TitleHeader (UnitDetail sections): 20sp semibold */
class TitleHeaderView(context: Context) : FrameLayout(context) {
    val title = TextView(context).apply { style(20f, R.color.label, medium = true) }

    init {
        addView(title, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply {
            marginStart = context.dpi(7.5f); marginEnd = context.dpi(20f); topMargin = context.dpi(15f); bottomMargin = context.dpi(8f)
        })
    }
}

// ------------------------------------------------------------------ simple cells

/** DetailCell: gray subheadline title over selectable body text with auto-detected links. */
class DetailCell(context: Context) : LinearLayout(context) {
    private val title = TextView(context).apply { style(15f, R.color.system_gray) }
    private val content = TextView(context).apply {
        style(17f)
        setLinkTextColor(context.col(R.color.accent))
        setTextIsSelectable(true)
    }

    init {
        orientation = VERTICAL
        val l = context.dpi(15f); val r = context.dpi(10f); val v = context.dpi(8f)
        setPadding(l, v, r, v)
        addView(title, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        addView(content, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
    }

    fun configure(title: String, content: String, selectable: Boolean = true) {
        this.title.text = title
        this.content.text = content
        this.content.setTextIsSelectable(selectable)
        if (selectable) Linkify.addLinks(this.content, Linkify.ALL)
    }
}

/** BaseCellTitled + ToggleCell / SimpleShareCell */
open class BaseCellTitled(context: Context) : FrameLayout(context) {
    val title = TextView(context).apply { style(17f); maxLines = 3 }
    val container = FrameLayout(context)

    init {
        addView(container, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply {
            marginStart = context.dpi(16f); marginEnd = context.dpi(10f); topMargin = context.dpi(10f); bottomMargin = context.dpi(10f)
        })
        container.addView(title, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL))
        minimumHeight = context.dpi(44f)
    }
}

class ToggleCell(context: Context) : BaseCellTitled(context) {
    val switcher = com.google.android.material.materialswitch.MaterialSwitch(context)
    var action: ((Boolean) -> Unit)? = null

    init {
        container.addView(switcher, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.END or Gravity.CENTER_VERTICAL).apply { marginEnd = context.dpi(5f) })
        (title.layoutParams as LayoutParams).marginEnd = context.dpi(70f)
        switcher.setOnCheckedChangeListener { _, isChecked -> action?.invoke(isChecked) }
        isClickable = true
        setOnClickListener { switcher.toggle() }
    }

    fun configure(title: String, value: Boolean, onToggle: ((Boolean) -> Unit)?) {
        this.title.text = title
        action = null
        switcher.isChecked = value
        action = onToggle
    }
}

class SimpleShareCell(context: Context) : BaseCellTitled(context) {
    val image = ImageView(context).apply {
        setImageResource(R.drawable.ic_sf_share)
        setColorFilter(context.col(R.color.accent))
    }

    init {
        title.text = context.getString(R.string.mapinfo_share)
        container.addView(image, LayoutParams(context.dpi(26f), context.dpi(26f), Gravity.END or Gravity.CENTER_VERTICAL).apply { marginEnd = context.dpi(5f) })
        (title.layoutParams as LayoutParams).marginEnd = context.dpi(40f)
    }
}

/** ShareAppClip cell: title + subtitle + qr icon at the right */
class ShareAppClipCell(context: Context) : FrameLayout(context) {
    init {
        val icon = ImageView(context).apply { setImageResource(R.drawable.ic_sf_qrcode); setColorFilter(context.col(R.color.accent)) }
        addView(icon, LayoutParams(context.dpi(50f), context.dpi(50f), Gravity.END or Gravity.CENTER_VERTICAL).apply { marginEnd = context.dpi(11f); topMargin = context.dpi(10f); bottomMargin = context.dpi(10f) })
        val col = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(TextView(context).apply { style(17f); text = context.getString(R.string.mapinfo_route_share_title) })
            addView(TextView(context).apply { style(12f); text = context.getString(R.string.mapinfo_route_share_appclipqr); maxLines = 2 }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = context.dpi(3f) })
        }
        addView(col, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL).apply { marginStart = context.dpi(16f); marginEnd = context.dpi(75f) })
        minimumHeight = context.dpi(70f)
    }
}

/** A "default content configuration" cell: image + text (FavoriteCell, Report cell). */
open class IconTextCell(context: Context) : FrameLayout(context) {
    val icon = ImageView(context).apply { setColorFilter(context.col(R.color.accent)) }
    val text = TextView(context).apply { style(17f) }

    init {
        addView(icon, LayoutParams(context.dpi(24f), context.dpi(24f), Gravity.START or Gravity.CENTER_VERTICAL).apply { marginStart = context.dpi(16f) })
        addView(text, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL).apply { marginStart = context.dpi(56f); marginEnd = context.dpi(16f); topMargin = context.dpi(11f); bottomMargin = context.dpi(11f) })
        minimumHeight = context.dpi(44f)
    }

    fun configure(iconRes: Int, text: String, tint: Int = context.col(R.color.accent)) {
        icon.setImageResource(iconRes); icon.setColorFilter(tint); this.text.text = text; this.text.setTextColor(context.col(R.color.label))
    }
}

/** RouteInfoCell port: Route / From / To buttons and the Plan button. */
class RouteInfoCell(context: Context) : FrameLayout(context) {
    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val w = MeasureSpec.getSize(widthMeasureSpec) - paddingLeft - paddingRight
        if (w > 0) buildingButton.maxWidth = (w * 0.45f).toInt().coerceAtLeast(context.dpi(100f))
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
    }
    enum class RouteVariant { FROM, TO, FROM_TO }
    enum class ClickVariant { FROM, TO }

    var onRouteClick: ((ClickVariant) -> Unit)? = null
    var onBuildingClick: (() -> Unit)? = null
    private var currentVariant = RouteVariant.TO

    private fun button(iconRes: Int, textRes: Int, filled: Boolean): TextView = TextView(context).apply {
        style(17f, if (filled) android.R.color.white else R.color.label, medium = true)
        text = context.getString(textRes)
        gravity = Gravity.CENTER
        compoundDrawablePadding = context.dpi(6f)
        val d = ContextCompat.getDrawable(context, iconRes)?.mutate()?.also {
            DrawableCompat.setTint(it, if (filled) 0xFFFFFFFF.toInt() else context.col(R.color.label))
            it.setBounds(0, 0, context.dpi(20f), context.dpi(20f))
        }
        setCompoundDrawables(d, null, null, null)
        background = GradientDrawable().apply {
            cornerRadius = context.dp(10f)
            setColor(context.col(if (filled) R.color.accent else R.color.ios_bottomsheetplan))
        }
        foreground = ContextCompat.getDrawable(context, android.R.drawable.list_selector_background)
        isClickable = true
        val p = context.dpi(10f); setPadding(p, 0, p, 0)
    }

    private val routeButton = button(R.drawable.ic_sf_figure_walk, R.string.mapinfo_route_route, true).apply { setOnClickListener { onRouteClick?.invoke(if (currentVariant == RouteVariant.TO) ClickVariant.TO else ClickVariant.FROM) } }
    private val fromRouteButton = button(R.drawable.ic_from, R.string.mapinfo_route_from, true).apply { setOnClickListener { onRouteClick?.invoke(ClickVariant.FROM) } }
    private val toRouteButton = button(R.drawable.ic_to, R.string.mapinfo_route_to, true).apply { setOnClickListener { onRouteClick?.invoke(ClickVariant.TO) } }
    private val buildingButton = button(R.drawable.ic_sf_plan, R.string.mapinfo_route_plan, false).apply {
        minWidth = context.dpi(100f); maxLines = 1; ellipsize = android.text.TextUtils.TruncateAt.END
        setOnClickListener { onBuildingClick?.invoke() }
    }

    private val routeRow = LinearLayout(context).apply { orientation = LinearLayout.HORIZONTAL }
    private val root = LinearLayout(context).apply { orientation = LinearLayout.HORIZONTAL }

    init {
        addView(root, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        configure(RouteVariant.TO, true)
    }

    fun configure(routeVariant: RouteVariant, showIndoor: Boolean) {
        currentVariant = routeVariant
        root.removeAllViews(); routeRow.removeAllViews()
        (routeButton.parent as? ViewGroup)?.removeView(routeButton)
        (fromRouteButton.parent as? ViewGroup)?.removeView(fromRouteButton)
        (toRouteButton.parent as? ViewGroup)?.removeView(toRouteButton)
        (buildingButton.parent as? ViewGroup)?.removeView(buildingButton)
        val h = context.dpi(46f)
        val gap = context.dpi(8f)
        if (routeVariant == RouteVariant.FROM_TO) {
            routeRow.addView(fromRouteButton, LinearLayout.LayoutParams(0, h, 1f))
            routeRow.addView(toRouteButton, LinearLayout.LayoutParams(0, h, 1f).apply { marginStart = gap })
        } else {
            routeButton.text = context.getString(if (routeVariant == RouteVariant.FROM) R.string.mapinfo_route_from else R.string.mapinfo_route_route)
            val icon = ContextCompat.getDrawable(context, if (routeVariant == RouteVariant.FROM) R.drawable.ic_from else R.drawable.ic_sf_figure_walk)?.mutate()?.also {
                DrawableCompat.setTint(it, 0xFFFFFFFF.toInt()); it.setBounds(0, 0, context.dpi(20f), context.dpi(20f))
            }
            routeButton.setCompoundDrawables(icon, null, null, null)
            routeRow.addView(routeButton, LinearLayout.LayoutParams(0, h, 1f))
        }
        if (routeVariant == RouteVariant.FROM_TO && showIndoor) {
            root.orientation = LinearLayout.VERTICAL
            root.addView(routeRow, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, h))
            root.addView(buildingButton, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, h).apply { topMargin = gap })
        } else {
            root.orientation = LinearLayout.HORIZONTAL
            root.addView(routeRow, LinearLayout.LayoutParams(0, h, 1f))
            if (showIndoor) root.addView(buildingButton, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, h).apply { marginStart = gap })
        }
    }
}

/** CreatedByCell port: footnote text with a tappable "More." suffix. */
class CreatedByCell(context: Context) : FrameLayout(context) {
    private val text = TextView(context).apply { style(13f, R.color.secondary_label); setLineSpacing(0f, 1.1f) }
    var onClick: (() -> Unit)? = null

    init {
        addView(text, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply { bottomMargin = context.dpi(15f) })
    }

    fun configure(info: String, more: String, onClick: () -> Unit) {
        this.onClick = onClick
        val s = android.text.SpannableString("$info $more")
        val start = info.length + 1
        s.setSpan(object : android.text.style.ClickableSpan() {
            override fun onClick(widget: View) { onClick() }
            override fun updateDrawState(ds: android.text.TextPaint) { ds.color = context.col(R.color.accent); ds.isUnderlineText = false }
        }, start, start + more.length, android.text.Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        text.text = s
        text.movementMethod = android.text.method.LinkMovementMethod.getInstance()
    }
}

/** ExclusiveSearchableCell: "From:"/"To:" label, 20dp icon, name */
class ExclusiveSearchableCell(context: Context) : LinearLayout(context) {
    private val title = TextView(context).apply { style(17f, R.color.secondary_label) }
    private val iconHolder = FrameLayout(context)
    private val name = TextView(context).apply { style(17f); maxLines = 1; ellipsize = android.text.TextUtils.TruncateAt.END }

    init {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        setPadding(context.dpi(15f), context.dpi(11f), context.dpi(8f), context.dpi(11f))
        addView(title)
        addView(iconHolder, LayoutParams(context.dpi(20f), context.dpi(20f)).apply { marginStart = context.dpi(2.5f) })
        addView(name, LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply { marginStart = context.dpi(2.5f) })
        minimumHeight = context.dpi(44f)
    }

    fun configure(searchable: Searchable, title: String) {
        this.title.text = title
        name.text = searchable.mainTitle
        iconHolder.removeAllViews()
        iconHolder.addView(createSearchIcon(context, searchable), FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
    }
}

/** ExclusiveCloseCell: red xmark + red text */
class ExclusiveCloseCell(context: Context) : IconTextCell(context) {
    fun configure(title: String) {
        icon.setImageResource(R.drawable.ic_sf_xmark); icon.setColorFilter(context.col(R.color.system_red))
        text.text = title; text.setTextColor(context.col(R.color.system_red))
    }
}

/** TodayCell (with progress ring): title / subtitle / time interval + icon inside a circular progress bar. */
class TodayCell(context: Context) : FrameLayout(context) {
    private val progress = CircularProgressBar(context)
    private val iconHolder = FrameLayout(context)
    private val titleLabel = TextView(context).apply { style(17f) }
    private val subTitleLabel = TextView(context).apply { style(15f, R.color.secondary_label) }
    private val subSubTitleLabel = TextView(context).apply { style(15f, R.color.secondary_label) }

    init {
        val p = context.dpi(10f)
        addView(progress, LayoutParams(context.dpi(50f), context.dpi(50f), Gravity.START or Gravity.CENTER_VERTICAL).apply { marginStart = p })
        addView(iconHolder, LayoutParams(context.dpi(40f), context.dpi(40f), Gravity.START or Gravity.CENTER_VERTICAL).apply { marginStart = p + context.dpi(5f) })
        val col = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(titleLabel); addView(subTitleLabel); addView(subSubTitleLabel)
        }
        addView(col, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL).apply { marginStart = context.dpi(70f); marginEnd = p; topMargin = p; bottomMargin = p })
    }

    fun configure(searchable: Searchable, title: String, subtitle: String?, interval: String, progressValue: Float) {
        titleLabel.text = title
        subTitleLabel.text = subtitle
        subSubTitleLabel.text = interval
        progress.progress = progressValue
        progress.visibility = if (progressValue <= 0f) View.INVISIBLE else View.VISIBLE
        iconHolder.removeAllViews()
        iconHolder.addView(createSearchIcon(context, searchable), LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
    }
}

/** CircularProgressBar port */
class CircularProgressBar(context: Context) : View(context) {
    var ringWidthDp = 5f
    var progress: Float = 0f
        set(value) { field = value; invalidate() }
    var color: Int = context.col(R.color.accent)
        set(value) { field = value; invalidate() }
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeCap = Paint.Cap.ROUND }
    private val rect = RectF()

    override fun onDraw(canvas: Canvas) {
        val sw = context.dp(ringWidthDp)
        paint.strokeWidth = sw; paint.color = color
        rect.set(sw / 2, sw / 2, width - sw / 2, height - sw / 2)
        canvas.drawArc(rect, -90f, 360f * progress.coerceIn(0f, 1f), false, paint)
    }
}
