package com.polymap.android.pages

import android.content.Context
import android.content.Intent
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.polymap.android.R
import com.polymap.android.api.CodeGeneratorProvider
import com.polymap.android.api.ReportTarget
import com.polymap.android.bottomsheet.BottomSheetContainer
import com.polymap.android.bottomsheet.NavbarBottomSheetPage
import com.polymap.android.map.MapViewDelegate
import com.polymap.android.map.annotations.AmenityAnnotation
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.EnviromentAmenityAnnotation
import com.polymap.android.map.annotations.OccupantAnnotation
import com.polymap.android.map.overlays.Building
import com.polymap.android.pages.cells.CreatedByCell
import com.polymap.android.pages.cells.DetailCell
import com.polymap.android.pages.cells.IconTextCell
import com.polymap.android.pages.cells.ListItem
import com.polymap.android.pages.cells.RouteInfoCell
import com.polymap.android.pages.cells.RowPos
import com.polymap.android.pages.cells.SheetListAdapter
import com.polymap.android.pages.cells.SimpleShareCell
import com.polymap.android.pages.cells.dpi
import com.polymap.android.pages.cells.style
import com.polymap.android.imdf.IMDF
import com.polymap.android.storage.FavoritesStorage
import com.polymap.android.ui.Sheets

/** UnitDetailInfo port: the sections shown for an annotation. */
class UnitDetailInfo(val annotation: BaseAnnotation) {
    sealed class Section {
        open val title: String? = null
        class Route(val showRoute: Boolean, val showIndoor: Boolean, val annotation: BaseAnnotation) : Section() {
            val building: Building? get() = (annotation as? AttractionAnnotation)?.building
        }
        class Detail(val content: List<Pair<String, String>>, override val title: String?) : Section()
        class Share(val annotation: BaseAnnotation) : Section()
        class Report(val favorite: BaseAnnotation?, val report: ReportTarget?) : Section()
        class CreatedBy(val authors: IMDF.Author) : Section()
    }

    var title: String = ""
    val sections = ArrayList<Section>()

    init {
        val ctx = com.polymap.android.App.instance
        when (annotation) {
            is OccupantAnnotation -> {
                title = annotation.properties.name?.bestLocalizedValue ?: annotation.title ?: "-"
                sections += Section.Route(showRoute = true, showIndoor = false, annotation = annotation)
                val content = ArrayList<Pair<String, String>>()
                annotation.properties.phone?.let { content += ctx.getString(R.string.mapinfo_detail_phone) to it }
                annotation.properties.email?.let { content += ctx.getString(R.string.mapinfo_detail_email) to it }
                annotation.properties.website?.let { content += ctx.getString(R.string.mapinfo_detail_website) to it }
                annotation.address?.let { content += ctx.getString(R.string.mapinfo_detail_address) to it.addressString() }
                sections += Section.Detail(content, ctx.getString(R.string.mapinfo_detail_title))
                sections += Section.Share(annotation)
                sections += Section.Report(annotation, ReportTarget.Annotation(annotation))
            }
            is AmenityAnnotation -> {
                title = annotation.properties.name?.bestLocalizedValue ?: annotation.title ?: "-"
                sections += Section.Route(true, false, annotation)
                sections += Section.Report(annotation, ReportTarget.Annotation(annotation))
            }
            is EnviromentAmenityAnnotation -> {
                title = annotation.properties.name?.bestLocalizedValue ?: annotation.title ?: "-"
                sections += Section.Route(true, false, annotation)
                sections += Section.Report(annotation, ReportTarget.Annotation(annotation))
            }
            is AttractionAnnotation -> {
                title = annotation.properties.name?.bestLocalizedValue ?: annotation.title ?: "-"
                sections += Section.Route(true, true, annotation)
                sections += Section.Share(annotation)
                sections += Section.Report(annotation, ReportTarget.Annotation(annotation))
                annotation.properties.authors?.let { sections += Section.CreatedBy(it) }
            }
        }
    }
}

/** UnitDetailVC port. */
class UnitDetailPage(context: Context, var mapViewDelegate: MapViewDelegate?) : NavbarBottomSheetPage(context, closable = true) {
    var unitDetailInfo: UnitDetailInfo? = null
        private set
    var showRouteButton = true
        private set

    private val titleTopOffset = 14f
    private var useTitleTransition = false
    private var titleHeight = 0

