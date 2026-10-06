package com.polymap.android.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import com.polymap.android.R
import com.polymap.android.api.ApiStatus
import com.polymap.android.api.CodeGeneratorModel
import com.polymap.android.api.CodeGeneratorProvider
import com.polymap.android.api.ShareVariants
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.pathfinder.PathFinder
import com.polymap.android.pages.MapInfo
import com.polymap.android.storage.RouteParameters
import com.polymap.android.storage.Storage
import com.polymap.android.ui.AccentButton
import com.polymap.android.ui.GroupedRow
import com.polymap.android.ui.GroupedSection
import com.polymap.android.ui.IosColors
import java.io.File

private fun hexColor(hex: String): Color {
    val h = hex.trim('#')
    val v = when (h.length) {
        3 -> h.map { "$it$it" }.joinToString("")
        else -> h
    }
    val int = v.toLong(16)
    return if (v.length == 8) Color(int) else Color(0xFF000000L or int)
}

/** AppClipCodePreview port: stacked tinted layers. */
@Composable
fun AppClipCodePreview(color: ShareVariants.ColorVariant, logo: ShareVariants.LogoVariant, badge: ShareVariants.BadgeVariant, modifier: Modifier = Modifier) {
    val p = color.preset
    val isBadge = badge == ShareVariants.BadgeVariant.BADGE
    Box(modifier.aspectRatio(if (isBadge) 1.5f else 1f)) {
        fun layer(res: Int, tint: String) = @Composable { Image(painterResource(res), null, Modifier.fillMaxSize(), colorFilter = ColorFilter.tint(hexColor(tint))) }
        layer(if (isBadge) R.drawable.ic_badge else R.drawable.ic_appclip_c_background, p.background)()
        if (isBadge) layer(R.drawable.ic_badgetext, p.badgeTextColor)()
        layer(if (isBadge) R.drawable.ic_appclip_primary else R.drawable.ic_appclip_c_primary, p.primary)()
        layer(if (isBadge) R.drawable.ic_appclip_secondary else R.drawable.ic_appclip_c_secondary, p.secondary)()
        if (logo == ShareVariants.LogoVariant.PHONE) {
            layer(if (isBadge) R.drawable.ic_appclip_nfc_primary else R.drawable.ic_appclip_c_nfc_primary, p.primary)()
            layer(if (isBadge) R.drawable.ic_appclip_nfc_secondary else R.drawable.ic_appclip_c_nfc_secondary, p.secondary)()
        } else {
            layer(if (isBadge) R.drawable.ic_appclip_camera else R.drawable.ic_appclip_c_camera, p.primary)()
        }
    }
}

/** QRCodePreview port */
@Composable
fun QRCodePreview(color: ShareVariants.ColorVariant, logo: ShareVariants.QRLogoVariant, modifier: Modifier = Modifier) {
    val p = color.preset
    Box(modifier.aspectRatio(1f)) {
        Image(painterResource(R.drawable.ic_qrbackground), null, Modifier.fillMaxSize(), colorFilter = ColorFilter.tint(hexColor(p.background)))
        Image(painterResource(if (logo == ShareVariants.QRLogoVariant.USE) R.drawable.ic_qrdata else R.drawable.ic_qrdatafull), null, Modifier.fillMaxSize(), colorFilter = ColorFilter.tint(hexColor(p.primary)))
        if (logo == ShareVariants.QRLogoVariant.USE) Image(painterResource(R.drawable.ic_qrlogo), null, Modifier.fillMaxSize(), colorFilter = ColorFilter.tint(hexColor(p.primary)))
    }
}

/** CodeVariant port: image + title + check circle (or warning) */
@Composable
fun CodeVariantOption(enabled: Boolean, warning: Boolean, title: String, icon: @Composable () -> Unit, onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.clickable(enabled = !warning) { onClick() }) {
        Box(Modifier.width(80.dp).height(90.dp), contentAlignment = Alignment.Center) { icon() }
        Text(title, fontSize = 17.sp, color = IosColors.label)
        Box(Modifier.size(25.dp), contentAlignment = Alignment.Center) {
            when {
                warning -> Image(painterResource(R.drawable.ic_sf_clear), null, Modifier.size(25.dp), colorFilter = ColorFilter.tint(IosColors.secondaryLabel))
                enabled -> Image(painterResource(R.drawable.ic_sf_check_circle_fill), null, Modifier.size(25.dp), colorFilter = ColorFilter.tint(IosColors.accent))
                else -> Box(Modifier.size(23.dp).border(2.dp, IosColors.secondaryLabel, CircleShape))
            }
        }
    }
}

