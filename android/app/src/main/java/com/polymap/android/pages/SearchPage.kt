package com.polymap.android.pages

import android.content.Context
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
import com.polymap.android.bottomsheet.BottomSheetContainer
import com.polymap.android.bottomsheet.NavbarBottomSheetPage
import com.polymap.android.map.FocusVariant
import com.polymap.android.map.HorizontalSize
import com.polymap.android.map.MapInfoDelegate
import com.polymap.android.map.MapViewDelegate
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.OccupantAnnotation
import com.polymap.android.map.annotations.Searchable
import com.polymap.android.pages.cells.ListItem
import com.polymap.android.pages.cells.RowPos
import com.polymap.android.pages.cells.SheetListAdapter
import com.polymap.android.pages.cells.dp
import com.polymap.android.pages.cells.dpi
import com.polymap.android.pages.cells.sectionRows
import com.polymap.android.pages.cells.style
import com.polymap.android.storage.FavoritesStorage
import com.polymap.android.storage.SearchHistoryStorage

/** UISearchBar (minimal style) analogue with a Cancel button. */
class SearchBarView(context: Context) : LinearLayout(context) {
    val field = EditText(context).apply {
        setBackgroundColor(0)
        hint = context.getString(R.string.choosingsearchcontroller_searchplaceholder)
        style(17f)
        setHintTextColor(context.col(R.color.tertiary_label))
        inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
        imeOptions = EditorInfo.IME_ACTION_SEARCH
        isSingleLine = true
        setPadding(0, 0, 0, 0)
    }
    val clearButton = ImageView(context).apply {
        setImageResource(R.drawable.ic_sf_clear)
        setColorFilter(context.col(R.color.system_gray))
        visibility = View.GONE
        setOnClickListener { field.setText("") }
    }
    val cancelButton = TextView(context).apply {
        text = context.getString(R.string.search_cancel)
        style(17f, R.color.accent)
        visibility = View.GONE
        setPadding(context.dpi(12f), context.dpi(8f), 0, context.dpi(8f))
    }
    private val container = LinearLayout(context).apply {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        background = GradientDrawable().apply { cornerRadius = context.dp(10f); setColor(context.col(R.color.ios_searchbarbackground)) }
        val icon = ImageView(context).apply { setImageResource(R.drawable.ic_sf_search); setColorFilter(context.col(R.color.system_gray)) }
        addView(icon, LayoutParams(context.dpi(20f), context.dpi(20f)).apply { marginStart = context.dpi(8f) })
        addView(field, LayoutParams(0, ViewGroup_MATCH, 1f).apply { marginStart = context.dpi(6f) })
        addView(clearButton, LayoutParams(context.dpi(18f), context.dpi(18f)).apply { marginEnd = context.dpi(8f); marginStart = context.dpi(4f) })
    }

    init {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        setPadding(context.dpi(16f), 0, context.dpi(16f), 0)
        addView(container, LayoutParams(0, context.dpi(36f), 1f))
        addView(cancelButton, LayoutParams(ViewGroup_WRAP, ViewGroup_WRAP))
        field.addTextChangedListener(object : android.text.TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: android.text.Editable?) { clearButton.visibility = if (s.isNullOrEmpty()) View.GONE else View.VISIBLE }
        })
    }

    fun setShowsCancelButton(show: Boolean) { cancelButton.visibility = if (show) View.VISIBLE else View.GONE }

    fun showKeyboard() {
        (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager).showSoftInput(field, InputMethodManager.SHOW_IMPLICIT)
    }

    fun endEditing() {
        field.clearFocus()
        (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager).hideSoftInputFromWindow(field.windowToken, 0)
    }

    companion object {
        private const val ViewGroup_MATCH = android.view.ViewGroup.LayoutParams.MATCH_PARENT
        private const val ViewGroup_WRAP = android.view.ViewGroup.LayoutParams.WRAP_CONTENT
    }
}

private fun Context.col(res: Int) = ContextCompat.getColor(this, res)

