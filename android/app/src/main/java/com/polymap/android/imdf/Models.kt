package com.polymap.android.imdf

import java.util.Locale
import java.util.UUID

/** Port of LocalizedName: picks the best value for the device locales, falling back to "ru". */
class LocalizedName(private val localizations: Map<String, String>) {
    val bestLocalizedValue: String?
        get() {
            val locales = preferredLanguages()
            for (code in locales) localizations[code]?.let { return it }
            for (code in locales.map { it.substringBefore('-') }) localizations[code]?.let { return it }
            return localizations["ru"] ?: localizations.values.firstOrNull()
        }

    operator fun get(lang: String) = localizations[lang]

    companion object {
        @Volatile
        var preferredLanguagesProvider: () -> List<String> = {
            val list = mutableListOf<String>()
            val ll = android.os.LocaleList.getDefault()
            for (i in 0 until ll.size()) list += ll[i].toLanguageTag()
            if (list.isEmpty()) list += Locale.getDefault().toLanguageTag()
            list
        }

        fun preferredLanguages(): List<String> = preferredLanguagesProvider()
    }
}

enum class Restriction(val raw: String) {
    EMPLOYEES_ONLY("employeesonly"), RESTRICTED("restricted");

    companion object {
        fun from(raw: String?) = entries.firstOrNull { it.raw == raw }
    }
}

/** A decoded IMDF feature: identifier, geometry (may be null for occupant/address/etc.) and typed properties. */
class Feature<P>(val identifier: UUID, val geometry: Geometry?, val properties: P)

object IMDF {
    class VenueProperties(
        val name: LocalizedName?,
        val altName: LocalizedName?,
        val category: String,
        val hours: String?,
        val phone: String?,
        val website: String?,
        val addressId: UUID?,
        val navpathBeginId: UUID?
    )

    class BuildingProperties(
        val name: LocalizedName?,
        val altName: LocalizedName?,
        val category: String,
        val restriction: Restriction?,
        val addressId: UUID?,
        val rotation: Double?,
        val displayPoint: Coord?
    )

    class LevelProperties(
        val name: LocalizedName?,
        val shortName: LocalizedName?,
        val ordinal: Int,
        val outdoor: Boolean,
        val category: String,
        val restriction: Restriction?,
        val addressId: UUID?,
        val buildingIds: List<UUID>,
        val displayPoint: Coord?
    )

    enum class UnitCategory(val raw: String) {
        AUDITORIUM("auditorium"), ADMINISTRATION("administration"), BRICK("brick"), CLASSROOM("classroom"),
        COLUMN("column"), CONCRETE("concrete"), CONFERENCEROOM("conferenceroom"), DRYWALL("drywall"),
        ELEVATOR("elevator"), ESCALATOR("escalator"), FIELDOFPLAY("fieldofplay"), FIRSTAID("firstaid"),
        FITNESSROOM("fitnessroom"), FOODSERVICE("foodservice"), FOODSERVICE_COFFEE("foodservice.coffee"),
        FOOTBRIDGE("footbridge"), GLASS("glass"), HUDDLEROOM("huddleroom"), KITCHEN("kitchen"),
        LABORATORY("laboratory"), LIBRARY("library"), LOBBY("lobby"), LOUNGE("lounge"), MAILROOM("mailroom"),
        MOTHERSROOM("mothersroom"), MOVIETHEATER("movietheater"), MOVINGWALKWAY("movingwalkway"),
        NONPUBLIC("nonpublic"), OFFICE("office"), OPENTOBELOW("opentobelow"), PARKING("parking"),
        PHONEROOM("phoneroom"), PLATFORM("platform"), PRIVATELOUNGE("privatelounge"), RAMP("ramp"),
        RECREATION("recreation"), RESTROOM("restroom"), RESTROOM_FAMILY("restroom.family"),
        RESTROOM_FEMALE("restroom.female"), RESTROOM_FEMALE_WHEELCHAIR("restroom.female.wheelchair"),
        RESTROOM_MALE("restroom.male"), RESTROOM_MALE_WHEELCHAIR("restroom.male.wheelchair"),
        RESTROOM_TRANSGENDER("restroom.transgender"), RESTROOM_TRANSGENDER_WHEELCHAIR("restroom.transgender.wheelchair"),
        RESTROOM_UNISEX("restroom.unisex"), RESTROOM_UNISEX_WHEELCHAIR("restroom.unisex.wheelchair"),
        RESTROOM_WHEELCHAIR("restroom.wheelchair"), ROAD("road"), ROOM("room"), SERVERROOM("serverroom"),
        SHOWER("shower"), SMOKINGAREA("smokingarea"), SECURITY("security"), STAIRS("stairs"), SHOP("shop"),
        STEPS("steps"), STORAGE("storage"), STRUCTURE("structure"), TERRACE("terrace"), THEATER("theater"),
        UNENCLOSEDAREA("unenclosedarea"), UNSPECIFIED("unspecified"), VEGETATION("vegetation"),
        WAITINGROOM("waitingroom"), WARDROBE("wardrobe"), WALKWAY("walkway"), WALKWAY_ISLAND("walkway.island"),
        WOOD("wood");