    private val titleLabel = TextView(context).apply { style(29f, R.color.label, bold = true) }
    private val titleNavbarLabel = TextView(context).apply { style(20f, R.color.label, bold = true); alpha = 0f; maxLines = 1 }
    private val recycler = RecyclerView(context).apply {
        layoutManager = LinearLayoutManager(context)
        clipToPadding = false
        isNestedScrollingEnabled = true
    }
    private val adapter = SheetListAdapter(context)

    /** callbacks wired by MapInfo */
    var onRouteTo: ((BaseAnnotation) -> Unit)? = null
    var onRouteFrom: ((BaseAnnotation) -> Unit)? = null

    init {
        navbarHeightDp = 60f
        navbar.clipChildren = true
        background.addView(titleLabel, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply {
            topMargin = dp(titleTopOffset).toInt(); marginStart = context.dpi(16f); marginEnd = context.dpi(16f + 30f + 5f)
        })
        navbar.addView(titleNavbarLabel, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL).apply {
            marginStart = context.dpi(16f); marginEnd = context.dpi(16f + 30f + 5f)
        })
        background.bringChildToFront(navbar)
        background.bringChildToFront(line)
        recycler.adapter = adapter
        contentView.addView(recycler, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        recycler.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(rv: RecyclerView, dx: Int, dy: Int) { didScroll(rv.computeVerticalScrollOffset().toFloat()) }
        })
        titleLabel.addOnLayoutChangeListener { v, _, top, _, bottom, _, _, _, _ ->
            val h = bottom - top
            if (h != titleHeight && h > 0) {
                titleHeight = h
                val newUse = h > dp(40f)
                if (newUse != useTitleTransition) { useTitleTransition = newUse; reload() }
                else if (useTitleTransition) reload()
            }
        }
    }

    override fun setContentBottomInset(px: Int) { recycler.setPadding(0, 0, 0, px) }

    fun configure(info: UnitDetailInfo, showRouteButton: Boolean = true) {
        this.showRouteButton = showRouteButton
        if (!showRouteButton) info.sections.removeAll { it is UnitDetailInfo.Section.Route }
        unitDetailInfo = info
        titleLabel.text = info.title
        titleNavbarLabel.text = info.title
        reload()
    }

    fun buildingPlanOpen(attraction: AttractionAnnotation) {
        container?.change(BottomSheetContainer.VerticalSize.SMALL, true)
        mapViewDelegate?.focus(attraction)
    }

    private fun didScroll(offset: Float) {
        if (useTitleTransition) {
            titleLabel.translationY = -offset
            val spacer = titleHeight - dp(navbarHeightDp) + dp(titleTopOffset) + dp(3f)
            val a = ((offset - spacer) / dp(30f)).coerceIn(0f, 1f)
            titleLabel.alpha = 1 - a
            titleNavbarLabel.alpha = ((offset - spacer - dp(20f)) / dp(30f)).coerceIn(0f, 1f)
            update(a)
        } else {
            titleLabel.translationY = 0f
            update(offset)
        }
    }

    private fun reload() {
        val info = unitDetailInfo ?: run { adapter.items = emptyList(); return }
        val items = ArrayList<ListItem>()
        if (useTitleTransition) {
            items += ListItem.Space((titleHeight - dp(navbarHeightDp) + dp(titleTopOffset) + dp(3f)).toInt().coerceAtLeast(0))
        }
        for (section in info.sections) {
            section.title?.let { items += ListItem.TitleHeader(it) }
            when (section) {
                is UnitDetailInfo.Section.Route -> {
                    items += ListItem.Custom("RouteInfoCell", RowPos.NONE, { c -> RouteInfoCell(c).apply { setPadding(c.dpi(16f), 0, c.dpi(16f), 0) } }, { v ->
                        val cell = v as RouteInfoCell
                        val to = RouteDetailPage.toPoint; val from = RouteDetailPage.fromPoint
                        val variant = when {
                            to != null && from != null -> if (from === section.annotation) RouteInfoCell.RouteVariant.FROM else if (to === section.annotation) RouteInfoCell.RouteVariant.TO else RouteInfoCell.RouteVariant.FROM_TO
                            to != null -> RouteInfoCell.RouteVariant.TO
                            from != null -> if (from === section.annotation) RouteInfoCell.RouteVariant.FROM else RouteInfoCell.RouteVariant.TO
                            else -> RouteInfoCell.RouteVariant.TO
                        }
                        cell.configure(variant, section.showIndoor)
                        cell.onRouteClick = { click ->
                            if (click == RouteInfoCell.ClickVariant.TO) onRouteTo?.invoke(section.annotation) else onRouteFrom?.invoke(section.annotation)
                        }
                        cell.onBuildingClick = {
                            val b = section.building
                            if (b == null || b.levels.isEmpty()) {
                                Sheets.showEmptyBuildingPlan(context, section.annotation.mainTitle ?: "-")
                            } else {
                                (section.annotation as? AttractionAnnotation)?.let { buildingPlanOpen(it) }
                            }
                        }
                    })
                    items += ListItem.Space(context.dpi(20f))
                }
                is UnitDetailInfo.Section.Detail -> {
                    if (section.content.isEmpty()) continue
                    section.content.forEachIndexed { i, (t, c) ->
                        val pos = rowPos(i, section.content.size)
                        items += ListItem.Custom("DetailCell", pos, { ctx -> DetailCell(ctx) }, { v -> (v as DetailCell).configure(t, c) })
                    }
                    items += ListItem.Space(context.dpi(20f))
                }
                is UnitDetailInfo.Section.Share -> {
                    items += ListItem.Custom("SimpleShareCell", RowPos.SINGLE, { ctx -> SimpleShareCell(ctx) }, { }, onClick = {
                        val link = CodeGeneratorProvider.createPermalink(section.annotation.imdfID)
                        val intent = Intent(Intent.ACTION_SEND).apply { type = "text/plain"; putExtra(Intent.EXTRA_TEXT, link) }
                        context.startActivity(Intent.createChooser(intent, null))
                    })
                    items += ListItem.Space(context.dpi(20f))
                }
                is UnitDetailInfo.Section.Report -> {
                    val rows = ArrayList<ListItem>()
                    val count = (if (section.favorite != null) 1 else 0) + (if (section.report != null) 1 else 0)
                    var idx = 0
                    section.favorite?.let { fav ->
                        val pos = rowPos(idx++, count)
                        rows += ListItem.Custom("IconTextCell", pos, { ctx -> IconTextCell(ctx) }, { v ->
                            val isFav = FavoritesStorage.shared.contains(fav)
                            (v as IconTextCell).configure(
                                if (isFav) R.drawable.ic_sf_star_slash else R.drawable.ic_sf_star,
                                context.getString(if (isFav) R.string.mapinfo_report_favorites_remove else R.string.mapinfo_report_favorites_add)
                            )
                        }, onClick = { v ->
                            if (FavoritesStorage.shared.contains(fav)) FavoritesStorage.shared.removeFavorites(fav) else FavoritesStorage.shared.addFavorites(fav)
                            val isFav = FavoritesStorage.shared.contains(fav)
                            (v as IconTextCell).configure(
                                if (isFav) R.drawable.ic_sf_star_slash else R.drawable.ic_sf_star,
                                context.getString(if (isFav) R.string.mapinfo_report_favorites_remove else R.string.mapinfo_report_favorites_add)
                            )
                        })
                    }
                    section.report?.let { rep ->
                        val pos = rowPos(idx++, count)
                        rows += ListItem.Custom("IconTextCell", pos, { ctx -> IconTextCell(ctx) }, { v ->
                            (v as IconTextCell).configure(R.drawable.ic_sf_report, context.getString(R.string.mapinfo_report_issue))
                        }, onClick = { Sheets.showReportIssue(context, rep) })
                    }
                    items += rows
                    items += ListItem.Space(context.dpi(20f))
                }
                is UnitDetailInfo.Section.CreatedBy -> {
                    items += ListItem.Custom("CreatedByCell", RowPos.NONE, { ctx -> CreatedByCell(ctx).apply { setPadding(ctx.dpi(16f), 0, ctx.dpi(16f), 0) } }, { v ->
                        (v as CreatedByCell).configure(section.authors.shortInfo.bestLocalizedValue ?: "", context.getString(R.string.mapinfo_detail_moreinfo)) {
                            Sheets.showCreatedBy(context, section.authors)
                        }
                    })
                }
            }
        }
        adapter.items = items
    }

    private fun rowPos(i: Int, n: Int) = when {
        n == 1 -> RowPos.SINGLE
        i == 0 -> RowPos.FIRST
        i == n - 1 -> RowPos.LAST
        else -> RowPos.MIDDLE
    }

    /** Re-bind the route cell (from/to points changed). */
    fun refresh() = reload()
}
