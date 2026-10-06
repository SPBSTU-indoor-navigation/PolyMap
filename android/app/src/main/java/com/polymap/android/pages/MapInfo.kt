package com.polymap.android.pages

import android.content.Context
import android.graphics.RectF
import com.polymap.android.bottomsheet.BottomSheetContainer
import com.polymap.android.bottomsheet.BottomSheetPage
import com.polymap.android.map.HorizontalSize
import com.polymap.android.map.MapInfoDelegate
import com.polymap.android.map.MapViewDelegate
import com.polymap.android.map.FocusVariant
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.map.annotations.Searchable
import com.polymap.android.storage.RouteParameters
import com.polymap.android.storage.SearchHistoryStorage

/** RouteDetail protocol */
interface RouteDetail {
    fun setFrom(annotation: BaseAnnotation)
    fun setTo(annotation: BaseAnnotation)
    fun setup(from: BaseAnnotation, to: BaseAnnotation, routeParams: RouteParameters)
}

/** ExclusiveRouteDetail protocol */
interface ExclusiveRouteDetail {
    fun show(from: BaseAnnotation, to: BaseAnnotation, routeParams: RouteParameters, allowParameterChange: Boolean)
    fun currentRoute(): Pair<Pair<BaseAnnotation, BaseAnnotation>, Pair<RouteParameters, Boolean>>?
}

/** MapInfo port: coordinates the bottom sheet pages with the map. */
class MapInfo(private val context: Context, val container: BottomSheetContainer) : MapInfoDelegate, RouteDetail, ExclusiveRouteDetail {
    enum class Page { SEARCH, ANNOTATION_INFO, ROUTE, EXCLUSIVE_ROUTE, UNKNOWN }

    var searchable: List<Searchable> = emptyList()
        set(value) { field = value; searchPage.searchable = value; routeDetailPage?.searchable = value }

    val pages = ArrayList<Page>()

    var mapViewDelegate: MapViewDelegate? = null
        set(value) {
            field = value
            searchPage.mapViewDelegate = value
            container.pages.filterIsInstance<UnitDetailPage>().forEach { it.mapViewDelegate = value }
        }

    private var startZoom = 0f
    private var lastZoomChange = 0L
    private var zoomHidden = false
    private var currentSelection: BaseAnnotation? = null
    private var skipSelectStateChange = false

    var routeDetailPage: RouteDetailPage? = null
        private set
    var exclusiveRoutePage: ExclusiveRoutePage? = null
        private set
    val searchPage = SearchPage(context)

    private val hidingEnable: Boolean
        get() = !(container.moved || container.movedByScroll) && container.currentSize == HorizontalSize.BIG && container.state == BottomSheetContainer.VerticalSize.MEDIUM

    init {
        searchPage.mapInfoDelegate = this
        push(searchPage, false)
        routeDetail = this
        exclusiveRouteDetail = this
    }

    // ------------------------------------------------------------------ navigation

    private fun push(page: BottomSheetPage, animated: Boolean) {
        container.push(page, animated)
        pages += when (page) {
            is UnitDetailPage -> Page.ANNOTATION_INFO
            is RouteDetailPage -> Page.ROUTE
            is ExclusiveRoutePage -> Page.EXCLUSIVE_ROUTE
            is SearchPage -> Page.SEARCH
            else -> Page.UNKNOWN
        }
    }

    fun pop(animated: Boolean): BottomSheetPage? {
        val top = container.pages.lastOrNull() ?: return null
        if (container.pages.size <= 1) return null
        top.beforeClose()
        val popped = container.pop(animated) ?: return null
        if (pages.lastOrNull() == Page.ANNOTATION_INFO) mapViewDelegate?.deselectAnnotation(currentSelection, true)
        pages.removeAt(pages.size - 1)
        container.pages.lastOrNull()?.let { onPopTo(it) }
        onPop(popped)
        return popped
    }

    fun popTo(page: BottomSheetPage, animated: Boolean) {
        val idx = container.pages.indexOf(page)
        if (idx < 0) return
        val toPop = container.pages.subList(idx + 1, container.pages.size).toList()
        if (toPop.isNotEmpty() && pages.lastOrNull() == Page.ANNOTATION_INFO) mapViewDelegate?.deselectAnnotation(currentSelection, true)
        for (p in toPop.reversed()) {
            p.beforeClose()
            container.pop(animated && p === toPop.last())
            pages.removeAt(pages.size - 1)
            onPop(p)
        }
        onPopTo(page)
    }

    private fun onPop(page: BottomSheetPage) {
        when (page) {
            is RouteDetailPage -> { routeDetailPage?.beforeClose(); routeDetailPage = null }
            is ExclusiveRoutePage -> { exclusiveRoutePage?.beforeClose(); exclusiveRoutePage = null }
            else -> {}
        }
    }

    private fun onPopTo(page: BottomSheetPage) {
        if (page is UnitDetailPage) {
            page.refresh()
            val annotation = page.unitDetailInfo?.annotation
            if (annotation != null) {
                skipSelectStateChange = true
                skipSelectStateChange = mapViewDelegate?.focusAndSelect(annotation, FocusVariant.AUTO) ?: false
            }
        }
    }

    // ------------------------------------------------------------------ MapInfoDelegate

