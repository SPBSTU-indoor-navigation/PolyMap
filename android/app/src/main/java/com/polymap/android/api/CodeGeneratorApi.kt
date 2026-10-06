package com.polymap.android.api

import android.content.Context
import com.polymap.android.storage.RouteParameters
import com.polymap.android.storage.ShareRouteCacheStorage
import java.io.File
import java.util.UUID

object CodeGeneratorModel {
    class ServerStatus(val status: String = "", val appclip: Boolean = false, val qr: Boolean = false)

    class GenerateResponse(val codeID: String = "", val base: String = "", val codeUrl: String = "")

    class DataResponse(
        val from: String = "",
        val to: String = "",
        val helloText: String = "",
        val asphalt: Boolean = false,
        val serviceRoute: Boolean = false,
        val allowParameterChange: Boolean = false
    ) {
        val fromId: UUID? get() = runCatching { UUID.fromString(from) }.getOrNull()
        val toId: UUID? get() = runCatching { UUID.fromString(to) }.getOrNull()
        val routeParams: RouteParameters get() = RouteParameters(asphalt, serviceRoute)
    }
}

/** ShareDialog color / logo / badge variants (moved out of the SwiftUI view). */
object ShareVariants {
    class Preset(val background: String, val primary: String, val secondary: String, val badgeTextColor: String)
    class ColorPreset(val normal: Preset, val inverted: Preset)

    enum class Variant(val raw: String, val preset: ColorPreset) {
        BLACK("black", ColorPreset(Preset("000", "fff", "888", "fff"), Preset("fff", "000", "888", "000"))),
        GRAY("gray", ColorPreset(Preset("777", "fff", "aaa", "fff"), Preset("fff", "777", "aaa", "000"))),
        RED("red", ColorPreset(Preset("ff3b30", "fff", "f99", "fff"), Preset("fff", "ff3b30", "f99", "000"))),
        ORANGE("orange", ColorPreset(Preset("EE7733", "fff", "eb8", "fff"), Preset("fff", "EE7733", "eb8", "000"))),
        GREEN("green", ColorPreset(Preset("33AA22", "fff", "9d9", "fff"), Preset("fff", "33AA22", "9d9", "000"))),
        TEAL("teal", ColorPreset(Preset("00A6A1", "fff", "8dc", "fff"), Preset("fff", "00A6A1", "8dc", "000"))),
        BLUE("blue", ColorPreset(Preset("007AFF", "fff", "7df", "fff"), Preset("fff", "007AFF", "7df", "000"))),
        INDIGO("indigo", ColorPreset(Preset("5856D6", "fff", "bbe", "fff"), Preset("fff", "5856D6", "bbe", "000"))),
        PURPLE("purple", ColorPreset(Preset("CC73E1", "fff", "ebe", "fff"), Preset("fff", "CC73E1", "ebe", "000")));

        companion object {
            fun from(raw: String?) = entries.firstOrNull { it.raw == raw }
        }
    }

    class ColorVariant(var inverted: Boolean, var currentVariant: Variant) {
        val preset: Preset get() = if (inverted) currentVariant.preset.inverted else currentVariant.preset.normal

        fun saveToStorage() {
            com.polymap.android.storage.Storage.set("colorVariant.inverted", inverted)
            com.polymap.android.storage.Storage.set("colorVariant.currentVariant", currentVariant.raw)
        }

        companion object {
            fun loadFromStorage(): ColorVariant? {
                val inverted = com.polymap.android.storage.Storage.bool("colorVariant.inverted") ?: return null
                val v = Variant.from(com.polymap.android.storage.Storage.string("colorVariant.currentVariant")) ?: return null
                return ColorVariant(inverted, v)
            }
        }
    }

    enum class LogoVariant(val raw: String) {
        CAMERA("camera"), PHONE("phone");

        fun saveToStorage() = com.polymap.android.storage.Storage.set("logoVariantValue", raw)

        companion object {
            fun loadFromStorage() = entries.firstOrNull { it.raw == com.polymap.android.storage.Storage.string("logoVariantValue") }
        }
    }

    enum class QRLogoVariant(val raw: String) {
        USE("use"), NONE("none");

        fun saveToStorage() = com.polymap.android.storage.Storage.set("QRlogoVariantValue", raw)

        companion object {
            fun loadFromStorage() = entries.firstOrNull { it.raw == com.polymap.android.storage.Storage.string("QRlogoVariantValue") }
        }
    }

    enum class BadgeVariant(val raw: String) {
        BADGE("badge"), CIRCLE("circle");

        fun saveToStorage() = com.polymap.android.storage.Storage.set("badgeVariantValue", raw)

        companion object {
            fun loadFromStorage() = entries.firstOrNull { it.raw == com.polymap.android.storage.Storage.string("badgeVariantValue") }
        }
    }

    /** ShareDialog.Settings port */
    class Settings(
        val color: ColorVariant?,
        val logo: LogoVariant?,
        val badge: BadgeVariant?,
        val qrLogoVariant: QRLogoVariant?,
        val isQR: Boolean,
        val from: UUID,
        val to: UUID,
        val text: String?,
        val routeParams: RouteParameters,
        val allowParameterChange: Boolean
    ) {
        val routeSettings get() = CodeGeneratorProvider.RouteSettings(isQR, from, to, text, routeParams, allowParameterChange)
    }
}

object CodeGeneratorProvider {
    private const val BASE_URL = NetworkShared.BASE_URL

    class RouteSettings(
        val isQR: Boolean, val from: UUID, val to: UUID, val text: String?,
        val routeParams: RouteParameters, val allowParameterChange: Boolean
    )