        val isRestroom get() = this == RESTROOM || this == RESTROOM_FEMALE || this == RESTROOM_MALE

        companion object {
            fun from(raw: String?) = entries.firstOrNull { it.raw == raw } ?: UNSPECIFIED
        }
    }

    class UnitProperties(
        val name: LocalizedName?,
        val altName: LocalizedName?,
        val levelId: UUID,
        val category: UnitCategory,
        val restriction: Restriction?,
        val displayPoint: Coord?
    )

    class Door(val type: String?, val material: String?, val automatic: Boolean)

    class OpeningProperties(
        val name: LocalizedName?,
        val altName: LocalizedName?,
        val levelId: UUID,
        val category: String?,
        val unitCategory: UnitCategory?,
        val unitRestriction: Restriction?,
        val door: Door?,
        val displayPoint: Coord?
    )

    enum class EnviromentCategory(val raw: String) {
        ROAD_MAIN("road.main"), ROAD_DIRT("road.dirt"), ROAD_PEDESTRIAN_MAIN("road.pedestrian.main"),
        ROAD_PEDESTRIAN_SECOND("road.pedestrian.second"), ROAD_PEDESTRIAN_TREADMILL("road.pedestrian.treadmill"),
        GRASS("grass"), GRASS_STADION("grass.stadion"), TREE("tree"), FOREST("forest"),
        FENCE_MAIN("fence.main"), FENCE_SECOND("fence.second"), SAND("sand"), WATER("water"), UNKNOWN("unknown");

        companion object {
            fun from(raw: String?) = entries.firstOrNull { it.raw == raw } ?: UNKNOWN
        }
    }

    class EnviromentUnitProperties(
        val name: LocalizedName?,
        val altName: LocalizedName?,
        val category: EnviromentCategory,
        val displayPoint: Coord?
    )

    class AddressProperties(
        val address: String?,
        val unit: String?,
        val locality: String?,
        val province: String?,
        val country: String?,
        val postalCode: String?,
        val postalCodeExt: String?,
        val postalCodeVanity: String?
    ) {
        /** IMDF.Address.addressString() port */
        fun addressString(): String {
            var result = ""
            unit?.let { result += it }
            address?.let { result += "\n$it" }
            postalCode?.let { result += "\n$it" }
            return result
        }
    }

    enum class EnviromentAmenityCategory(val raw: String) {
        PARKING_CAR("parking.car"), PARKING_BICYCLE("parking.bicycle"), BANCH("banch"), METRO("metro"),
        TRANSPORT_BUS("transport.bus"), TRANSPORT_TRUM("transport.trum"), STADIUM("stadium"),
        STADIUM_FOOTBALL("stadium.football"), STADIUM_BASKETBALL("stadium.basketball"),
        STADIUM_VOLLEYBALL("stadium.volleyball"), ENTRANCE("entrance"), PLAYGROUND("playground"), UNKNOWN("unknown");

        companion object {
            fun from(raw: String?) = entries.firstOrNull { it.raw == raw } ?: UNKNOWN
        }
    }

    class EnviromentAmenityProperties(
        val name: LocalizedName?,
        val altName: LocalizedName?,
        val category: EnviromentAmenityCategory,
        val detailLevel: Int
    )

    enum class AmenityCategory(val raw: String) {
        ATM("atm"), COPYMACHINE("copymachine"), EATINGDRINKING("eatingdrinking"), ELEVATOR("elevator"),
        ESCALATOR("escalator"), ENTRY("entry"), FAREGATE("faregate"), INFORMATION("information"),
        LIBRARY("library"), RESTROOM("restroom"), RESTROOM_FEMALE("restroom.female"), RESTROOM_MALE("restroom.male"),
        SEAT("seat"), SECURITY("security"), SECURITY_CHECKPOINT("security.checkpoint"), SMOKINGAREA("smokingarea"),
        STUDENTSERVICES("studentservices"), SWIMMINGPOOL("swimmingpool"), VENDINGMACHINE("vendingmachine"),
        UNSPECIFIED("unspecified"), STAIRS("stairs");

