package com.polymap.android.pages

import android.content.Context
import android.content.Intent
import android.graphics.drawable.GradientDrawable
import android.text.InputType
import android.view.Gravity
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.polymap.android.R
import com.polymap.android.api.CodeGeneratorProvider
import com.polymap.android.api.ReportTarget
import com.polymap.android.bottomsheet.BottomSheetContainer
import com.polymap.android.bottomsheet.NavbarBottomSheetPage
import com.polymap.android.map.HorizontalSize
import com.polymap.android.map.MapViewDelegate
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.Searchable
import com.polymap.android.pages.cells.DetailCell
import com.polymap.android.pages.cells.IconTextCell
import com.polymap.android.pages.cells.ListItem
import com.polymap.android.pages.cells.RowPos
import com.polymap.android.pages.cells.ShareAppClipCell
import com.polymap.android.pages.cells.SheetListAdapter
import com.polymap.android.pages.cells.SimpleShareCell
import com.polymap.android.pages.cells.ToggleCell
import com.polymap.android.pages.cells.dp
import com.polymap.android.pages.cells.dpi
import com.polymap.android.pages.cells.style
import com.polymap.android.pathfinder.PathFinder
import com.polymap.android.pathfinder.PathResult
import com.polymap.android.storage.RouteParameters
import com.polymap.android.ui.Sheets
import java.util.UUID
import kotlin.math.ceil
import kotlin.math.max

/** Formatting helpers for PathInfo (MKDistanceFormatter / DateComponentsFormatter analogues). */
object RouteFormat {
    fun distance(context: Context, meters: Double): String {
        val locale = context.resources.configuration.locales[0]
        val ru = locale.language == "ru"
        return if (meters < 1000) "${meters.toInt()} ${if (ru) "м" else "m"}"
        else String.format(locale, "%.1f %s", meters / 1000.0, if (ru) "км" else "km")
    }

    fun minutes(context: Context, sec: Float): String {
        val m = max(1, (sec / 60f).toInt())
        val ru = context.resources.configuration.locales[0].language == "ru"
        if (!ru) return if (m == 1) "1 minute" else "$m minutes"
        val n = m % 100; val n1 = m % 10
        val word = when {
            n in 11..19 -> "минут"
            n1 == 1 -> "минута"
            n1 in 2..4 -> "минуты"
            else -> "минут"
        }
        return "$m $word"
    }

    fun timeRound(sec: Float): Float = ceil(sec / 60f) * 60f
}

/** SearchLine port: "From:"/"To:" text field with a Cancel button while searching. */
class SearchLine(context: Context) : FrameLayout(context) {
    var beginEditing: ((String) -> Unit)? = null
    var didChange: ((String) -> Unit)? = null
    var endEditingCallback: (() -> Unit)? = null

    var searchable: Searchable? = null
        private set
    var isEditing = false
    var isSearch = false
        set(value) {
            if (field == value) return
            field = value
            cancelButton.animate().alpha(if (value) 1f else 0f).setDuration(if (value) 100 else 300).start()
            (backgroundView.layoutParams as LayoutParams).marginEnd = if (value) context.dpi(70f) else 0
            backgroundView.requestLayout()
            applyCorners()
            textField.setPadding(context.dpi(4f), 0, if (value) context.dpi(30f) else context.dpi(50f), 0)
        }
    /** which corners are rounded in the normal state (top for From, bottom for To) */
    var topCorners = true
        set(value) { field = value; applyCorners() }

