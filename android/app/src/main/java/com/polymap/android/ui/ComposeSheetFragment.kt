package com.polymap.android.ui

import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.polymap.android.R
import com.polymap.android.ui.screens.CreatedByDetailScreen
import com.polymap.android.ui.screens.EmptyBuildingPlanScreen
import com.polymap.android.ui.screens.HelloMessageScreen
import com.polymap.android.ui.screens.OpenUrlPopupScreen
import com.polymap.android.ui.screens.ReportIssueScreen
import com.polymap.android.ui.screens.ShareDialogScreen

/**
 * Presents a Compose screen as an iOS "page sheet" (full height modal bottom sheet with rounded top corners).
 */
class ComposeSheetFragment : BottomSheetDialogFragment() {
    private var kind: SheetKind? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        kind = pending.remove(arguments?.getInt(ARG_ID) ?: -1)
        if (kind == null) dismissAllowingStateLoss()
    }

    override fun getTheme(): Int = R.style.Theme_PolyMap_Sheet

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = super.onCreateDialog(savedInstanceState) as BottomSheetDialog
        dialog.behavior.state = BottomSheetBehavior.STATE_EXPANDED
        dialog.behavior.skipCollapsed = true
        dialog.behavior.isFitToContents = false
        dialog.behavior.expandedOffset = (24 * resources.displayMetrics.density).toInt()
        dialog.behavior.isDraggable = true
        return dialog
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val k = kind ?: return FrameLayout(requireContext())
        val compose = ComposeView(requireContext()).apply {
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
            setContent {
                PolyMapTheme {
                    // The dialog window may consume the system insets before they reach Compose (seen on
                    // Android 16), so also use the nav bar height measured in the main activity window.
                    val density = LocalDensity.current
                    val nav = WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()
                    val ime = WindowInsets.ime.asPaddingValues().calculateBottomPadding()
                    val fallback = with(density) { Sheets.navBarBottomPx.toDp() }
                    val bottom = maxOf(nav, ime, fallback)
                    Box(Modifier.fillMaxSize().padding(bottom = bottom)) { Content(k) }
                }
            }
        }
        return FrameLayout(requireContext()).apply {
            layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            setBackgroundResource(R.drawable.sheet_background)
            addView(compose, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        }
    }

    override fun onStart() {
        super.onStart()
        (dialog as? BottomSheetDialog)?.let { d ->
            d.findViewById<View>(com.google.android.material.R.id.design_bottom_sheet)?.let { sheet ->
                sheet.layoutParams = sheet.layoutParams.apply { height = ViewGroup.LayoutParams.MATCH_PARENT }
                sheet.setBackgroundResource(android.R.color.transparent)
            }
        }
    }

    @Composable
    private fun Content(kind: SheetKind) {
        val close: () -> Unit = { dismissAllowingStateLoss() }
        when (kind) {
            is SheetKind.Hello -> HelloMessageScreen(close)
            is SheetKind.EmptyPlan -> EmptyBuildingPlanScreen(kind.buildingName, close)
            is SheetKind.Report -> ReportIssueScreen(kind.report, close)
            is SheetKind.CreatedBy -> CreatedByDetailScreen(kind.authors, close)
            is SheetKind.Share -> ShareDialogScreen(kind.from, kind.to, kind.params, close)
            is SheetKind.OpenUrl -> OpenUrlPopupScreen(kind.id, close)
        }
    }

    companion object {
        private const val ARG_ID = "id"
        private val pending = HashMap<Int, SheetKind>()
        private var nextId = 1

        fun show(activity: AppCompatActivity, kind: SheetKind) {
            val id = nextId++
            pending[id] = kind
            ComposeSheetFragment().apply { arguments = Bundle().apply { putInt(ARG_ID, id) } }
                .show(activity.supportFragmentManager, "sheet$id")
        }
    }
}