@Composable
private fun IosSwitch(checked: Boolean, onChange: (Boolean) -> Unit) {
    Switch(checked = checked, onCheckedChange = onChange, colors = SwitchDefaults.colors(checkedTrackColor = IosColors.accent, checkedThumbColor = Color.White))
}

@Composable
private fun SettingsLine(title: String, current: String, onClick: () -> Unit) {
    GroupedRow(onClick = onClick) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(title, fontSize = 17.sp, color = IosColors.label, modifier = Modifier.weight(1f))
            Text(current, fontSize = 17.sp, color = IosColors.secondaryLabel)
            Spacer(Modifier.width(6.dp))
            Image(painterResource(R.drawable.ic_sf_chevron_forward), null, Modifier.size(20.dp), colorFilter = ColorFilter.tint(IosColors.secondaryLabel))
        }
    }
}

@Composable
private fun CheckRow(title: String, checked: Boolean, leading: (@Composable () -> Unit)? = null, onClick: () -> Unit) {
    GroupedRow(onClick = onClick) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            leading?.let { it(); Spacer(Modifier.width(10.dp)) }
            Text(title, fontSize = 17.sp, color = IosColors.label, modifier = Modifier.weight(1f))
            if (checked) Image(painterResource(R.drawable.ic_sf_checkmark), null, Modifier.size(22.dp), colorFilter = ColorFilter.tint(IosColors.accent))
        }
    }
}

private enum class ShareScreen { MAIN, COLOR, LOGO, BADGE, QR_COLOR, QR_LOGO, RESULT }

@Composable
private fun ColorVariantName(v: ShareVariants.Variant): String = stringResource(
    when (v) {
        ShareVariants.Variant.BLACK -> R.string.share_colorvariant_preset_black
        ShareVariants.Variant.GRAY -> R.string.share_colorvariant_preset_gray
        ShareVariants.Variant.RED -> R.string.share_colorvariant_preset_red
        ShareVariants.Variant.ORANGE -> R.string.share_colorvariant_preset_orange
        ShareVariants.Variant.GREEN -> R.string.share_colorvariant_preset_green
        ShareVariants.Variant.TEAL -> R.string.share_colorvariant_preset_teal
        ShareVariants.Variant.BLUE -> R.string.share_colorvariant_preset_blue
        ShareVariants.Variant.INDIGO -> R.string.share_colorvariant_preset_indigo
        ShareVariants.Variant.PURPLE -> R.string.share_colorvariant_preset_purple
    }
)