    val titleLabel = TextView(context).apply { style(17f, R.color.secondary_label) }
    val textField = EditText(context).apply {
        setBackgroundColor(0)
        hint = context.getString(R.string.mapinfo_route_info_search)
        style(17f)
        setHintTextColor(context.col(R.color.tertiary_label))
        inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
        imeOptions = EditorInfo.IME_ACTION_SEARCH
        isSingleLine = true
        setPadding(context.dpi(4f), 0, context.dpi(50f), 0)
    }
    private val bgDrawable = GradientDrawable().apply { setColor(context.col(R.color.ios_searchbarbackground)) }
    private val backgroundView = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        background = bgDrawable
        addView(titleLabel, LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { marginStart = context.dpi(8f) })
        addView(textField, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f))
        setOnClickListener { textField.requestFocus(); showKeyboard() }
    }
    val cancelButton = TextView(context).apply {
        text = context.getString(R.string.search_cancel)
        style(17f, R.color.accent)
        alpha = 0f
        setPadding(context.dpi(10f), context.dpi(8f), 0, context.dpi(8f))
        setOnClickListener { endSearch() }
    }

    init {
        addView(backgroundView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        addView(cancelButton, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.END or Gravity.CENTER_VERTICAL))
        applyCorners()
        textField.setOnFocusChangeListener { _, hasFocus ->
            if (hasFocus) {
                if (!isSearch) isSearch = true
                if (!isEditing) {
                    beginEditing?.invoke(textField.text.toString())
                    post { isEditing = true }
                }
                // the navbar re-layout + sheet animation started above can swallow the IME request made by the tap:
                // ask again once the transition has settled (iOS: becomeFirstResponder keeps the keyboard up)
                textField.postDelayed({ if (textField.isFocused) showKeyboard() }, 350)
            } else isEditing = false
        }
        textField.setOnEditorActionListener { _, actionId, _ -> if (actionId == EditorInfo.IME_ACTION_SEARCH) { hideKeyboard(); true } else false }
        textField.addTextChangedListener(object : android.text.TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: android.text.Editable?) { if (textField.hasFocus()) didChange?.invoke(s?.toString() ?: "") }
        })
    }

    private fun applyCorners() {
        val r = context.dp(10f)
        bgDrawable.cornerRadii = when {
            isSearch -> floatArrayOf(r, r, r, r, r, r, r, r)
            topCorners -> floatArrayOf(r, r, r, r, 0f, 0f, 0f, 0f)
            else -> floatArrayOf(0f, 0f, 0f, 0f, r, r, r, r)
        }
    }

    fun setup(searchable: Searchable?) {
        this.searchable = searchable
        setText()
    }

    private fun setText() {
        textField.setText(searchable?.mainTitle ?: "")
    }

    fun endSearch() {
        isSearch = false
        hideKeyboard()
        textField.clearFocus()
        endEditingCallback?.invoke()
        setText()
    }

    fun selectAll() { textField.selectAll() }

    private fun showKeyboard() {
        (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager).showSoftInput(textField, InputMethodManager.SHOW_IMPLICIT)
    }

    fun hideKeyboard() {
        (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager).hideSoftInputFromWindow(textField.windowToken, 0)
    }
}

private fun Context.col(res: Int) = ContextCompat.getColor(this, res)

/** RouteDetailSearchTableView: excludes the other endpoint from results */
class RouteDetailSearchTableView(context: Context) : SearchTableView(context) {
    var skipSearchable: Searchable? = null
        set(value) { field = value; process(lastSearch, force = true) }

    override fun filter(searchText: String): List<Searchable> =
        super.filter(searchText).filter { it.annotation !== skipSearchable?.annotation }
}

/** RouteDetailInfo port: sections of the route page. */
open class RouteDetailInfo(private val context: Context, var routeParams: RouteParameters, private val redrawPath: (() -> Unit)?) {
    sealed class Section {
        open val title: String? = null
        class PathInfo(val content: List<Pair<String, String>>, override val title: String) : Section()
        class Settings(override val title: String) : Section()
        class RouteShare(val from: BaseAnnotation, val to: BaseAnnotation, val params: RouteParameters) : Section()
        class Report(val report: ReportTarget) : Section()
        class FromTo(val from: Searchable, val to: Searchable) : Section()
        class Close(val onClose: () -> Unit) : Section()
    }

    val sections = ArrayList<Section>()
    var result: PathResult? = null
        private set

    fun onParamsUpdate() {
        routeParams.saveToStorage()
        redrawPath?.invoke()
    }

