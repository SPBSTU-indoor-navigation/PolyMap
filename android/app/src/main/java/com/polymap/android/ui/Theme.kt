package com.polymap.android.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.polymap.android.R

/** iOS system colors resolved from resources (light/dark aware). */
object IosColors {
    val accent: Color @Composable get() = colorResource(R.color.accent)
    val label: Color @Composable get() = colorResource(R.color.label)
    val secondaryLabel: Color @Composable get() = colorResource(R.color.secondary_label)
    val groupedBackground: Color @Composable get() = colorResource(R.color.system_grouped_background)
    val secondaryGroupedBackground: Color @Composable get() = colorResource(R.color.secondary_system_grouped_background)
    val systemBackground: Color @Composable get() = colorResource(R.color.system_background)
    val secondarySystemBackground: Color @Composable get() = colorResource(R.color.secondary_system_background)
    val separator: Color @Composable get() = colorResource(R.color.separator)
    val red: Color @Composable get() = colorResource(R.color.system_red)
    val blue: Color @Composable get() = colorResource(R.color.system_blue)
    val gray: Color @Composable get() = colorResource(R.color.system_gray)
}

@Composable
fun PolyMapTheme(content: @Composable () -> Unit) {
    val dark = isSystemInDarkTheme()
    val accent = colorResource(R.color.accent)
    val scheme = if (dark) darkColorScheme(
        primary = accent, onPrimary = Color.White, secondary = accent,
        background = colorResource(R.color.system_grouped_background),
        surface = colorResource(R.color.secondary_system_grouped_background),
        onBackground = colorResource(R.color.label), onSurface = colorResource(R.color.label),
        surfaceVariant = colorResource(R.color.system_gray5)
    ) else lightColorScheme(
        primary = accent, onPrimary = Color.White, secondary = accent,
        background = colorResource(R.color.system_grouped_background),
        surface = colorResource(R.color.secondary_system_grouped_background),
        onBackground = colorResource(R.color.label), onSurface = colorResource(R.color.label),
        surfaceVariant = colorResource(R.color.system_gray5)
    )
    MaterialTheme(colorScheme = scheme, content = content)
}

/** iOS inset-grouped section: optional header/footer and a rounded card with rows separated by dividers. */
@Composable
fun GroupedSection(
    header: String? = null,
    footer: String? = null,
    modifier: Modifier = Modifier,
    transparent: Boolean = false,
    rows: List<@Composable () -> Unit>
) {
    Column(modifier = modifier.fillMaxWidth().padding(horizontal = 16.dp)) {
        header?.let {
            Text(it.uppercase(), fontSize = 13.sp, color = IosColors.secondaryLabel, modifier = Modifier.padding(start = 16.dp, bottom = 6.dp))
        }
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(10.dp))
                .background(if (transparent) Color.Transparent else IosColors.secondaryGroupedBackground)
        ) {
            rows.forEachIndexed { i, row ->
                row()
                if (i < rows.size - 1 && !transparent) HorizontalDivider(color = IosColors.separator, thickness = 0.5.dp, modifier = Modifier.padding(start = 16.dp))
            }
        }
        footer?.let {
            Text(it, fontSize = 13.sp, color = IosColors.secondaryLabel, modifier = Modifier.padding(start = 16.dp, top = 6.dp, end = 16.dp))
        }
        Spacer(Modifier.height(20.dp))
    }
}

@Composable
fun GroupedRow(onClick: (() -> Unit)? = null, padding: PaddingValues = PaddingValues(horizontal = 16.dp, vertical = 11.dp), content: @Composable () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 44.dp)
            .then(if (onClick != null) Modifier.clickable { onClick() } else Modifier)
            .padding(padding),
        contentAlignment = Alignment.CenterStart
    ) { content() }
}

/** The big accent "Continue" style button (max width 300, height 46, radius 10). */
@Composable
fun AccentButton(text: String, enabled: Boolean = true, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        enabled = enabled,
        shape = RoundedCornerShape(10.dp),
        colors = ButtonDefaults.buttonColors(containerColor = IosColors.accent, disabledContainerColor = IosColors.secondaryLabel, contentColor = Color.White, disabledContentColor = Color.White),
        modifier = Modifier.widthIn(max = 300.dp).fillMaxWidth().height(46.dp)
    ) {
        Text(text, fontSize = 17.sp, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
fun Context_dp(): Float = LocalContext.current.resources.displayMetrics.density