/** ShareDialog port (with its sub-screens and the ShareResult). */
@Composable
fun ShareDialogScreen(from: BaseAnnotation, to: BaseAnnotation, routeParams: RouteParameters, close: () -> Unit) {
    var screen by remember { mutableStateOf(ShareScreen.MAIN) }
    var isQR by remember { mutableStateOf(Storage.bool("shareCodeVariant") ?: true) }
    var showHelloText by remember { mutableStateOf(false) }
    var routeParameterChanging by remember { mutableStateOf(false) }
    var helloText by remember { mutableStateOf("") }
    var colorVariant by remember { mutableStateOf(ShareVariants.ColorVariant.loadFromStorage() ?: ShareVariants.ColorVariant(false, ShareVariants.Variant.GREEN)) }
    var logoVariant by remember { mutableStateOf(ShareVariants.LogoVariant.loadFromStorage() ?: ShareVariants.LogoVariant.CAMERA) }
    var badgeVariant by remember { mutableStateOf(ShareVariants.BadgeVariant.loadFromStorage() ?: ShareVariants.BadgeVariant.BADGE) }
    var qrLogoVariant by remember { mutableStateOf(ShareVariants.QRLogoVariant.loadFromStorage() ?: ShareVariants.QRLogoVariant.USE) }
    var serverStatus by remember { mutableStateOf<ApiStatus<CodeGeneratorModel.ServerStatus>?>(null) }
    var warningQR by remember { mutableStateOf(false) }
    var warningAppClip by remember { mutableStateOf(false) }
    var tick by remember { mutableStateOf(0) }

    LaunchedEffect(Unit) {
        CodeGeneratorProvider.loadStatus { res ->
            serverStatus = res
            warningQR = !(res.data?.qr ?: true)
            warningAppClip = !(res.data?.appclip ?: true)
            if (warningAppClip) isQR = true
        }
    }

    BackHandler(enabled = screen != ShareScreen.MAIN) { screen = ShareScreen.MAIN }

    val back: @Composable () -> Unit = {
        Row(Modifier.clickable { screen = ShareScreen.MAIN }.padding(horizontal = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            Image(painterResource(R.drawable.ic_sf_chevron_backward), null, Modifier.size(24.dp), colorFilter = ColorFilter.tint(IosColors.accent))
            Text(stringResource(R.string.share_navigationtitle), fontSize = 17.sp, color = IosColors.accent)
        }
    }

    when (screen) {
        ShareScreen.MAIN -> Column(Modifier.fillMaxSize()) {
            SheetNavBar(stringResource(R.string.share_navigationtitle))
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState())) {
                Text(stringResource(R.string.share_maininfo), fontSize = 13.sp, color = IosColors.secondaryLabel, modifier = Modifier.padding(horizontal = 32.dp, vertical = 8.dp))
                GroupedSection(rows = listOf(
                    { GroupedRow { Row(verticalAlignment = Alignment.CenterVertically) { Text(stringResource(R.string.mapinfo_route_info_from), fontSize = 17.sp, color = IosColors.label); Spacer(Modifier.width(8.dp)); SearchablePreview(from) } } },
                    { GroupedRow { Row(verticalAlignment = Alignment.CenterVertically) { Text(stringResource(R.string.mapinfo_route_info_to), fontSize = 17.sp, color = IosColors.label); Spacer(Modifier.width(8.dp)); SearchablePreview(to) } } }
                ))
                // hello text
                val helloRows = mutableListOf<@Composable () -> Unit>({
                    GroupedRow { Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Text(stringResource(R.string.share_hellotext_title), fontSize = 17.sp, color = IosColors.label, modifier = Modifier.weight(1f))
                        IosSwitch(showHelloText) { showHelloText = it }
                    } }
                })
                if (showHelloText) helloRows += { GroupedRow { PlaceholderTextArea(helloText, { helloText = it }, stringResource(R.string.share_hellotext_placehodler)) } }
                GroupedSection(footer = stringResource(R.string.share_hellotext_info), rows = helloRows)
                GroupedSection(footer = stringResource(R.string.share_allowparameterchange_description), rows = listOf({
                    GroupedRow { Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Text(stringResource(R.string.share_allowparameterchange), fontSize = 17.sp, color = IosColors.label, modifier = Modifier.weight(1f))
                        IosSwitch(routeParameterChanging) { routeParameterChanging = it }
                    } }
                }))
                // code variant
                GroupedSection(header = stringResource(R.string.share_codevariant_title), footer = stringResource(R.string.share_codevariant_info), rows = listOf({
                    Column(Modifier.fillMaxWidth().padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                            CodeVariantOption(isQR, warningQR, stringResource(R.string.share_codevariant_qr), { Image(painterResource(R.drawable.ic_sf_qrcode), null, Modifier.size(80.dp), colorFilter = ColorFilter.tint(IosColors.label)) }) {
                                if (!warningQR) { isQR = true; Storage.set("shareCodeVariant", true) }
                            }
                            CodeVariantOption(!isQR, warningAppClip, stringResource(R.string.share_codevariant_appclip), { Image(painterResource(R.drawable.ic_appclippreview), null, Modifier.size(80.dp), colorFilter = ColorFilter.tint(IosColors.label)) }) {
                                if (!warningAppClip) { isQR = false; Storage.set("shareCodeVariant", false) }
                            }
                        }
                        if (warningQR || warningAppClip) {
                            Text(
                                stringResource(if (warningQR && warningAppClip) R.string.share_erroralert_message else if (warningQR) R.string.share_erroralert_qr_message else R.string.share_erroralert_appclip_message),
                                fontSize = 12.sp, color = IosColors.red, textAlign = TextAlign.Center, modifier = Modifier.padding(top = 8.dp)
                            )
                        }
                    }
                }))
                if (!isQR) {
                    GroupedSection(rows = listOf(
                        { SettingsLine(stringResource(R.string.share_colorvariant_title), ColorVariantName(colorVariant.currentVariant)) { screen = ShareScreen.COLOR } },
                        { SettingsLine(stringResource(R.string.share_logovariant_title), stringResource(if (logoVariant == ShareVariants.LogoVariant.CAMERA) R.string.share_logovariant_camera else R.string.share_logovariant_phone)) { screen = ShareScreen.LOGO } },
                        { SettingsLine(stringResource(R.string.share_badgevariant_title), stringResource(if (badgeVariant == ShareVariants.BadgeVariant.BADGE) R.string.share_badgevariant_badge else R.string.share_badgevariant_circle)) { screen = ShareScreen.BADGE } }
                    ))
                } else {
                    GroupedSection(rows = listOf(
                        { SettingsLine(stringResource(R.string.share_colorvariant_title), ColorVariantName(colorVariant.currentVariant)) { screen = ShareScreen.QR_COLOR } },
                        { SettingsLine(stringResource(R.string.share_qrlogovariant_title), stringResource(if (qrLogoVariant == ShareVariants.QRLogoVariant.USE) R.string.share_qrlogovariant_use else R.string.share_qrlogovariant_none)) { screen = ShareScreen.QR_LOGO } }
                    ))
                }
                Column(Modifier.fillMaxWidth().padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    val s = serverStatus
                    if (s == null) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            CircularProgressIndicator(Modifier.size(18.dp), color = IosColors.secondaryLabel, strokeWidth = 2.dp)
                            Spacer(Modifier.width(8.dp))
                            Text(stringResource(R.string.share_connectioncheck), color = IosColors.secondaryLabel)
                        }
                    } else if (s.data == null) {
                        Text(stringResource(R.string.share_connectionerror), color = IosColors.secondaryLabel)
                    }
                    Spacer(Modifier.height(8.dp))
                    AccentButton(stringResource(R.string.share_create), enabled = serverStatus != null && !(warningQR && warningAppClip)) { screen = ShareScreen.RESULT }
                }
            }
        }
        ShareScreen.COLOR, ShareScreen.QR_COLOR -> Column(Modifier.fillMaxSize()) {
            SheetNavBar(stringResource(R.string.share_colorvariant_title), leading = back)
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState())) {
                GroupedSection(rows = ShareVariants.Variant.entries.map { v ->
                    {
                        val preset = if (colorVariant.inverted) v.preset.inverted else v.preset.normal
                        CheckRow(ColorVariantName(v), colorVariant.currentVariant == v, leading = {
                            Box(Modifier.size(20.dp).clip(CircleShape).background(hexColor(preset.background)).padding(5.dp).clip(CircleShape).background(hexColor(preset.primary)))
                        }) { colorVariant = ShareVariants.ColorVariant(colorVariant.inverted, v); colorVariant.saveToStorage(); tick++ }
                    }
                })
            }
            Column(Modifier.fillMaxWidth().background(IosColors.groupedBackground).padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                if (screen == ShareScreen.COLOR) AppClipCodePreview(colorVariant, logoVariant, badgeVariant, Modifier.widthIn(max = 250.dp).fillMaxWidth())
                else QRCodePreview(colorVariant, qrLogoVariant, Modifier.widthIn(max = 250.dp).fillMaxWidth())
                Row(Modifier.clickable { colorVariant = ShareVariants.ColorVariant(!colorVariant.inverted, colorVariant.currentVariant); colorVariant.saveToStorage(); tick++ }.padding(8.dp), verticalAlignment = Alignment.CenterVertically) {
                    Image(painterResource(R.drawable.ic_sf_swap), null, Modifier.size(20.dp), colorFilter = ColorFilter.tint(IosColors.accent))
                    Spacer(Modifier.width(4.dp))
                    Text(stringResource(R.string.share_colorvariant_preview_changecolor), color = IosColors.accent, fontSize = 17.sp)
                }
            }
        }
        ShareScreen.LOGO -> Column(Modifier.fillMaxSize()) {
            SheetNavBar(stringResource(R.string.share_logovariant_title), leading = back)
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState())) {
                GroupedSection(footer = stringResource(R.string.share_logovariant_info), rows = listOf(
                    { CheckRow(stringResource(R.string.share_logovariant_camera), logoVariant == ShareVariants.LogoVariant.CAMERA) { logoVariant = ShareVariants.LogoVariant.CAMERA; logoVariant.saveToStorage() } },
                    { CheckRow(stringResource(R.string.share_logovariant_phone), logoVariant == ShareVariants.LogoVariant.PHONE) { logoVariant = ShareVariants.LogoVariant.PHONE; logoVariant.saveToStorage() } }
                ))
            }
            Box(Modifier.fillMaxWidth().background(IosColors.groupedBackground).padding(16.dp), contentAlignment = Alignment.Center) { AppClipCodePreview(colorVariant, logoVariant, badgeVariant, Modifier.widthIn(max = 250.dp).fillMaxWidth()) }
        }
        ShareScreen.BADGE -> Column(Modifier.fillMaxSize()) {
            SheetNavBar(stringResource(R.string.share_badgevariant_title), leading = back)
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState())) {
                GroupedSection(footer = stringResource(R.string.share_badgevariant_info), rows = listOf(
                    { CheckRow(stringResource(R.string.share_badgevariant_badge), badgeVariant == ShareVariants.BadgeVariant.BADGE) { badgeVariant = ShareVariants.BadgeVariant.BADGE; badgeVariant.saveToStorage() } },
                    { CheckRow(stringResource(R.string.share_badgevariant_circle), badgeVariant == ShareVariants.BadgeVariant.CIRCLE) { badgeVariant = ShareVariants.BadgeVariant.CIRCLE; badgeVariant.saveToStorage() } }
                ))
            }
            Box(Modifier.fillMaxWidth().background(IosColors.groupedBackground).padding(16.dp), contentAlignment = Alignment.Center) { AppClipCodePreview(colorVariant, logoVariant, badgeVariant, Modifier.widthIn(max = 250.dp).fillMaxWidth()) }
        }
        ShareScreen.QR_LOGO -> Column(Modifier.fillMaxSize()) {
            SheetNavBar(stringResource(R.string.share_qrlogovariant_title), leading = back)
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState())) {
                GroupedSection(rows = listOf(
                    { CheckRow(stringResource(R.string.share_qrlogovariant_use), qrLogoVariant == ShareVariants.QRLogoVariant.USE) { qrLogoVariant = ShareVariants.QRLogoVariant.USE; qrLogoVariant.saveToStorage() } },
                    { CheckRow(stringResource(R.string.share_qrlogovariant_none), qrLogoVariant == ShareVariants.QRLogoVariant.NONE) { qrLogoVariant = ShareVariants.QRLogoVariant.NONE; qrLogoVariant.saveToStorage() } }
                ))
            }
            Box(Modifier.fillMaxWidth().background(IosColors.groupedBackground).padding(16.dp), contentAlignment = Alignment.Center) { QRCodePreview(colorVariant, qrLogoVariant, Modifier.widthIn(max = 250.dp).fillMaxWidth()) }
        }
        ShareScreen.RESULT -> ShareResultScreen(
            ShareVariants.Settings(colorVariant, logoVariant, badgeVariant, qrLogoVariant, isQR, from.imdfID, to.imdfID, helloText, routeParams, routeParameterChanging), close
        )
    }
}