    fun pathInfoSection(result: PathResult): Section.PathInfo {
        val content = ArrayList<Pair<String, String>>()
        content += context.getString(R.string.mapinfo_route_info_distance) to RouteFormat.distance(context, result.totalDistance)
        val time = RouteFormat.minutes(context, max(60f, RouteFormat.timeRound(result.time)))
        val fastTime = RouteFormat.minutes(context, max(60f, RouteFormat.timeRound(result.fastTime)))
        content += context.getString(R.string.mapinfo_route_info_time) to time
        if (time != fastTime) content += context.getString(R.string.mapinfo_route_info_fasttime) to fastTime
        if (result.indoorDistance > 0 && result.outdoorDistance > 0) {
            content += context.getString(R.string.mapinfo_route_info_indoor) to RouteFormat.distance(context, result.indoorDistance)
            content += context.getString(R.string.mapinfo_route_info_outdoor) to RouteFormat.distance(context, result.outdoorDistance)
        }
        return Section.PathInfo(content, context.getString(R.string.mapinfo_route_info_routeinformation))
    }

    open fun configure(result: PathResult?) {
        this.result = result
        sections.clear()
        result?.let { sections += pathInfoSection(it) }
        sections += Section.Settings(context.getString(R.string.mapinfo_route_info_parameters))
        if (result != null) {
            sections += Section.RouteShare(result.from, result.to, routeParams)
            sections += Section.Report(ReportTarget.Route(result.from, result.to, routeParams))
        }
    }
}

/** RouteDetailVC port. */
class RouteDetailPage(context: Context, val mapViewDelegate: MapViewDelegate, searchable: List<Searchable>) : NavbarBottomSheetPage(context, closable = true) {
    enum class State { NORMAL, FROM, TO }

    var fromAnnotation: BaseAnnotation? = null
    var toAnnotation: BaseAnnotation? = null
    var routeParams: RouteParameters = RouteParameters.fromStorage
    private var beforeCloseComplete = false
    var routeDetailInfo: RouteDetailInfo? = null
        private set
    var state = State.NORMAL
        private set
    private var focusAfterChangeSize: PathResult? = null
    var pathID: UUID? = null
        private set
    private var verticalSizeBeforeSearch: BottomSheetContainer.VerticalSize? = null
    var searchable: List<Searchable> = searchable
        set(value) { field = value; searchTableView.searchable = value }

    private val titleLabel = TextView(context).apply { text = context.getString(R.string.mapinfo_route_info_title); style(29f, R.color.label, bold = true) }
    private val separator = View(context).apply { setBackgroundColor(color(R.color.separator)) }
    private val changeDirection = ImageView(context).apply {
        setImageResource(R.drawable.ic_sf_swap)
        setColorFilter(color(R.color.accent))
        val p = context.dpi(11f); setPadding(p, p, p, p)
        background = GradientDrawable().apply { shape = GradientDrawable.OVAL; setColor(color(R.color.ios_bottomsheetgroupped)) }
        elevation = dp(1f)
        isClickable = true
        setOnClickListener { changeDirectionTap() }
    }
    val searchFrom = SearchLine(context).apply {
        topCorners = true
        titleLabel.text = context.getString(R.string.mapinfo_route_info_from)
        endEditingCallback = { cancelEditing() }
        didChange = { onSearchEdit(it) }
        beginEditing = { beginEditing(State.FROM, it) }
    }
    val searchTo = SearchLine(context).apply {
        topCorners = false
        titleLabel.text = context.getString(R.string.mapinfo_route_info_to)
        endEditingCallback = { cancelEditing() }
        didChange = { onSearchEdit(it) }
        beginEditing = { beginEditing(State.TO, it) }
    }
    private val container_ = FrameLayout(context)
    private val recycler = RecyclerView(context).apply { layoutManager = LinearLayoutManager(context); clipToPadding = false; isNestedScrollingEnabled = true }
    private val adapter = SheetListAdapter(context)
    private val searchTableView = RouteDetailSearchTableView(context).apply { alpha = 0f; visibility = View.INVISIBLE; this.searchable = searchable }

