package com.polymap.android.map.annotations

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import com.polymap.android.R
import com.polymap.android.imdf.Coord
import com.polymap.android.imdf.IMDF
import com.polymap.android.map.overlays.Building
import com.polymap.android.map.overlays.Level
import java.util.UUID

/** Searchable protocol port. Colors / sprites are resource ids. */
interface Searchable {
    val annotation: BaseAnnotation
    @get:DrawableRes val annotationSprite: Int?
    @get:ColorRes val backgroundSpriteColor: Int
    val mainTitle: String?
    val additionalTitle: String? get() = ""
    val place: String?
    val shortPlace: String?
    val floor: String?
    val searchTags: List<String>
}

interface IndoorAnnotation {
    val building: Building
    val level: Level
}

interface AmenityDetailLevel {
    val detailLevel: AmenityAnnotation.DetailLevel
}

abstract class BaseAnnotation(val imdfID: UUID, val coordinate: Coord) : Searchable {
    abstract val title: String?
    override val annotation: BaseAnnotation get() = this
    override fun equals(other: Any?) = this === other
    override fun hashCode() = System.identityHashCode(this)
}

/** Maps IMDF sprite names (UIImage(named:)) to drawable resources. */
object Sprites {
    private val map: Map<String, Int> = mapOf(
        "academic.council" to R.drawable.ic_academic_council,
        "administration" to R.drawable.ic_administration,
        "archive" to R.drawable.ic_archive,
        "banch" to R.drawable.ic_banch,
        "classroom" to R.drawable.ic_classroom,
        "concert.hall" to R.drawable.ic_concert_hall,
        "default" to R.drawable.ic_default,
        "elevator" to R.drawable.ic_elevator,
        "entrance" to R.drawable.ic_entrance,
        "foodservice.coffee" to R.drawable.ic_foodservice_coffee,
        "foodservice" to R.drawable.ic_foodservice,
        "laboratorium" to R.drawable.ic_laboratorium,
        "lecture" to R.drawable.ic_lecture,
        "library" to R.drawable.ic_library,
        "metro" to R.drawable.ic_metro,
        "museum" to R.drawable.ic_museum,
        "parking.bicycle" to R.drawable.ic_parking_bicycle,
        "parking.car" to R.drawable.ic_parking_car,
        "playground" to R.drawable.ic_playground,
        "reading.room" to R.drawable.ic_reading_room,
        "restroom.female" to R.drawable.ic_restroom_female,
        "restroom" to R.drawable.ic_restroom,
        "restroom.male" to R.drawable.ic_restroom_male,
        "restroom.wheelchair" to R.drawable.ic_restroom_wheelchair,
        "security" to R.drawable.ic_security,
        "souvenirs" to R.drawable.ic_souvenirs,
        "stadium.basketball" to R.drawable.ic_stadium_basketball,
        "stadium.football" to R.drawable.ic_stadium_football,
        "stadium" to R.drawable.ic_stadium,
        "stadium.volleyball" to R.drawable.ic_stadium_volleyball,
        "stairs" to R.drawable.ic_stairs,
        "ticket" to R.drawable.ic_ticket,
        "vendingmachine" to R.drawable.ic_vendingmachine,
        "wardrobe" to R.drawable.ic_wardrobe,
        "warning" to R.drawable.ic_warning,
        "unspecified" to R.drawable.ic_warning
    )

    private val images: Map<String, Int> = mapOf(
        "Gydro" to R.drawable.img_gydro
    )

    @DrawableRes
    fun named(name: String?): Int? = name?.let { map[it] }

    @DrawableRes
    fun image(name: String?): Int? = name?.let { images[it] }

    val default = R.drawable.ic_default
}