/** ShareResult port: generates the code and offers PNG / SVG / tutorial / permalink. */
@Composable
fun ShareResultScreen(settings: ShareVariants.Settings, close: () -> Unit) {
    val context = LocalContext.current
    var preview by remember { mutableStateOf<android.graphics.Bitmap?>(null) }
    var response by remember { mutableStateOf<CodeGeneratorModel.GenerateResponse?>(null) }
    var svg by remember { mutableStateOf<ApiStatus<File>?>(null) }
    var png by remember { mutableStateOf<ApiStatus<File>?>(null) }
    var tutorial by remember { mutableStateOf<String?>(null) }
    var failed by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        CodeGeneratorProvider.generateCode(settings.routeSettings) { res ->
            val r = res.data
            if (r == null) { failed = true; return@generateCode }
            response = r
            tutorial = CodeGeneratorProvider.tutorialUrl(r.codeID, settings.isQR, settings.color, settings.logo, settings.badge, settings.qrLogoVariant)
            val loadPreview: (ApiStatus<File>) -> Unit = { st -> st.data?.let { f -> preview = android.graphics.BitmapFactory.decodeFile(f.absolutePath) } ?: run { failed = true } }
            if (settings.isQR) {
                CodeGeneratorProvider.loadQR(context, r.codeID, settings.color, settings.qrLogoVariant, false, 512, loadPreview)
                CodeGeneratorProvider.loadQR(context, r.codeID, settings.color, settings.qrLogoVariant, true) { svg = it }
                CodeGeneratorProvider.loadQR(context, r.codeID, settings.color, settings.qrLogoVariant, false, 2048) { png = it }
            } else {
                CodeGeneratorProvider.loadAppclip(context, r.codeID, settings.color, settings.logo, settings.badge, false, 512, loadPreview)
                CodeGeneratorProvider.loadAppclip(context, r.codeID, settings.color, settings.logo, settings.badge, true) { svg = it }
                CodeGeneratorProvider.loadAppclip(context, r.codeID, settings.color, settings.logo, settings.badge, false, 2048) { png = it }
            }
        }
    }

    fun shareFile(f: File, mime: String) {
        val uri = FileProvider.getUriForFile(context, context.packageName + ".files", f)
        val intent = Intent(Intent.ACTION_SEND).apply { type = mime; putExtra(Intent.EXTRA_STREAM, uri); addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION) }
        context.startActivity(Intent.createChooser(intent, null))
    }

    fun shareText(t: String) {
        val intent = Intent(Intent.ACTION_SEND).apply { type = "text/plain"; putExtra(Intent.EXTRA_TEXT, t) }
        context.startActivity(Intent.createChooser(intent, null))
    }

    Column(Modifier.fillMaxSize()) {
        SheetNavBar(stringResource(R.string.share_result_navigationtitle), trailing = { NavTextButton(stringResource(R.string.share_result_done)) { close() } })
        val bmp = preview
        if (bmp == null && !failed) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator(color = IosColors.accent) }
        } else Column(Modifier.weight(1f).verticalScroll(rememberScrollState())) {
            Box(Modifier.fillMaxWidth().padding(16.dp), contentAlignment = Alignment.Center) {
                if (bmp != null) Image(bmp.asImageBitmap(), null, Modifier.widthIn(max = 250.dp).fillMaxWidth().aspectRatio(bmp.width.toFloat() / bmp.height))
                else Image(painterResource(R.drawable.ic_sf_xmark_octagon), null, Modifier.size(120.dp), colorFilter = ColorFilter.tint(IosColors.secondaryLabel))
            }
            @Composable
            fun shareLine(title: String, result: ApiStatus<File>?, mime: String) {
                GroupedRow(onClick = { result?.data?.let { shareFile(it, mime) } }) {
                    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Text(title, fontSize = 17.sp, color = IosColors.label, modifier = Modifier.weight(1f))
                        if (result == null) CircularProgressIndicator(Modifier.size(18.dp), color = IosColors.secondaryLabel, strokeWidth = 2.dp)
                        else Image(painterResource(R.drawable.ic_sf_share), null, Modifier.size(22.dp), colorFilter = ColorFilter.tint(IosColors.accent))
                    }
                }
            }
            val rows = mutableListOf<@Composable () -> Unit>(
                { shareLine(stringResource(R.string.share_result_sharepng), png, "image/png") },
                { shareLine(stringResource(R.string.share_result_sharesvg), svg, "image/svg+xml") }
            )
            tutorial?.let { url ->
                rows += {
                    GroupedRow(onClick = { runCatching { context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url))) } }) {
                        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                            Text(stringResource(R.string.share_result_sharepdf), fontSize = 17.sp, color = IosColors.label, modifier = Modifier.weight(1f))
                            Image(painterResource(R.drawable.ic_sf_safari), null, Modifier.size(22.dp), colorFilter = ColorFilter.tint(IosColors.accent))
                        }
                    }
                }
            }
            GroupedSection(rows = rows)
            response?.let { r ->
                GroupedSection(footer = stringResource(R.string.share_result_shareurl_info), rows = listOf({
                    GroupedRow(onClick = { shareText(r.codeUrl) }) {
                        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                            Text(stringResource(R.string.share_result_shareurl), fontSize = 17.sp, color = IosColors.label, modifier = Modifier.weight(1f))
                            Image(painterResource(R.drawable.ic_sf_share), null, Modifier.size(22.dp), colorFilter = ColorFilter.tint(IosColors.accent))
                        }
                    }
                }))
            }
        }
    }
}