/** natural (numeric-aware, case-insensitive) string compare like NSString .numeric */
fun naturalCompare(a: String, b: String): Int {
    val x = a.lowercase(); val y = b.lowercase()
    var i = 0; var j = 0
    while (i < x.length && j < y.length) {
        val cx = x[i]; val cy = y[j]
        if (cx.isDigit() && cy.isDigit()) {
            var ni = i; while (ni < x.length && x[ni].isDigit()) ni++
            var nj = j; while (nj < y.length && y[nj].isDigit()) nj++
            val nx = x.substring(i, ni).trimStart('0'); val ny = y.substring(j, nj).trimStart('0')
            if (nx.length != ny.length) return nx.length - ny.length
            val c = nx.compareTo(ny); if (c != 0) return c
            i = ni; j = nj
        } else {
            if (cx != cy) return cx.compareTo(cy)
            i++; j++
        }
    }
    return (x.length - i) - (y.length - j)
}

/** SearchTableView comparator port */
fun searchComparator(searchText: String): Comparator<Searchable> = Comparator { lhs, rhs ->
    val lt = lhs.mainTitle ?: return@Comparator 1
    val rt = rhs.mainTitle ?: return@Comparator -1
    val li = lt.lowercase().indexOf(searchText); val ri = rt.lowercase().indexOf(searchText)
    if (li < 0 || ri < 0) naturalCompare(lt, rt) else if (li == ri) naturalCompare(lt, rt) else li - ri
}

/** SearchTableView port: search results grouped as Buildings + occupants by building. */
open class SearchTableView(context: Context) : FrameLayout(context) {
    val recycler = RecyclerView(context).apply {
        layoutManager = LinearLayoutManager(context)
        clipToPadding = false
        isNestedScrollingEnabled = true
    }
    val adapter = SheetListAdapter(context)
    var onSelect: ((Searchable) -> Unit)? = null
    var onScrolled: ((RecyclerView) -> Unit)? = null
    var onBeginDrag: (() -> Unit)? = null

    var searchable: List<Searchable> = emptyList()
        set(value) { field = value; process(lastSearch, force = true) }
    var lastSearch: String = " "
        private set
    var sections: List<Pair<String, List<Searchable>>> = emptyList()
        private set

    private val emptyResult = TextView(context).apply {
        style(16f, R.color.secondary_label)
        text = context.getString(R.string.mapinfo_search_emptysearchresult)
        visibility = View.GONE
    }

    init {
        recycler.adapter = adapter
        addView(recycler, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        addView(emptyResult, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_HORIZONTAL or Gravity.TOP).apply { topMargin = context.dpi(50f) })
        recycler.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(rv: RecyclerView, dx: Int, dy: Int) { onScrolled?.invoke(rv) }
            override fun onScrollStateChanged(rv: RecyclerView, newState: Int) { if (newState == RecyclerView.SCROLL_STATE_DRAGGING) onBeginDrag?.invoke() }
        })
        process("")
    }

    open fun filter(searchText: String): List<Searchable> =
        if (searchText.isEmpty()) searchable else searchable.filter { s -> s.mainTitle?.lowercase()?.contains(searchText) == true }

    fun process(searchText: String = "", force: Boolean = false) {
        val text = searchText.lowercase().trim()
        if (text == lastSearch && !force) return
        lastSearch = text
        val filtered = filter(text)
        val result = ArrayList<Pair<String, List<Searchable>>>()
        val buildings = filtered.filter { it is AttractionAnnotation }.sortedWith(searchComparator(text))
        if (buildings.isNotEmpty()) result += context.getString(R.string.mapinfo_search_buildings) to buildings
        val occupants = filtered.filter { it is OccupantAnnotation }
        for ((place, group) in occupants.groupBy { it.place }) {
            result += (place ?: "-") to group.sortedWith(searchComparator(text))
        }
        sections = result
        val items = ArrayList<ListItem>()
        for ((title, list) in result) {
            items += ListItem.Header(title, grouped = false)
            items += sectionRows(list, grouped = false) { s, pos -> ListItem.SearchableRow(s, false, pos) { sel -> onSelect?.invoke(sel) } }
        }
        adapter.items = items
        emptyResult.visibility = if (result.isEmpty()) View.VISIBLE else View.GONE
    }
}