object AnnotationColors {
    /** UIColor(named: colorAssetName + "-annotation") lookup. */
    @ColorRes
    fun occupantBackground(category: IMDF.OccupantCategory): Int = when (category) {
        IMDF.OccupantCategory.ACADEMIC_COUNCIL -> R.color.ios_academic_council_annotation
        IMDF.OccupantCategory.ADMINISTRATION -> R.color.ios_administration_annotation
        IMDF.OccupantCategory.ARCHIVE -> R.color.ios_archive_annotation
        IMDF.OccupantCategory.AUDITORIUM -> R.color.ios_auditorium_annotation
        IMDF.OccupantCategory.CLASSROOM -> R.color.ios_classroom_annotation
        IMDF.OccupantCategory.CONCERT_HALL -> R.color.ios_concert_hall_annotation
        IMDF.OccupantCategory.FOODSERVICE -> R.color.ios_foodservice_annotation
        IMDF.OccupantCategory.FOODSERVICE_COFFEE -> R.color.ios_foodservice_coffee_annotation
        IMDF.OccupantCategory.LABORATORY -> R.color.ios_laboratory_annotation
        IMDF.OccupantCategory.LIBRARY -> R.color.ios_library_annotation
        IMDF.OccupantCategory.MUSEUM -> R.color.ios_museum_annotation
        IMDF.OccupantCategory.READING_ROOM -> R.color.ios_reading_room_annotation
        IMDF.OccupantCategory.RESTROOM, IMDF.OccupantCategory.RESTROOM_MALE,
        IMDF.OccupantCategory.RESTROOM_FEMALE, IMDF.OccupantCategory.RESTROOM_WHEELCHAIR -> R.color.ios_restroom_annotation
        IMDF.OccupantCategory.SECURITY -> R.color.ios_security_annotation
        IMDF.OccupantCategory.SOUVENIRS -> R.color.ios_souvenirs_annotation
        IMDF.OccupantCategory.TICKET -> R.color.ios_ticket_annotation
        IMDF.OccupantCategory.WARDROBE -> R.color.ios_wardrobe_annotation
        IMDF.OccupantCategory.UNSPECIFIED -> R.color.ios_default_annotation
    }

    /** UIColor(named: colorAssetName + "-annotation-label") ?? "-annotation" ?? default label */
    @ColorRes
    fun occupantLabel(category: IMDF.OccupantCategory): Int = when (category) {
        IMDF.OccupantCategory.CLASSROOM -> R.color.ios_classroom_annotation_label
        IMDF.OccupantCategory.LABORATORY -> R.color.ios_laboratory_annotation_label
        IMDF.OccupantCategory.UNSPECIFIED -> R.color.ios_default_annotation_label
        else -> occupantBackground(category)
    }
}

class OccupantAnnotation(
    coordinate: Coord,
    imdfID: UUID,
    val properties: IMDF.OccupantProperties,
    val address: IMDF.AddressProperties?,
    override val level: Level
) : BaseAnnotation(imdfID, coordinate), IndoorAnnotation {

    enum class DetailLevel(val raw: Int) {
        CIRCLE_PRIMARY(0), CIRCLE_SECONDARY(1), CIRCLE_WITHOUT_LABEL(2), POINT_PRIMARY(3), POINT_SECONDARY(4)
    }

    override val title: String? get() = properties.shortName?.bestLocalizedValue
    override val building: Building get() = level.building

    val sprite: Int by lazy {
        val imageName = when (properties.category) {
            IMDF.OccupantCategory.CLASSROOM -> "classroom"
            IMDF.OccupantCategory.LABORATORY -> "laboratorium"
            IMDF.OccupantCategory.AUDITORIUM -> "lecture"
            else -> properties.category.raw
        }
        Sprites.named(imageName) ?: Sprites.default
    }

    @get:ColorRes
    override val backgroundSpriteColor: Int get() = AnnotationColors.occupantBackground(properties.category)

    @get:ColorRes
    val titleLabelColor: Int get() = AnnotationColors.occupantLabel(properties.category)

    val detailLevel: DetailLevel
        get() = when (properties.category) {
            IMDF.OccupantCategory.RESTROOM, IMDF.OccupantCategory.RESTROOM_WHEELCHAIR,
            IMDF.OccupantCategory.RESTROOM_MALE, IMDF.OccupantCategory.RESTROOM_FEMALE,
            IMDF.OccupantCategory.SECURITY -> DetailLevel.CIRCLE_WITHOUT_LABEL
            IMDF.OccupantCategory.WARDROBE, IMDF.OccupantCategory.TICKET -> DetailLevel.CIRCLE_WITHOUT_LABEL
            IMDF.OccupantCategory.SOUVENIRS, IMDF.OccupantCategory.FOODSERVICE_COFFEE,
            IMDF.OccupantCategory.FOODSERVICE -> DetailLevel.CIRCLE_WITHOUT_LABEL
            else -> DetailLevel.POINT_SECONDARY
        }

    override val annotationSprite: Int get() = sprite
    override val mainTitle: String? get() = properties.name?.bestLocalizedValue
    override val place: String? get() = level.building.properties.name?.bestLocalizedValue
    override val shortPlace: String? get() = level.building.properties.altName?.bestLocalizedValue
    override val floor: String? get() = level.properties.name?.bestLocalizedValue
    override val searchTags: List<String> get() = emptyList()

    companion object {
        val levelProcessor: DetailLevelProcessor<DetailLevelState> = DetailLevelProcessor<DetailLevelState>().apply {
            builder(DetailLevel.CIRCLE_WITHOUT_LABEL.raw)
                .add(0f, DetailLevelState.MIN)
                .add(19f, DetailLevelState.NORMAL)
                .add(21f, DetailLevelState.BIG)
            builder(DetailLevel.POINT_PRIMARY.raw)
                .add(19.6f, DetailLevelState.MIN)
                .add(20.2f, DetailLevelState.NORMAL)
                .add(21.5f, DetailLevelState.BIG)
            builder(DetailLevel.POINT_SECONDARY.raw)
                .add(17.0f, DetailLevelState.HIDE)
                .add(19.6f, DetailLevelState.MIN)
                .add(20.2f, DetailLevelState.NORMAL)
                .add(21.5f, DetailLevelState.BIG)
        }
    }
}

