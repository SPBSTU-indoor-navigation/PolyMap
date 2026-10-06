package com.polymap.android.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.polymap.android.R
import com.polymap.android.map.annotations.AmenityAnnotation
import com.polymap.android.map.annotations.AttractionAnnotation
import com.polymap.android.map.annotations.EnviromentAmenityAnnotation
import com.polymap.android.map.annotations.Searchable
import com.polymap.android.ui.IosColors

/** SearchablePreview port: 40dp icon + title + "place • floor". */
@Composable
fun SearchablePreview(searchable: Searchable, modifier: Modifier = Modifier) {
    Row(modifier = modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(40.dp), contentAlignment = Alignment.Center) {
            when (searchable) {
                is AttractionAnnotation -> {
                    Box(
                        Modifier.fillMaxSize().clip(CircleShape).background(colorResource(R.color.ios_attractionborder))
                            .padding(2.dp).clip(CircleShape).background(colorResource(R.color.ios_attractionbackground)),
                        contentAlignment = Alignment.Center
                    ) {
                        val sprite = searchable.annotationSprite
                        if (sprite != null) Image(painterResource(sprite), null, Modifier.fillMaxSize().clip(CircleShape), contentScale = ContentScale.Crop)
                        else Text(searchable.additionalTitle ?: "", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = colorResource(R.color.ios_attractionborder), maxLines = 1)
                    }
                }
                is AmenityAnnotation, is EnviromentAmenityAnnotation -> {
                    Box(Modifier.fillMaxSize().padding(3.dp).clip(RoundedCornerShape(8.dp)).background(colorResource(searchable.backgroundSpriteColor)), contentAlignment = Alignment.Center) {
                        searchable.annotationSprite?.let { Image(painterResource(it), null, Modifier.fillMaxSize().padding(7.dp), colorFilter = ColorFilter.tint(Color.White)) }
                    }
                }
                else -> {
                    Box(Modifier.fillMaxSize().clip(CircleShape).background(colorResource(searchable.backgroundSpriteColor)), contentAlignment = Alignment.Center) {
                        searchable.annotationSprite?.let { Image(painterResource(it), null, Modifier.fillMaxSize().padding(10.dp), colorFilter = ColorFilter.tint(Color.White)) }
                    }
                }
            }
        }
        Spacer(Modifier.width(8.dp))
        Column(Modifier.weight(1f)) {
            Text(searchable.mainTitle ?: "", fontSize = 17.sp, color = IosColors.label, maxLines = 1, overflow = TextOverflow.Ellipsis)
            val place = searchable.place; val floor = searchable.floor
            if (place != null && floor != null) {
                Text("$place • $floor", fontSize = 15.sp, color = IosColors.secondaryLabel, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
        }
    }
}

/** Inline navigation bar for modal sheets (title + optional leading/trailing buttons). */
@Composable
fun SheetNavBar(title: String, leading: (@Composable () -> Unit)? = null, trailing: (@Composable () -> Unit)? = null) {
    Box(Modifier.fillMaxWidth().height(44.dp)) {
        Box(Modifier.align(Alignment.CenterStart)) { leading?.invoke() }
        Text(title, fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = IosColors.label, modifier = Modifier.align(Alignment.Center))
        Box(Modifier.align(Alignment.CenterEnd)) { trailing?.invoke() }
    }
}

@Composable
fun NavTextButton(text: String, enabled: Boolean = true, onClick: () -> Unit) {
    TextButton(onClick = onClick, enabled = enabled) {
        Text(text, fontSize = 17.sp, color = if (enabled) IosColors.accent else IosColors.secondaryLabel)
    }
}