    private fun <T> load(url: String, method: HttpMethod, params: Map<String, String>, type: Class<T>, jsonEncoding: Boolean = false, timeoutSec: Long = 30, completion: (ApiStatus<T>) -> Unit) {
        NetworkShared.load("$BASE_URL/api$url", method, params, type, jsonEncoding, timeoutSec, completion)
    }

    fun loadStatus(completion: (ApiStatus<CodeGeneratorModel.ServerStatus>) -> Unit) =
        load("/generator/status", HttpMethod.GET, emptyMap(), CodeGeneratorModel.ServerStatus::class.java, completion = completion)

    fun loadData(id: String, completion: (ApiStatus<CodeGeneratorModel.DataResponse>) -> Unit) {
        load("/load/$id", HttpMethod.GET, emptyMap(), CodeGeneratorModel.DataResponse::class.java, timeoutSec = 10) { res ->
            res.data?.let { ShareRouteCacheStorage.save(id, it) }
            completion(res)
        }
    }

    fun loadDataCache(id: String, completion: (ApiStatus<CodeGeneratorModel.DataResponse>) -> Unit) {
        val cache = ShareRouteCacheStorage.get(id)
        if (cache != null) completion(ApiStatus.SuccessWith(cache)) else loadData(id, completion)
    }

    fun generateCode(settings: RouteSettings, completion: (ApiStatus<CodeGeneratorModel.GenerateResponse>) -> Unit) {
        val params = mapOf(
            "codeVariant" to (if (settings.isQR) "qr" else "appclip"),
            "from" to settings.from.toString().uppercase(),
            "to" to settings.to.toString().uppercase(),
            "helloText" to (settings.text ?: ""),
            "asphalt" to settings.routeParams.asphalt.toString(),
            "serviceRoute" to settings.routeParams.serviceRoute.toString(),
            "allowParameterChange" to settings.allowParameterChange.toString()
        )
        load("/generate", HttpMethod.POST, params, CodeGeneratorModel.GenerateResponse::class.java, jsonEncoding = true, completion = completion)
    }

    fun createParams(id: String, colorVariant: ShareVariants.ColorVariant?, logoVariant: ShareVariants.LogoVariant?, badgeVariant: ShareVariants.BadgeVariant?): MutableMap<String, String> {
        val preset = colorVariant?.preset
        val params = mutableMapOf("id" to id)
        preset?.let {
            params["background"] = it.background; params["primary"] = it.primary
            params["secondary"] = it.secondary; params["badgeTextColor"] = it.badgeTextColor
        }
        params["logo"] = if (logoVariant == ShareVariants.LogoVariant.PHONE) "phone" else "camera"
        params["useBadge"] = if (badgeVariant == ShareVariants.BadgeVariant.CIRCLE) "false" else "true"
        return params
    }

    fun createParamsQR(id: String, colorVariant: ShareVariants.ColorVariant?, logoVariant: ShareVariants.QRLogoVariant?): MutableMap<String, String> {
        val params = mutableMapOf("id" to id)
        colorVariant?.preset?.let { params["background"] = it.background; params["primary"] = it.primary }
        logoVariant?.let { params["logo"] = (it == ShareVariants.QRLogoVariant.USE).toString() }
        return params
    }

    fun tutorialUrl(id: String, isQR: Boolean, colorVariant: ShareVariants.ColorVariant?, logoVariant: ShareVariants.LogoVariant?,
                    badgeVariant: ShareVariants.BadgeVariant?, qrLogoVariant: ShareVariants.QRLogoVariant?): String {
        val params = if (isQR) createParamsQR(id, colorVariant, qrLogoVariant) else createParams(id, colorVariant, logoVariant, badgeVariant)
        return "$BASE_URL/share-code-tutorial?" + params.entries.joinToString("&") { "${it.key}=${it.value}" }
    }

    fun loadAppclip(context: Context, id: String, colorVariant: ShareVariants.ColorVariant?, logoVariant: ShareVariants.LogoVariant?,
                    badgeVariant: ShareVariants.BadgeVariant?, svg: Boolean, width: Int = 2048, completion: (ApiStatus<File>) -> Unit) {
        val params = createParams(id, colorVariant, logoVariant, badgeVariant)
        params["type"] = if (svg) "svg" else "png"
        params["width"] = width.toString()
        NetworkShared.download("$BASE_URL/api/appclip-code", params, File(context.cacheDir, "share/AppClip_$width.${if (svg) "svg" else "png"}"), completion)
    }

    fun loadQR(context: Context, id: String, colorVariant: ShareVariants.ColorVariant?, logoVariant: ShareVariants.QRLogoVariant?,
               svg: Boolean, width: Int = 2048, completion: (ApiStatus<File>) -> Unit) {
        val params = createParamsQR(id, colorVariant, logoVariant)
        params["type"] = if (svg) "svg" else "png"
        params["width"] = width.toString()
        NetworkShared.download("$BASE_URL/api/qr-code", params, File(context.cacheDir, "share/QR_$width.${if (svg) "svg" else "png"}"), completion)
    }

    fun createPermalink(from: UUID, to: UUID, params: RouteParameters): String =
        "$BASE_URL/share/route?from=${from.toString().uppercase()}&to=${to.toString().uppercase()}&asphalt=${params.asphalt}&serviceRoute=${params.serviceRoute}"

    fun createPermalink(annotation: UUID): String = "$BASE_URL/share/annotation?annotation=${annotation.toString().uppercase()}"
}