class AmenityAnnotation(
    coordinate: Coord,
    imdfID: UUID,
    val properties: IMDF.AmenityProperties,
    detailLevel: Int,
    override val level: Level
) : BaseAnnotation(imdfID, coordinate), IndoorAnnotation, AmenityDetailLevel {

    enum class DetailLevel(val raw: Int) {
        ALWAYS_SHOW_BIG(0), ALWAYS_SHOW(1), MIN(2), HIDDEN_MIN(3), ALWAYS_SHOW_MIN(4);

        companion object {
            fun from(raw: Int) = entries.firstOrNull { it.raw == raw } ?: MIN
        }
    }

    override val detailLevel: DetailLevel = DetailLevel.from(detailLevel)
    override val title: String? get() = properties.altName?.bestLocalizedValue
    override val building: Building get() = level.building
    val sprite: Int by lazy { Sprites.named(properties.category.raw) ?: Sprites.default }

    override val annotationSprite: Int get() = sprite
    override val backgroundSpriteColor: Int get() = R.color.system_blue
    override val mainTitle: String? get() = properties.altName?.bestLocalizedValue
    override val place: String? get() = level.building.properties.name?.bestLocalizedValue
    override val shortPlace: String? get() = level.building.properties.altName?.bestLocalizedValue
    override val floor: String? get() = level.properties.name?.bestLocalizedValue
    override val searchTags: List<String> get() = emptyList()

    companion object {
        val levelProcessor: DetailLevelProcessor<DetailLevelState> = DetailLevelProcessor<DetailLevelState>().apply {
            builder(DetailLevel.ALWAYS_SHOW_BIG.raw)
                .add(0f, DetailLevelState.NORMAL)
                .add(17f, DetailLevelState.BIG)
            builder(DetailLevel.ALWAYS_SHOW.raw)
                .add(10f, DetailLevelState.HIDE)
                .add(16f, DetailLevelState.MIN)
                .add(18.5f, DetailLevelState.BIG)
            builder(DetailLevel.MIN.raw)
                .add(0f, DetailLevelState.HIDE)
                .add(17f, DetailLevelState.MIN)
                .add(18.5f, DetailLevelState.NORMAL)
                .add(21f, DetailLevelState.BIG)
            builder(DetailLevel.HIDDEN_MIN.raw)
                .add(0f, DetailLevelState.HIDE)
                .add(19.5f, DetailLevelState.MIN)
                .add(21.0f, DetailLevelState.NORMAL)
                .add(22f, DetailLevelState.BIG)
            builder(DetailLevel.ALWAYS_SHOW_MIN.raw)
                .add(0f, DetailLevelState.NORMAL)
                .add(22f, DetailLevelState.BIG)
        }
    }
}

