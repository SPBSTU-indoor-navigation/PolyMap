package com.polymap.android.ui

import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import com.polymap.android.api.ReportTarget
import com.polymap.android.imdf.IMDF
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.storage.RouteParameters

/** Entry points for the modal (SwiftUI on iOS) screens, presented as bottom sheet dialogs. */
object Sheets {
    /** Navigation bar height of the main window (px); fallback for sheet dialogs whose window swallows insets. */
    @JvmStatic var navBarBottomPx = 0

    private fun activity(context: Context): AppCompatActivity? {
        var c = context
        while (c is android.content.ContextWrapper) {
            if (c is AppCompatActivity) return c
            c = c.baseContext
        }
        return null
    }

    fun showHello(context: Context) = activity(context)?.let { ComposeSheetFragment.show(it, SheetKind.Hello) }
    fun showEmptyBuildingPlan(context: Context, buildingName: String) = activity(context)?.let { ComposeSheetFragment.show(it, SheetKind.EmptyPlan(buildingName)) }
    fun showReportIssue(context: Context, report: ReportTarget) = activity(context)?.let { ComposeSheetFragment.show(it, SheetKind.Report(report)) }
    fun showCreatedBy(context: Context, authors: IMDF.Author) = activity(context)?.let { ComposeSheetFragment.show(it, SheetKind.CreatedBy(authors)) }
    fun showShareDialog(context: Context, from: BaseAnnotation, to: BaseAnnotation, params: RouteParameters) =
        activity(context)?.let { ComposeSheetFragment.show(it, SheetKind.Share(from, to, params)) }
    fun showOpenUrl(context: Context, id: String) = activity(context)?.let { ComposeSheetFragment.show(it, SheetKind.OpenUrl(id)) }
}

sealed class SheetKind {
    object Hello : SheetKind()
    class EmptyPlan(val buildingName: String) : SheetKind()
    class Report(val report: ReportTarget) : SheetKind()
    class CreatedBy(val authors: IMDF.Author) : SheetKind()
    class Share(val from: BaseAnnotation, val to: BaseAnnotation, val params: RouteParameters) : SheetKind()
    class OpenUrl(val id: String) : SheetKind()
}