/** MainSearchTableView + MainSearchData port: Today / Recent / Favorites / Recommendation. */
class MainSearchTableView(context: Context) : FrameLayout(context) {
    val recycler = RecyclerView(context).apply {
        layoutManager = LinearLayoutManager(context)
        clipToPadding = false
        isNestedScrollingEnabled = true
    }
    val adapter = SheetListAdapter(context)
    var onSelect: ((Searchable) -> Unit)? = null
    var onScrolled: ((RecyclerView) -> Unit)? = null
    var onBeginDrag: (() -> Unit)? = null

    private var recent: List<Searchable> = emptyList()
    private var favorites: List<Searchable> = emptyList()
    private var recomendation: List<Searchable> = emptyList()

    var searchable: List<Searchable> = emptyList()
        set(value) { field = value; process() }

    init {
        recycler.adapter = adapter
        addView(recycler, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        recycler.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(rv: RecyclerView, dx: Int, dy: Int) { onScrolled?.invoke(rv) }
            override fun onScrollStateChanged(rv: RecyclerView, newState: Int) { if (newState == RecyclerView.SCROLL_STATE_DRAGGING) onBeginDrag?.invoke() }
        })
        FavoritesStorage.shared.onAdd.addHandler { a -> favorites = favorites + a; reload() }
        FavoritesStorage.shared.onRemove.addHandler { a -> favorites = favorites.filter { it !== a }; reload() }
        SearchHistoryStorage.shared.onHistoryChange.addHandler { h ->
            recent = h
            postDelayed({ reload() }, 500)
        }
    }

    private fun process() {
        recent = SearchHistoryStorage.shared.history
        favorites = FavoritesStorage.shared.favorites
        if (recent.isEmpty() || favorites.isEmpty()) {
            recomendation = listOf("главное учебное", "бульвар", "белый зал", "читальный", "main academic", "bulvar", "white concert", "reading hall").mapNotNull { title ->
                searchable.filter { it.mainTitle?.lowercase()?.contains(title) == true }.sortedBy { it.floor ?: "" }.firstOrNull()
            }
        }
        reload()
    }

    private fun reload() {
        val sections = ArrayList<Pair<String, List<Searchable>>>()
        if (recent.isNotEmpty()) sections += context.getString(R.string.mapinfo_search_recent) to recent
        if (favorites.isNotEmpty()) sections += context.getString(R.string.mapinfo_search_favorites) to favorites
        if (sections.size < 2) sections += context.getString(R.string.mapinfo_search_recomendation) to recomendation
        val items = ArrayList<ListItem>()
        for ((title, list) in sections) {
            if (list.isEmpty()) continue
            items += ListItem.Header(title, grouped = true)
            items += sectionRows(list, grouped = true) { s, pos -> ListItem.SearchableRow(s, true, pos) { sel -> onSelect?.invoke(sel) } }
            items += ListItem.Space(context.dpi(20f))
        }
        adapter.items = items
    }
}

/** SearchVC port: the root page of the bottom sheet. */
class SearchPage(context: Context) : NavbarBottomSheetPage(context, closable = false) {
    var mapViewDelegate: MapViewDelegate? = null
    var mapInfoDelegate: MapInfoDelegate? = null

    var isSearch = false
        set(value) {
            field = value
            searchTableView.visibility = View.VISIBLE; mainTableView.visibility = View.VISIBLE
            searchTableView.animate().alpha(if (value) 1f else 0f).setDuration(200).withEndAction { searchTableView.visibility = if (isSearch) View.VISIBLE else View.INVISIBLE }.start()
            mainTableView.animate().alpha(if (value) 0f else 1f).setDuration(200).withEndAction { mainTableView.visibility = if (isSearch) View.INVISIBLE else View.VISIBLE }.start()
        }
    private var verticalSizeBeforeSearch: BottomSheetContainer.VerticalSize? = null

