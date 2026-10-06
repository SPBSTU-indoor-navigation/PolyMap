package com.polymap.android.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.layout.Arrangement
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
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.polymap.android.R
import com.polymap.android.imdf.IMDF
import com.polymap.android.ui.AccentButton
import com.polymap.android.ui.IosColors

/** HelloMessage port */
@Composable
fun HelloMessageScreen(close: () -> Unit) {
    Column(Modifier.fillMaxSize().padding(vertical = 16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            stringResource(R.string.hellopopup_title), fontSize = 34.sp, fontWeight = FontWeight.Black, textAlign = TextAlign.Center, color = IosColors.label,
            modifier = Modifier.padding(top = 40.dp, bottom = 30.dp).padding(horizontal = 16.dp)
        )
        Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(16.dp).widthIn(max = 500.dp), verticalArrangement = Arrangement.spacedBy(30.dp)) {
            HelloMessageLine(stringResource(R.string.hellopopup_indoor_title), stringResource(R.string.hellopopup_indoor_message), R.drawable.ic_sf_plan)
            HelloMessageLine(stringResource(R.string.hellopopup_route_title), stringResource(R.string.hellopopup_route_message), R.drawable.ic_sf_route)
            HelloMessageLine(stringResource(R.string.hellopopup_share_title), stringResource(R.string.hellopopup_share_message), R.drawable.ic_sf_qrcode)
        }
        Box(Modifier.padding(horizontal = 16.dp, vertical = 8.dp)) { AccentButton(stringResource(R.string.hellopopup_continue), onClick = close) }
    }
}

@Composable
fun HelloMessageLine(title: String, content: String, icon: Int) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Image(painterResource(icon), null, Modifier.size(40.dp), colorFilter = ColorFilter.tint(IosColors.accent))
        Spacer(Modifier.width(16.dp))
        Column(Modifier.weight(1f)) {
            Text(title, fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = IosColors.label)
            Text(content, fontSize = 17.sp, color = IosColors.secondaryLabel)
        }
    }
}

/** CreatedByDetail port */
@Composable
fun CreatedByDetailScreen(authors: IMDF.Author, close: () -> Unit) {
    val d = authors.detail
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp), verticalArrangement = Arrangement.spacedBy(20.dp)) {
        Text(d.title.bestLocalizedValue ?: "", fontSize = 34.sp, fontWeight = FontWeight.Bold, color = IosColors.label)
        Text(d.description.bestLocalizedValue ?: "", fontSize = 17.sp, color = IosColors.label)
        val list = d.authors.map { it.bestLocalizedValue ?: "" }
        if (list.isNotEmpty()) {
            val at = d.authorsTitle.bestLocalizedValue ?: ""
            if (at.isNotEmpty()) Text(at, fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = IosColors.label)
            Column(Modifier.fillMaxWidth().clip(RoundedCornerShape(10.dp)).background(IosColors.secondaryGroupedBackground).padding(16.dp)) {
                list.forEachIndexed { i, a ->
                    Text(a, fontSize = 17.sp, color = IosColors.label, modifier = Modifier.fillMaxWidth())
                    if (i < list.size - 1) HorizontalDivider(color = IosColors.separator, modifier = Modifier.padding(vertical = 8.dp))
                }
            }
        }
    }
}

/** EmptyBuildingPlan port */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun EmptyBuildingPlanScreen(buildingName: String, close: () -> Unit) {
    val context = LocalContext.current
    val clipboard = LocalClipboardManager.current
    val email = stringResource(R.string.empty_plan_email)
    var menu by remember { mutableStateOf(false) }
    val subject = stringResource(R.string.mapinfo_detail_emptyplan_mail_subject)
    val body = stringResource(R.string.mapinfo_detail_emptyplan_mail_message).replace("{BUILDING}", buildingName)
    val openMail = {
        val intent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:$email")).apply {
            putExtra(Intent.EXTRA_SUBJECT, subject); putExtra(Intent.EXTRA_TEXT, body)
        }
        runCatching { context.startActivity(intent) }
    }
    Column(Modifier.fillMaxSize()) {
        SheetNavBar("", leading = { NavTextButton(stringResource(R.string.present_cancel)) { close() } })
        Column(Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(50.dp)) {
            Text(stringResource(R.string.mapinfo_detail_emptyplan_title), fontSize = 34.sp, fontWeight = FontWeight.Bold, color = IosColors.label, modifier = Modifier.padding(top = 40.dp))
            Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
                Text(stringResource(R.string.mapinfo_detail_emptyplan_message), fontSize = 17.sp, color = IosColors.label)
                Box {
                    Text(email, fontSize = 17.sp, color = IosColors.label, modifier = Modifier.combinedClickable(onClick = { menu = true }, onLongClick = { menu = true }))
                    DropdownMenu(expanded = menu, onDismissRequest = { menu = false }) {
                        DropdownMenuItem(text = { Text(stringResource(R.string.mapinfo_detail_emptyplan_email_copy)) }, onClick = { clipboard.setText(AnnotatedString(email)); menu = false })
                        DropdownMenuItem(text = { Text(stringResource(R.string.mapinfo_detail_emptyplan_email_open)) }, onClick = { menu = false; openMail() })
                    }
                }
            }
        }
        Box(Modifier.fillMaxWidth().padding(20.dp), contentAlignment = Alignment.Center) {
            AccentButton(stringResource(R.string.mapinfo_detail_emptyplan_open)) { openMail() }
        }
    }
}
