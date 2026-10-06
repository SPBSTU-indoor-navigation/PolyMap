package com.polymap.android.pages.cells

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.polymap.android.R
import com.polymap.android.map.annotations.AmenityAnnotation
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.EnviromentAmenityAnnotation
import com.polymap.android.map.annotations.OccupantAnnotation
import com.polymap.android.map.annotations.Searchable

/** Items of a UITableView-like list. */
sealed class ListItem(val viewType: Int) {
    /** grouped = SearchGroupedHeaderView (no separator, inset), plain = SearchHeaderView */
    class Header(val title: String, val grouped: Boolean) : ListItem(if (grouped) VT_HEADER_GROUPED else VT_HEADER_PLAIN)
    class TitleHeader(val title: String) : ListItem(VT_TITLE_HEADER)
    class SearchableRow(val searchable: Searchable, val grouped: Boolean, val pos: RowPos, val onClick: (Searchable) -> Unit) :
        ListItem(
            when (searchable) {
                is OccupantAnnotation -> VT_OCCUPANT
                is AttractionAnnotation -> VT_ATTRACTION
                is AmenityAnnotation -> VT_AMENITY
                is EnviromentAmenityAnnotation -> VT_ENV_AMENITY
                else -> VT_OCCUPANT
            }
        )
    /** A custom row: [kind] identifies the cell class, so recycled views are only reused between rows of the same class. */
    class Custom(val kind: String, val pos: RowPos, val create: (Context) -> View, val bind: (View) -> Unit, val onClick: ((View) -> Unit)? = null) : ListItem(customViewType(kind))
    class Space(val heightPx: Int) : ListItem(VT_SPACE)

    companion object {
        const val VT_HEADER_PLAIN = 1
        const val VT_HEADER_GROUPED = 2
        const val VT_TITLE_HEADER = 3
        const val VT_OCCUPANT = 4
        const val VT_ATTRACTION = 5
        const val VT_AMENITY = 6
        const val VT_ENV_AMENITY = 7
        const val VT_SPACE = 8
        const val VT_CUSTOM_BASE = 100
        private val kinds = ArrayList<String>()
        @Synchronized
        fun customViewType(kind: String): Int {
            var i = kinds.indexOf(kind)
            if (i < 0) { kinds += kind; i = kinds.size - 1 }
            return VT_CUSTOM_BASE + i
        }
    }
}

/**
 * RecyclerView adapter emulating UITableView grouped / insetGrouped styles: rows are wrapped in a container
 * with horizontal insets; grouped rows get rounded card backgrounds depending on their position in the section.
 */
class SheetListAdapter(private val context: Context) : RecyclerView.Adapter<SheetListAdapter.VH>() {
    var items: List<ListItem> = emptyList()
        set(value) { field = value; notifyDataSetChanged() }

    /** horizontal inset for grouped rows (UITableView insetGrouped layout margins) */
    var insetDp = 16f

    class VH(val wrapper: FrameLayout, val content: View) : RecyclerView.ViewHolder(wrapper)

    override fun getItemViewType(position: Int): Int = items[position].viewType

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val wrapper = FrameLayout(context).apply { layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT) }
        val content: View = when (viewType) {
            ListItem.VT_HEADER_PLAIN -> SearchHeaderView(context)
            ListItem.VT_HEADER_GROUPED -> SearchGroupedHeaderView(context)
            ListItem.VT_TITLE_HEADER -> TitleHeaderView(context)
            ListItem.VT_OCCUPANT -> OccupantSearchCell(context)
            ListItem.VT_ATTRACTION -> AttractionSearchCell(context)
            ListItem.VT_AMENITY -> OccupantSearchCell(context, rounded = true)
            ListItem.VT_ENV_AMENITY -> AttractionSearchCell(context, amenity = true)
            ListItem.VT_SPACE -> View(context)
            else -> {
                val item = items.first { it.viewType == viewType } as ListItem.Custom
                item.create(context)
            }
        }
        wrapper.addView(content, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        return VH(wrapper, content)
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: VH, position: Int) {
        val item = items[position]
        val lp = holder.content.layoutParams as FrameLayout.LayoutParams
        val inset = context.dpi(insetDp)
        holder.content.background = null
        holder.content.foreground = null
        holder.content.isClickable = false
        holder.content.setOnClickListener(null)
        when (item) {
            is ListItem.Header -> {
                (holder.content as? SearchHeaderView)?.title?.text = item.title
                (holder.content as? SearchGroupedHeaderView)?.title?.text = item.title
                lp.marginStart = if (item.grouped) inset else 0; lp.marginEnd = if (item.grouped) inset else 0
            }
            is ListItem.TitleHeader -> {
                (holder.content as TitleHeaderView).title.text = item.title
                lp.marginStart = inset; lp.marginEnd = inset
            }
            is ListItem.SearchableRow -> {
                val cell = holder.content as BaseSearchCell
                cell.configure(item.searchable)
                cell.separatorVisible = !item.grouped && item.pos != RowPos.LAST && item.pos != RowPos.SINGLE
                if (item.grouped) {
                    lp.marginStart = inset; lp.marginEnd = inset
                    cell.background = groupedBackground(context, item.pos)
                    cell.separatorVisible = item.pos == RowPos.FIRST || item.pos == RowPos.MIDDLE
                } else {
                    lp.marginStart = 0; lp.marginEnd = 0
                    cell.separatorVisible = true
                }
                cell.foreground = ContextCompat.getDrawable(context, R.drawable.row_highlight)
                cell.isClickable = true
                cell.setOnClickListener { item.onClick(item.searchable) }
            }
            is ListItem.Custom -> {
                lp.marginStart = if (item.pos == RowPos.NONE) 0 else inset
                lp.marginEnd = if (item.pos == RowPos.NONE) 0 else inset
                if (item.pos != RowPos.NONE) holder.content.background = groupedBackground(context, item.pos)
                item.bind(holder.content)
                if (item.onClick != null) {
                    holder.content.foreground = ContextCompat.getDrawable(context, R.drawable.row_highlight)
                    holder.content.isClickable = true
                    holder.content.setOnClickListener { item.onClick.invoke(holder.content) }
                }
            }
            is ListItem.Space -> {
                lp.height = item.heightPx
            }
        }
        holder.content.layoutParams = lp
    }
}

/** Helper to build grouped sections. */
fun <T> sectionRows(list: List<T>, grouped: Boolean, map: (T, RowPos) -> ListItem): List<ListItem> {
    return list.mapIndexed { i, t ->
        val pos = when {
            list.size == 1 -> RowPos.SINGLE
            i == 0 -> RowPos.FIRST
            i == list.size - 1 -> RowPos.LAST
            else -> RowPos.MIDDLE
        }
        map(t, if (grouped) pos else RowPos.NONE)
    }
}