        companion object {
            fun from(raw: String?) = entries.firstOrNull { it.raw == raw } ?: UNSPECIFIED
        }
    }

    class AmenityProperties(
        val name: LocalizedName?,
        val altName: LocalizedName?,
        val unitIds: List<UUID>,
        val category: AmenityCategory,
        val detailLevel: Int,
        val hours: String?,
        val phone: String?,
        val website: String?,
        val addressId: UUID?
    )

    class AuthorDetail(
        val title: LocalizedName,
        val description: LocalizedName,
        val authorsTitle: LocalizedName,
        val authors: List<LocalizedName>
    )

    class Author(val shortInfo: LocalizedName, val detail: AuthorDetail)

    class AttractionProperties(
        val name: LocalizedName?,
        val altName: LocalizedName?,
        val shortName: LocalizedName?,
        val buildingId: UUID,
        val category: String,
        val image: String?,
        val authors: Author?
    )

    enum class DetailCategory(val raw: String) {
        CROSSWALK("crosswalk"), ROAD_MARKING_MAIN("road.marking.main"), PARKING_MARKING("parking.marking"),
        PARKING_BIG("parking.big"), FENCE_MAIN("fence.main"), FENCE_HEIGTH("fence.heigth"), STEPS("steps"),
        INDOOR_STEPS("indoor.steps"), INDOOR_STAIRS("indoor.stairs"), TREADMILL_MARKING("treadmill.marking"),
        STADION_GRASS_MARKING("stadion.grass.marking"), UNKNOWN("unknown");

        /** Line widths from Detail.configurate(renderer:) */
        val lineWidth: Float
            get() = when (this) {
                CROSSWALK -> 7.3f
                ROAD_MARKING_MAIN -> 2.5f
                PARKING_MARKING -> 2f
                PARKING_BIG -> 5f
                FENCE_MAIN -> 3f
                FENCE_HEIGTH -> 2f
                STEPS -> 1f
                INDOOR_STEPS, INDOOR_STAIRS -> 0.5f
                STADION_GRASS_MARKING -> 3f
                TREADMILL_MARKING -> 0.6f
                UNKNOWN -> 1f
            }

        companion object {
            fun from(raw: String?) = entries.firstOrNull { it.raw == raw } ?: UNKNOWN
        }
    }

    class DetailProperties(val category: DetailCategory, val levelId: UUID?)

    class AnchorProperties(val unitId: UUID, val addressId: UUID?)

    enum class OccupantCategory(val raw: String) {
        AUDITORIUM("auditorium"), ADMINISTRATION("administration"), CLASSROOM("classroom"), LABORATORY("laboratory"),
        LIBRARY("library"), SOUVENIRS("souvenirs"), FOODSERVICE("foodservice"), FOODSERVICE_COFFEE("foodservice.coffee"),
        SECURITY("security"), WARDROBE("wardrobe"), UNSPECIFIED("unspecified"), RESTROOM("restroom"),
        RESTROOM_FEMALE("restroom.female"), RESTROOM_MALE("restroom.male"), RESTROOM_WHEELCHAIR("restroom.wheelchair"),
        TICKET("ticket"), MUSEUM("museum"), CONCERT_HALL("concert.hall"), ARCHIVE("archive"),
        READING_ROOM("reading.room"), ACADEMIC_COUNCIL("academic.council");

        val isRestroom get() = this == RESTROOM || this == RESTROOM_FEMALE || this == RESTROOM_MALE || this == RESTROOM_WHEELCHAIR

        companion object {
            fun from(raw: String?) = entries.firstOrNull { it.raw == raw } ?: UNSPECIFIED
        }
    }

    class OccupantProperties(
        val name: LocalizedName?,
        val shortName: LocalizedName?,
        val category: OccupantCategory,
        val anchorId: UUID,
        val hours: String?,
        val phone: String?,
        val email: String?,
        val website: String?,
        val correlationId: UUID?
    )

    enum class NavPathTag(val raw: String) {
        DIRT("dirt"), SERVICE("service");

        companion object {
            fun from(raw: String?) = entries.firstOrNull { it.raw == raw }
        }
    }

    class NavPathProperties(
        val buildingId: UUID?,
        val levelId: UUID?,
        val neighbours: List<UUID>,
        val weight: Float,
        val tags: List<NavPathTag>
    )

    class NavPathAssocietedProperties(val pathNodeId: UUID, val associetedId: UUID)
}