class EnviromentAmenityAnnotation(
    coordinate: Coord,
    imdfID: UUID,
    val properties: IMDF.EnviromentAmenityProperties,
    detailLevel: Int
) : BaseAnnotation(imdfID, coordinate), AmenityDetailLevel {

    override val detailLevel: AmenityAnnotation.DetailLevel = AmenityAnnotation.DetailLevel.from(detailLevel)
    override val title: String? get() = properties.altName?.bestLocalizedValue
    val sprite: Int by lazy { Sprites.named(properties.category.raw) ?: Sprites.default }

    override val annotationSprite: Int get() = sprite
    override val backgroundSpriteColor: Int get() = R.color.system_blue
    override val mainTitle: String? get() = properties.altName?.bestLocalizedValue
    override val place: String? get() = null
    override val shortPlace: String? get() = null
    override val floor: String? get() = null
    override val searchTags: List<String> get() = emptyList()
}

class AttractionAnnotation(
    coordinate: Coord,
    imdfID: UUID,
    val properties: IMDF.AttractionProperties,
    val building: Building
) : BaseAnnotation(imdfID, coordinate) {

    override val title: String? get() = properties.name?.bestLocalizedValue
    override val annotationSprite: Int? by lazy { Sprites.image(properties.image) }
    override val backgroundSpriteColor: Int get() = android.R.color.transparent
    override val mainTitle: String? get() = properties.name?.bestLocalizedValue
    override val place: String? get() = null
    override val shortPlace: String? get() = null
    override val floor: String? get() = null
    override val searchTags: List<String> get() = emptyList()
    override val additionalTitle: String? get() = properties.shortName?.bestLocalizedValue
}

// ------------------------------------------------------------------ Detail level processing (Shared.swift port)

enum class DetailLevelState { BIG, NORMAL, MIN, HIDE, UNDEFINED }

class DetailLevelProcessor<T> {
    private class Size<T>(val size: Float, val state: T)

    inner class Builder(private val levelDetail: Int) {
        fun add(mapSize: Float, state: T): Builder {
            this@DetailLevelProcessor.add(levelDetail, mapSize, state)
            return this
        }
    }

    private val sizes = HashMap<Int, MutableList<Size<T>>>()

    fun add(forDetailLevel: Int, mapSize: Float, state: T) {
        val list = sizes.getOrPut(forDetailLevel) { mutableListOf() }
        list.add(Size(mapSize, state))
        list.sortBy { it.size }
    }

    fun builder(forDetailLevel: Int) = Builder(forDetailLevel)

    fun evaluate(forDetailLevel: Int, mapSize: Float): T? {
        val list = sizes[forDetailLevel] ?: return null
        var lastSize = list.first()
        if (mapSize < lastSize.size) return lastSize.state
        for (size in list) {
            if (lastSize.size < mapSize && mapSize < size.size) return lastSize.state
            lastSize = size
        }
        return lastSize.state
    }
}

val defaultDetailLevelProcessor: DetailLevelProcessor<DetailLevelState> = DetailLevelProcessor<DetailLevelState>().apply {
    builder(0).add(0f, DetailLevelState.NORMAL).add(17f, DetailLevelState.BIG)
    builder(1).add(10f, DetailLevelState.HIDE).add(16f, DetailLevelState.MIN).add(18.5f, DetailLevelState.BIG)
    builder(2).add(0f, DetailLevelState.HIDE).add(17f, DetailLevelState.MIN).add(18.5f, DetailLevelState.NORMAL).add(21f, DetailLevelState.BIG)
    builder(3).add(0f, DetailLevelState.HIDE).add(19.5f, DetailLevelState.MIN).add(21.0f, DetailLevelState.NORMAL).add(22f, DetailLevelState.BIG)
    builder(4).add(0f, DetailLevelState.HIDE).add(20.3f, DetailLevelState.MIN).add(21.3f, DetailLevelState.NORMAL).add(22.3f, DetailLevelState.BIG)
}