    var searchable: List<Searchable> = emptyList()
        set(value) { field = value; searchTableView.searchable = value; mainTableView.searchable = value }

    val searchBar = SearchBarView(context)
    val mainTableView = MainSearchTableView(context)
    val searchTableView = SearchTableView(context).apply { alpha = 0f; visibility = View.INVISIBLE }

    init {
        navbar.addView(searchBar, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL))
        contentView.addView(searchTableView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        contentView.addView(mainTableView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))

        searchBar.field.setOnFocusChangeListener { _, hasFocus ->
            if (hasFocus) {
                searchBarShouldBeginEditing()
                searchBar.field.postDelayed({ if (searchBar.field.isFocused && container?.isUserDragging != true) searchBar.showKeyboard() }, 350)
            }
        }
        searchBar.field.setOnClickListener { if (!isSearch) searchBarShouldBeginEditing() }
        searchBar.cancelButton.setOnClickListener { searchBarCancelButtonClicked() }
        searchBar.field.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_SEARCH) { searchBar.endEditing(); true } else false
        }
        searchBar.field.addTextChangedListener(object : android.text.TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: android.text.Editable?) { searchTableView.process(s?.toString() ?: "") }
        })

        mainTableView.onSelect = { select(it.annotation) }
        searchTableView.onSelect = { select(it.annotation); searchBar.endEditing() }
        mainTableView.onScrolled = { didScroll(it) }
        searchTableView.onScrolled = { didScroll(it) }
        searchTableView.onBeginDrag = { searchBar.endEditing() }
    }

    override fun setContentBottomInset(px: Int) {
        mainTableView.recycler.setPadding(0, 0, 0, px)
        searchTableView.recycler.setPadding(0, 0, 0, px)
    }

    private fun didScroll(rv: RecyclerView) {
        update(rv.computeVerticalScrollOffset() / dp(20f))
    }

    override fun nextStateAfterTap(current: BottomSheetContainer.VerticalSize): BottomSheetContainer.VerticalSize? =
        if (!isSearch) super.nextStateAfterTap(current) else null

    fun cancelEdit() {
        searchBar.setShowsCancelButton(false)
        searchBar.field.setText("")
        searchBar.endEditing()
        isSearch = false
        searchTableView.process()
    }

    override fun onStateChange(verticalSize: BottomSheetContainer.VerticalSize) {
        super.onStateChange(verticalSize)
        if (isSearch && verticalSize == BottomSheetContainer.VerticalSize.SMALL) cancelEdit()
    }

    override fun onBottomSheetScroll(progress: Float) {
        super.onBottomSheetScroll(progress)
        if (isSearch && container?.isUserDragging == true) searchBar.endEditing()
    }

    private fun select(annotation: BaseAnnotation) {
        mapInfoDelegate?.select(annotation)
        mapViewDelegate?.focusAndSelect(annotation, FocusVariant.CENTER)
    }

    private fun searchBarShouldBeginEditing() {
        if (isSearch) return
        searchBar.setShowsCancelButton(true)
        verticalSizeBeforeSearch = container?.verticalSize()
        container?.change(BottomSheetContainer.VerticalSize.BIG, true)
        isSearch = true
    }

    private fun searchBarCancelButtonClicked() {
        cancelEdit()
        val c = container ?: return
        if (c.horizontalSize() == HorizontalSize.BIG && c.verticalSize() == BottomSheetContainer.VerticalSize.BIG) {
            val size = verticalSizeBeforeSearch ?: BottomSheetContainer.VerticalSize.MEDIUM
            c.change(if (size != BottomSheetContainer.VerticalSize.SMALL) size else BottomSheetContainer.VerticalSize.MEDIUM, true)
        }
    }
}
