package com.polymap.android.pages

import android.content.Context
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.polymap.android.R
import com.polymap.android.bottomsheet.NavbarBottomSheetPage
import com.polymap.android.map.MapViewDelegate
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.pages.cells.SheetListAdapter
import com.polymap.android.pages.cells.dpi
import com.polymap.android.pages.cells.style
import com.polymap.android.pathfinder.PathFinder
import com.polymap.android.pathfinder.PathResult
import com.polymap.android.storage.RouteParameters
import java.util.UUID

/** ExclusiveRouteDetailInfo port */
class ExclusiveRouteDetailInfo(context: Context, routeParams: RouteParameters, var allowParameterChange: Boolean, redrawPath: (() -> Unit)?, private val onExclusiveClose: () -> Unit) :
    RouteDetailInfo(context, routeParams, redrawPath) {

    override fun configure(result: PathResult?) {
        sections.clear()
        if (result != null) {
            sections += Section.FromTo(result.from, result.to)
            sections += pathInfoSection(result)
        }
        if (allowParameterChange) sections += Section.Settings(com.polymap.android.App.instance.getString(R.string.mapinfo_route_info_parameters))
        sections += Section.Close(onExclusiveClose)
    }
}

/** ExclusiveRouteDetailVC port: route opened from an invitation link, not closable via the navbar. */
class ExclusiveRoutePage(context: Context, val mapViewDelegate: MapViewDelegate) : NavbarBottomSheetPage(context, closable = false) {
    var routeDetailInfo: ExclusiveRouteDetailInfo? = null
        private set
    var pathID: UUID? = null
        private set
    var from: BaseAnnotation? = null
    var to: BaseAnnotation? = null
    var routeParams: RouteParameters? = null
    var allowParameterChange: Boolean? = null

    private val titleLabel = TextView(context).apply { text = context.getString(R.string.mapinfo_route_info_title); style(29f, R.color.label, bold = true) }
    private val recycler = RecyclerView(context).apply { layoutManager = LinearLayoutManager(context); clipToPadding = false; isNestedScrollingEnabled = true }
    private val adapter = SheetListAdapter(context)

    init {
        navbar.addView(titleLabel, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL).apply { marginStart = context.dpi(16f); marginEnd = context.dpi(16f) })
        recycler.adapter = adapter
        contentView.addView(recycler, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        recycler.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(rv: RecyclerView, dx: Int, dy: Int) { update(rv.computeVerticalScrollOffset() / dp(20f)) }
        })
    }

    override fun setContentBottomInset(px: Int) { recycler.setPadding(0, 0, 0, px) }

    override fun beforeClose() {
        super.beforeClose()
        RouteDetailPage.toPoint = null; RouteDetailPage.fromPoint = null
        post {
            listOfNotNull(to, from).forEach { mapViewDelegate.unpinAnnotation(it, true) }
            pathID?.let { mapViewDelegate.removePath(it) }
        }
    }

    private fun closeAlert() {
        com.google.android.material.dialog.MaterialAlertDialogBuilder(context)
            .setTitle(R.string.mapinfo_exclroute_info_closealert_title)
            .setMessage(R.string.mapinfo_exclroute_info_closealert_message)
            .setNegativeButton(R.string.mapinfo_exclroute_info_closealert_cancel, null)
            .setPositiveButton(R.string.mapinfo_exclroute_info_closealert_end) { _, _ -> close() }
            .show()
    }

    fun show(from: BaseAnnotation, to: BaseAnnotation, routeParams: RouteParameters, allowParameterChange: Boolean) {
        this.routeParams = routeParams
        this.allowParameterChange = allowParameterChange
        listOfNotNull(this.to, this.from).forEach { mapViewDelegate.unpinAnnotation(it, true) }
        this.from = from; this.to = to
        listOf(to, from).forEach { mapViewDelegate.pinAnnotation(it, true) }
        val info = routeDetailInfo
        if (info != null) {
            info.allowParameterChange = allowParameterChange
            info.routeParams = routeParams
            info.configure(info.result)
            reload()
        } else drawPath()
    }

    fun drawPath() {
        val from = from ?: return
        val to = to ?: return
        pathID?.let { mapViewDelegate.removePath(it) }
        val result = PathFinder.shared.findPath(from, to, routeParams?.denyTags ?: emptyList())
        if (result != null) {
            pathID = mapViewDelegate.addPath(result.path)
            mapViewDelegate.focus(result)
        } else pathID = null

        val info = routeDetailInfo
        if (info != null) {
            info.configure(result)
        } else if (result != null) {
            routeDetailInfo = ExclusiveRouteDetailInfo(context, routeParams ?: RouteParameters(false, false), allowParameterChange ?: false, { drawPath() }) { closeAlert() }
                .also { it.configure(result) }
        }
        reload()
    }

    private fun reload() {
        val info = routeDetailInfo ?: return
        adapter.items = RouteDetailPage.buildItems(context, info, container, mapViewDelegate, allowParameterChange = false)
    }
}