    init {
        navbarHeightDp = 155f
        navbar.addView(titleLabel, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply { marginStart = context.dpi(16f); topMargin = context.dpi(15f); marginEnd = context.dpi(55f) })
        (closeButton.layoutParams as LayoutParams).apply { gravity = Gravity.END or Gravity.TOP; topMargin = context.dpi(15f); marginEnd = context.dpi(16f) }
        navbar.addView(container_, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        container_.addView(searchFrom, LayoutParams(LayoutParams.MATCH_PARENT, context.dpi(40f)).apply { marginStart = context.dpi(16f); marginEnd = context.dpi(16f); topMargin = context.dpi(60f) })
        container_.addView(searchTo, LayoutParams(LayoutParams.MATCH_PARENT, context.dpi(40f)).apply { marginStart = context.dpi(16f); marginEnd = context.dpi(16f); topMargin = context.dpi(100f) })
        container_.addView(separator, LayoutParams(LayoutParams.MATCH_PARENT, context.dpi(1f)).apply { marginStart = context.dpi(16f); marginEnd = context.dpi(16f); topMargin = context.dpi(100f) })
        container_.addView(changeDirection, LayoutParams(context.dpi(45f), context.dpi(45f), Gravity.END).apply { marginEnd = context.dpi(25f); topMargin = context.dpi(100f - 22.5f) })
        navbar.bringChildToFront(closeButton)
        recycler.adapter = adapter
        contentView.addView(recycler, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        contentView.addView(searchTableView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        recycler.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(rv: RecyclerView, dx: Int, dy: Int) { update(rv.computeVerticalScrollOffset() / dp(20f)) }
        })
        searchTableView.onScrolled = { update(it.computeVerticalScrollOffset() / dp(20f)) }
        searchTableView.onBeginDrag = { searchFrom.hideKeyboard(); searchTo.hideKeyboard() }
        searchTableView.onSelect = { s -> searchTableDidSelect(s) }
        navbar.isClickable = true
    }

    override fun setContentBottomInset(px: Int) {
        recycler.setPadding(0, 0, 0, px)
        searchTableView.recycler.setPadding(0, 0, 0, px)
    }

    override fun nextStateAfterTap(current: BottomSheetContainer.VerticalSize): BottomSheetContainer.VerticalSize? =
        if (state == State.NORMAL) super.nextStateAfterTap(current) else null

    private fun beginEditing(state: State, text: String) {
        if (this.state != State.NORMAL && this.state != state) {
            post {
                searchFrom.endSearch(); searchTo.endSearch()
                changeState(State.NORMAL)
            }
        } else {
            verticalSizeBeforeSearch = container?.verticalSize()
            container?.change(BottomSheetContainer.VerticalSize.BIG, true)
            changeState(state)
            // the field opens pre-filled with the current point's title; searching for it would show
            // "nothing found" (entrances etc. are not searchable) — show the full list instead
            val line = if (state == State.FROM) searchFrom else searchTo
            searchTableView.process(if (text == (line.searchable?.mainTitle ?: "")) "" else text, force = true)
        }
    }

    private fun cancelEditing() {
        changeState(State.NORMAL)
        val c = container ?: return
        if (c.horizontalSize() == HorizontalSize.BIG && c.verticalSize() == BottomSheetContainer.VerticalSize.BIG) {
            val size = verticalSizeBeforeSearch ?: BottomSheetContainer.VerticalSize.MEDIUM
            c.change(if (size != BottomSheetContainer.VerticalSize.SMALL) size else BottomSheetContainer.VerticalSize.MEDIUM, true)
        }
    }

    private fun changeState(state: State) {
        if (this.state == state) return
        if (state != State.NORMAL) searchTableView.skipSearchable = if (state == State.FROM) searchTo.searchable else searchFrom.searchable
        searchTableView.visibility = View.VISIBLE
        val normalEnable = if (state == State.NORMAL) 1f else 0f

        if (state == State.NORMAL) {
            changeDirection.animate().alpha(1f).scaleX(1f).scaleY(1f).setStartDelay(200).setDuration(100).start()
        } else {
            changeDirection.animate().alpha(0f).scaleX(0.7f).scaleY(0.7f).setStartDelay(0).setDuration(100).start()
        }

        // navbar layout: normal = 155dp with both fields; editing = 70dp with the edited field on top
        val editing = state != State.NORMAL
        val fromLp = searchFrom.layoutParams as LayoutParams
        val toLp = searchTo.layoutParams as LayoutParams
        if (editing) {
            navbarHeightDp = 70f
            val lp = if (state == State.FROM) fromLp else toLp
            lp.topMargin = context.dpi(17f); lp.height = context.dpi(36f)
        } else {
            navbarHeightDp = 155f
            fromLp.topMargin = context.dpi(60f); fromLp.height = context.dpi(40f)
            toLp.topMargin = context.dpi(100f); toLp.height = context.dpi(40f)
        }
        searchFrom.requestLayout(); searchTo.requestLayout()

        closeButton.animate().alpha(normalEnable).setDuration(300).start()
        titleLabel.animate().alpha(normalEnable).setDuration(300).start()
        separator.animate().alpha(normalEnable).setDuration(300).start()
        recycler.animate().alpha(normalEnable).setDuration(300).start()
        searchFrom.animate().alpha(if (state != State.TO) 1f else 0f).setDuration(300).start()
        searchTo.animate().alpha(if (state != State.FROM) 1f else 0f).setDuration(300).start()
        searchTableView.animate().alpha(if (state != State.NORMAL) 1f else 0f).setDuration(300).withEndAction {
            if (state == State.TO) searchTo.selectAll()
            if (state == State.FROM) searchFrom.selectAll()
            searchTableView.visibility = if (state == State.NORMAL) View.INVISIBLE else View.VISIBLE
            if (state == State.NORMAL) { searchTo.isEditing = false; searchFrom.isEditing = false }
        }.start()
        closeButton.isClickable = !editing
        this.state = state
    }

    private var changeDirectionAnimate = false

    private fun changeDirectionTap() {
        if (changeDirectionAnimate) return
        changeDirectionAnimate = true
        changeDirection.animate().rotation(180f).setDuration(200).start()
        val dy = dp(40f)
        searchTo.textField.animate().translationY(-dy).setDuration(200).start()
        searchFrom.textField.animate().translationY(dy).setDuration(200).withEndAction {
            changeDirection.rotation = 0f
            searchFrom.textField.translationY = 0f; searchTo.textField.translationY = 0f
            val t = fromAnnotation; fromAnnotation = toAnnotation; toAnnotation = t
            drawPath()
            changeDirectionAnimate = false
        }.start()
    }

    override fun onBottomSheetScroll(progress: Float) {
        super.onBottomSheetScroll(progress)
        if (container?.isUserDragging != true) return
        if (searchFrom.isEditing) searchFrom.hideKeyboard()
        if (searchTo.isEditing) searchTo.hideKeyboard()
    }

    override fun changeContentAlpha(alpha: Float) {
        super.changeContentAlpha(alpha)
        container_.alpha = alpha
    }

    override fun onStateChange(verticalSize: BottomSheetContainer.VerticalSize) {
        super.onStateChange(verticalSize)
        if (verticalSize == BottomSheetContainer.VerticalSize.SMALL) {
            if (searchFrom.isSearch) searchFrom.isSearch = false
            if (searchTo.isSearch) searchTo.isSearch = false
            changeState(State.NORMAL)
        }
        val result = focusAfterChangeSize
        if (result != null && verticalSize != BottomSheetContainer.VerticalSize.BIG) {
            post { mapViewDelegate.focus(result) }
            focusAfterChangeSize = null
        }
    }

    override fun beforeClose() {
        super.beforeClose()
        if (beforeCloseComplete) return
        beforeCloseComplete = true
        toPoint = null; fromPoint = null
        focusAfterChangeSize = null
        post {
            listOfNotNull(toAnnotation, fromAnnotation).forEach { mapViewDelegate.unpinAnnotation(it, true) }
            pathID?.let { id ->
                if (fromAnnotation == null) currentVenueDefaultStart()?.let { mapViewDelegate.unpinAnnotation(it, true) }
                mapViewDelegate.removePath(id)
            }
        }
    }

    private fun currentVenueDefaultStart(): BaseAnnotation? = com.polymap.android.MainActivity.currentVenue?.defaultPathStartPoint

    private fun onSearchEdit(text: String) = searchTableView.process(text)

    private fun searchTableDidSelect(searchable: Searchable) {
        val annotation = searchable.annotation
        if (state == State.TO) { searchTo.endSearch(); setTo(annotation) }
        else if (state == State.FROM) { searchFrom.endSearch(); setFrom(annotation) }
    }

    // ------------------------------------------------------------------ RouteDetail protocol

    fun setFrom(annotation: BaseAnnotation) {
        fromPoint?.let { mapViewDelegate.unpinAnnotation(it, true) }
        mapViewDelegate.pinAnnotation(annotation, true)
        fromAnnotation = annotation
        drawPath()
    }

    fun setTo(annotation: BaseAnnotation) {
        toPoint?.let { mapViewDelegate.unpinAnnotation(it, true) }
        mapViewDelegate.pinAnnotation(annotation, true)
        mapViewDelegate.deselectAnnotation(annotation, true)
        toAnnotation = annotation
        drawPath()
    }

    fun setup(from: BaseAnnotation, to: BaseAnnotation, routeParams: RouteParameters) {
        fromPoint?.let { mapViewDelegate.unpinAnnotation(it, true) }
        toPoint?.let { mapViewDelegate.unpinAnnotation(it, true) }
        this.fromAnnotation = from; this.toAnnotation = to; this.routeParams = routeParams
        mapViewDelegate.pinAnnotation(from, true); mapViewDelegate.pinAnnotation(to, true)
        mapViewDelegate.deselectAnnotation(from, true); mapViewDelegate.deselectAnnotation(to, true)
        val info = routeDetailInfo
        if (info != null) { info.routeParams = routeParams; reload() } else drawPath()
    }

    fun drawPath() {
        fromAnnotation = fromAnnotation ?: currentVenueDefaultStart()
        val from = fromAnnotation ?: return
        val to = toAnnotation ?: return
        fromPoint = from; toPoint = to
        searchFrom.setup(from); searchTo.setup(to)
        pathID?.let { mapViewDelegate.removePath(it) }
        listOf(to, from).forEach { mapViewDelegate.pinAnnotation(it, true) }

        val result = PathFinder.shared.findPath(from, to, routeParams.denyTags)
        val info = routeDetailInfo ?: RouteDetailInfo(context, routeParams, { drawPath() }).also { routeDetailInfo = it }
        info.routeParams = routeParams
        info.configure(result)
        reload()

        if (result != null) {
            pathID = mapViewDelegate.addPath(result.path)
            val c = container
            if (c != null && c.horizontalSize() == HorizontalSize.BIG && c.verticalSize() == BottomSheetContainer.VerticalSize.BIG) {
                focusAfterChangeSize = result
            } else {
                mapViewDelegate.focus(result)
            }
        } else pathID = null
    }

    private fun reload() {
        val info = routeDetailInfo ?: return
        adapter.items = buildItems(context, info, container, mapViewDelegate)
    }

    companion object {
        var toPoint: BaseAnnotation? = null
        var fromPoint: BaseAnnotation? = null

        /** Builds list items for RouteDetailInfo sections (shared with the exclusive page). */
        fun buildItems(context: Context, info: RouteDetailInfo, container: BottomSheetContainer?, mapViewDelegate: MapViewDelegate?, allowParameterChange: Boolean = true): List<ListItem> {
            val items = ArrayList<ListItem>()
            fun rowPos(i: Int, n: Int) = when { n == 1 -> RowPos.SINGLE; i == 0 -> RowPos.FIRST; i == n - 1 -> RowPos.LAST; else -> RowPos.MIDDLE }
            for ((sIdx, section) in info.sections.withIndex()) {
                section.title?.let { if (!(sIdx == 0 && section is RouteDetailInfo.Section.FromTo)) items += ListItem.Header(it, grouped = true) }
                when (section) {
                    is RouteDetailInfo.Section.PathInfo -> {
                        section.content.forEachIndexed { i, (t, c) ->
                            items += ListItem.Custom("DetailCell", rowPos(i, section.content.size), { ctx -> DetailCell(ctx) }, { v -> (v as DetailCell).configure(t, c, selectable = false) })
                        }
                    }
                    is RouteDetailInfo.Section.Settings -> {
                        items += ListItem.Custom("ToggleCell", RowPos.FIRST, { ctx -> ToggleCell(ctx) }, { v ->
                            (v as ToggleCell).configure(context.getString(R.string.mapinfo_route_info_asphalt), info.routeParams.asphalt) { info.routeParams.asphalt = it; if (allowParameterChange) info.onParamsUpdate() }
                        })
                        items += ListItem.Custom("ToggleCell", RowPos.LAST, { ctx -> ToggleCell(ctx) }, { v ->
                            (v as ToggleCell).configure(context.getString(R.string.mapinfo_route_info_serviceroute), info.routeParams.serviceRoute) { info.routeParams.serviceRoute = it; if (allowParameterChange) info.onParamsUpdate() }
                        })
                    }
                    is RouteDetailInfo.Section.RouteShare -> {
                        items += ListItem.Custom("SimpleShareCell", RowPos.FIRST, { ctx -> SimpleShareCell(ctx) }, { }, onClick = {
                            val link = CodeGeneratorProvider.createPermalink(section.from.imdfID, section.to.imdfID, section.params)
                            val intent = Intent(Intent.ACTION_SEND).apply { type = "text/plain"; putExtra(Intent.EXTRA_TEXT, link) }
                            context.startActivity(Intent.createChooser(intent, null))
                        })
                        items += ListItem.Custom("ShareAppClipCell", RowPos.LAST, { ctx -> ShareAppClipCell(ctx) }, { }, onClick = {
                            Sheets.showShareDialog(context, section.from, section.to, section.params)
                        })
                    }
                    is RouteDetailInfo.Section.Report -> {
                        items += ListItem.Custom("IconTextCell", RowPos.SINGLE, { ctx -> IconTextCell(ctx) }, { v ->
                            (v as IconTextCell).configure(R.drawable.ic_sf_report, context.getString(R.string.mapinfo_report_issue))
                        }, onClick = { Sheets.showReportIssue(context, section.report) })
                    }
                    is RouteDetailInfo.Section.FromTo -> {
                        items += ListItem.Custom("ExclusiveSearchableCell", RowPos.FIRST, { ctx -> com.polymap.android.pages.cells.ExclusiveSearchableCell(ctx) }, { v ->
                            (v as com.polymap.android.pages.cells.ExclusiveSearchableCell).configure(section.from, context.getString(R.string.mapinfo_route_info_from))
                        })
                        items += ListItem.Custom("ExclusiveSearchableCell", RowPos.LAST, { ctx -> com.polymap.android.pages.cells.ExclusiveSearchableCell(ctx) }, { v ->
                            (v as com.polymap.android.pages.cells.ExclusiveSearchableCell).configure(section.to, context.getString(R.string.mapinfo_route_info_to))
                        })
                    }
                    is RouteDetailInfo.Section.Close -> {
                        items += ListItem.Custom("ExclusiveCloseCell", RowPos.SINGLE, { ctx -> com.polymap.android.pages.cells.ExclusiveCloseCell(ctx) }, { v ->
                            (v as com.polymap.android.pages.cells.ExclusiveCloseCell).configure(context.getString(R.string.mapinfo_exclroute_info_close))
                        }, onClick = { section.onClose() })
                    }
                }
                items += ListItem.Space(context.dpi(20f))
            }
            return items
        }
    }
}