    override fun zoomMap(zoom: Float, animated: Boolean) {
        if (animated) return
        val now = System.currentTimeMillis()
        if (now - lastZoomChange > 300) { startZoom = zoom; zoomHidden = false }
        lastZoomChange = now
        if (kotlin.math.abs(zoom - startZoom) > 0.5f) {
            if (hidingEnable && !zoomHidden) container.changeState(BottomSheetContainer.VerticalSize.SMALL)
            zoomHidden = true
        }
    }

    override fun panAction(translationY: Float, locationY: Float) {
        if (hidingEnable) {
            // location relative to the sheet top: collapse when dragging down near/below the sheet
            if (translationY > 0 && locationY - container.sheetTop > -50 * context.resources.displayMetrics.density) {
                container.changeState(BottomSheetContainer.VerticalSize.SMALL)
            }
        }
    }

    override fun mkDidSelect(annotation: BaseAnnotation?) {
        currentSelection = annotation
        select(annotation)
    }

    override fun mkDidDeselect(annotation: BaseAnnotation?) {
        container.post { annotationDeselect(annotation) }
    }

    private fun annotationDeselect(annotation: BaseAnnotation?) {
        val cur = currentSelection ?: return
        val a = annotation ?: return
        if (cur === a && pages.lastOrNull() == Page.ANNOTATION_INFO) pop(true)
    }

    override fun select(annotation: BaseAnnotation?) {
        val a = annotation ?: return
        SearchHistoryStorage.shared.open(a)
        val info = UnitDetailInfo(a)
        if (pages.lastOrNull() == Page.ANNOTATION_INFO) {
            (container.pages.lastOrNull() as? UnitDetailPage)?.configure(info, showRouteButton = !pages.contains(Page.EXCLUSIVE_ROUTE))
        } else {
            val page = UnitDetailPage(context, mapViewDelegate)
            wireUnitDetail(page)
            page.configure(info, showRouteButton = !pages.contains(Page.EXCLUSIVE_ROUTE))
            push(page, true)
            page.onClose = { pop(true) }
        }
        if (container.state != BottomSheetContainer.VerticalSize.MEDIUM && container.currentSize == HorizontalSize.BIG && !skipSelectStateChange) {
            container.changeState(BottomSheetContainer.VerticalSize.MEDIUM)
        }
        skipSelectStateChange = false
    }

    private fun wireUnitDetail(page: UnitDetailPage) {
        page.onRouteTo = { setTo(it) }
        page.onRouteFrom = { setFrom(it) }
    }

    override fun getSafeZone(): RectF = container.safeZone()

    override fun getHorizontalSize(): HorizontalSize = container.currentSize

    // ------------------------------------------------------------------ RouteDetail

    override fun setup(from: BaseAnnotation, to: BaseAnnotation, routeParams: RouteParameters) {
        currentSelection?.let { mapViewDelegate?.deselectAnnotation(it, true) }
        getRoutePage().setup(from, to, routeParams)
    }

    override fun setFrom(annotation: BaseAnnotation) { getRoutePage().setFrom(annotation) }

    override fun setTo(annotation: BaseAnnotation) { getRoutePage().setTo(annotation) }

    private fun getRoutePage(): RouteDetailPage {
        val existing = routeDetailPage
        if (existing != null && container.pages.contains(existing)) {
            container.post { popTo(existing, true) }
            return existing
        }
        val page = RouteDetailPage(context, mapViewDelegate!!, searchable)
        routeDetailPage = page
        push(page, true)
        page.onClose = { pop(true) }
        return page
    }

    // ------------------------------------------------------------------ ExclusiveRouteDetail

    override fun show(from: BaseAnnotation, to: BaseAnnotation, routeParams: RouteParameters, allowParameterChange: Boolean) {
        if (pages.lastOrNull() == Page.ANNOTATION_INFO) mapViewDelegate?.deselectAnnotation(currentSelection, true)
        getExclusivePage { it.show(from, to, routeParams, allowParameterChange) }
    }

    override fun currentRoute(): Pair<Pair<BaseAnnotation, BaseAnnotation>, Pair<RouteParameters, Boolean>>? {
        val p = exclusiveRoutePage ?: return null
        if (!container.pages.contains(p)) return null
        val from = p.from ?: return null; val to = p.to ?: return null
        val params = p.routeParams ?: return null; val allow = p.allowParameterChange ?: return null
        return Pair(Pair(from, to), Pair(params, allow))
    }

    private fun getExclusivePage(completion: (ExclusiveRoutePage) -> Unit) {
        val existing = exclusiveRoutePage
        if (existing != null && container.pages.contains(existing)) {
            popTo(existing, true)
            completion(existing)
            return
        }
        fun create() {
            val page = ExclusiveRoutePage(context, mapViewDelegate!!)
            exclusiveRoutePage = page
            push(page, true)
            page.onClose = { pop(true) }
            completion(page)
        }
        if (container.pages.size > 1) {
            popTo(container.pages.first(), true)
            container.postDelayed({ create() }, 550)
        } else create()
    }

    companion object {
        var routeDetail: RouteDetail? = null
            private set
        var exclusiveRouteDetail: ExclusiveRouteDetail? = null
            private set
    }
}