/** OpenUrlPopup + OpenUrlPopupContent port */
@Composable
fun OpenUrlPopupScreen(id: String, close: () -> Unit) {
    var data by remember { mutableStateOf<ApiStatus<CodeGeneratorModel.DataResponse>?>(null) }
    LaunchedEffect(Unit) { CodeGeneratorProvider.loadData(id) { data = it } }
    val d = data
    Box(Modifier.fillMaxSize()) {
        when {
            d == null -> CircularProgressIndicator(Modifier.align(Alignment.Center), color = IosColors.accent)
            d.data == null -> Column(Modifier.fillMaxSize().padding(30.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                Text(stringResource(R.string.share_openurl_interneterror), textAlign = TextAlign.Center, fontSize = 17.sp, color = IosColors.label)
                Spacer(Modifier.height(40.dp))
                Image(painterResource(R.drawable.ic_sf_wifi_slash), null, Modifier.size(200.dp), colorFilter = ColorFilter.tint(IosColors.accent))
            }
            else -> OpenUrlPopupContent(d.data!!, close)
        }
    }
}

@Composable
private fun OpenUrlPopupContent(data: CodeGeneratorModel.DataResponse, close: () -> Unit) {
    val from = data.fromId?.let { PathFinder.shared.annotationById[it] }
    val to = data.toId?.let { PathFinder.shared.annotationById[it] }
    LaunchedEffect(Unit) { if (from == null || to == null) close() }
    Column(Modifier.fillMaxSize().padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(20.dp)) {
        Text(stringResource(R.string.share_openurl_title), fontSize = 34.sp, fontWeight = FontWeight.Bold, color = IosColors.label, modifier = Modifier.padding(top = 40.dp, bottom = 30.dp))
        Column(Modifier.widthIn(max = 500.dp).fillMaxWidth()) {
            Text(stringResource(R.string.share_openurl_info), fontSize = 17.sp, color = IosColors.label)
            if (from != null && to != null) {
                Column(Modifier.fillMaxWidth().padding(top = 8.dp).clip(androidx.compose.foundation.shape.RoundedCornerShape(10.dp)).background(IosColors.secondarySystemBackground).padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) { Text(stringResource(R.string.mapinfo_route_info_from), fontSize = 17.sp, color = IosColors.label); Spacer(Modifier.width(8.dp)); SearchablePreview(from) }
                    androidx.compose.material3.HorizontalDivider(Modifier.padding(vertical = 8.dp), color = IosColors.separator)
                    Row(verticalAlignment = Alignment.CenterVertically) { Text(stringResource(R.string.mapinfo_route_info_to), fontSize = 17.sp, color = IosColors.label); Spacer(Modifier.width(8.dp)); SearchablePreview(to) }
                }
            }
            if (data.helloText.isNotEmpty()) {
                Row(Modifier.padding(top = 16.dp), verticalAlignment = Alignment.Top) {
                    Image(painterResource(R.drawable.ic_sf_text_bubble), null, Modifier.size(40.dp), colorFilter = ColorFilter.tint(IosColors.accent))
                    Spacer(Modifier.width(16.dp))
                    Column {
                        Text(stringResource(R.string.share_openurl_message), fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = IosColors.label)
                        Text(data.helloText, fontSize = 17.sp, color = IosColors.secondaryLabel)
                    }
                }
            }
        }
        Spacer(Modifier.weight(1f))
        Text(stringResource(R.string.share_openurl_openinfo), fontSize = 13.sp, color = IosColors.secondaryLabel, modifier = Modifier.padding(horizontal = 20.dp))
        AccentButton(stringResource(R.string.share_openurl_continue)) {
            if (from != null && to != null) MapInfo.exclusiveRouteDetail?.show(from, to, data.routeParams, data.allowParameterChange)
            close()
        }
    }
}
