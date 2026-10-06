package com.polymap.android.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.polymap.android.R
import com.polymap.android.api.ApiStatus
import com.polymap.android.api.ReportApiProvider
import com.polymap.android.api.ReportTarget
import com.polymap.android.ui.GroupedRow
import com.polymap.android.ui.GroupedSection
import com.polymap.android.ui.IosColors

/** TextViewPlaceholder port: a plain multi-line text area with a placeholder. */
@Composable
fun PlaceholderTextArea(text: String, onChange: (String) -> Unit, placeholder: String, height: Int = 200) {
    Box(Modifier.fillMaxWidth().height(height.dp)) {
        if (text.isEmpty()) Text(placeholder, fontSize = 17.sp, color = IosColors.secondaryLabel)
        BasicTextField(
            value = text, onValueChange = onChange,
            textStyle = TextStyle(fontSize = 17.sp, color = IosColors.label),
            cursorBrush = SolidColor(IosColors.accent),
            modifier = Modifier.fillMaxSize()
        )
    }
}

/** ReportanIssue port */
@Composable
fun ReportIssueScreen(report: ReportTarget, close: () -> Unit) {
    var text by remember { mutableStateOf("") }
    var sending by remember { mutableStateOf(false) }
    if (sending) {
        ReportResultScreen(text, report, close)
        return
    }
    Column(Modifier.fillMaxSize()) {
        SheetNavBar(stringResource(R.string.reportanissue_title), trailing = { NavTextButton(stringResource(R.string.reportanissue_send), enabled = text.isNotEmpty()) { sending = true } })
        Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(top = 8.dp)) {
            when (report) {
                is ReportTarget.Annotation -> GroupedSection(header = stringResource(R.string.reportanissue_error_annotation), rows = listOf({ GroupedRow { SearchablePreview(report.annotation) } }))
                is ReportTarget.Route -> GroupedSection(header = stringResource(R.string.reportanissue_error_route), rows = listOf(
                    { GroupedRow { Row(verticalAlignment = Alignment.CenterVertically) { Text(stringResource(R.string.mapinfo_route_info_from), fontSize = 17.sp, color = IosColors.label); Spacer(Modifier.width(8.dp)); SearchablePreview(report.from) } } },
                    { GroupedRow { Row(verticalAlignment = Alignment.CenterVertically) { Text(stringResource(R.string.mapinfo_route_info_to), fontSize = 17.sp, color = IosColors.label); Spacer(Modifier.width(8.dp)); SearchablePreview(report.to) } } },
                    { GroupedRow { Text("${stringResource(R.string.mapinfo_route_info_asphalt)}: ${stringResource(if (report.params.asphalt) R.string.reportanissue_enable else R.string.reportanissue_disable)}", fontSize = 17.sp, color = IosColors.label) } },
                    { GroupedRow { Text("${stringResource(R.string.mapinfo_route_info_serviceroute)}: ${stringResource(if (report.params.serviceRoute) R.string.reportanissue_enable else R.string.reportanissue_disable)}", fontSize = 17.sp, color = IosColors.label) } }
                ))
            }
            GroupedSection(header = stringResource(R.string.reportanissue_message_title), footer = stringResource(R.string.reportanissue_message_footer), rows = listOf({
                GroupedRow { PlaceholderTextArea(text, { text = it }, stringResource(R.string.reportanissue_message_placeholder)) }
            }))
            Spacer(Modifier.height(400.dp))
        }
    }
}

/** ReportResult port */
@Composable
fun ReportResultScreen(reportText: String, report: ReportTarget, close: () -> Unit) {
    val context = LocalContext.current
    var result by remember { mutableStateOf<ApiStatus<ReportApiProvider.Result>?>(null) }
    LaunchedEffect(Unit) {
        ReportApiProvider.sendReport(context, reportText, report) { result = it }
    }
    Column(Modifier.fillMaxSize()) {
        SheetNavBar("", trailing = { NavTextButton(stringResource(R.string.share_result_done)) { close() } })
        Box(Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
            val r = result
            if (r == null) {
                CircularProgressIndicator(color = IosColors.accent)
            } else {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    val ok = r.data != null
                    Image(painterResource(if (ok) R.drawable.ic_sf_check_bubble else R.drawable.ic_sf_xmark_octagon), null, Modifier.size(200.dp).padding(30.dp), colorFilter = ColorFilter.tint(IosColors.accent))
                    Text(stringResource(if (ok) R.string.reportanissue_succes else R.string.reportanissue_servererror), fontSize = 17.sp, textAlign = TextAlign.Center, color = IosColors.label, modifier = Modifier.padding(horizontal = 20.dp))
                }
            }
        }
    }
}
