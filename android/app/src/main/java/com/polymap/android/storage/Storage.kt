package com.polymap.android.storage

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.polymap.android.imdf.IMDF
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.api.CodeGeneratorModel
import java.util.UUID

/** UserDefaults analogue backed by SharedPreferences. */
object Storage {
    private var prefs: SharedPreferences? = null

    fun init(context: Context) {
        prefs = context.applicationContext.getSharedPreferences("polymap", Context.MODE_PRIVATE)
    }

    fun string(key: String): String? = prefs?.getString(key, null)
    fun bool(key: String): Boolean? = prefs?.let { if (it.contains(key)) it.getBoolean(key, false) else null }
    fun int(key: String): Int? = prefs?.let { if (it.contains(key)) it.getInt(key, 0) else null }
    fun contains(key: String) = prefs?.contains(key) ?: false
    fun stringList(key: String): List<String>? = string(key)?.let { runCatching { Gson().fromJson(it, Array<String>::class.java).toList() }.getOrNull() }

    fun set(key: String, value: String?) { prefs?.edit()?.putString(key, value)?.apply() }
    fun set(key: String, value: Boolean) { prefs?.edit()?.putBoolean(key, value)?.apply() }
    fun set(key: String, value: Int) { prefs?.edit()?.putInt(key, value)?.apply() }
    fun setList(key: String, value: List<String>) { prefs?.edit()?.putString(key, Gson().toJson(value))?.apply() }
    fun remove(key: String) { prefs?.edit()?.remove(key)?.apply() }
}

/** Simple multicast event (Event<T> port). */
class Event<T> {
    private val handlers = mutableListOf<(T) -> Unit>()
    fun addHandler(handler: (T) -> Unit) { handlers += handler }
    fun removeHandler(handler: (T) -> Unit) { handlers -= handler }
    fun invoke(data: T) { handlers.toList().forEach { it(data) } }
}

class FavoritesStorage private constructor() {
    val onAdd = Event<BaseAnnotation>()
    val onRemove = Event<BaseAnnotation>()

    var favorites: List<BaseAnnotation> = emptyList()
        private set

    fun setup(annotations: Map<UUID, BaseAnnotation>) {
        favorites = (Storage.stringList("favoritesID") ?: emptyList())
            .mapNotNull { runCatching { UUID.fromString(it) }.getOrNull() }
            .mapNotNull { annotations[it] }
    }

    fun contains(annotation: BaseAnnotation) = favorites.any { it === annotation }

    fun addFavorites(annotation: BaseAnnotation) {
        if (!contains(annotation)) {
            favorites = favorites + annotation
            onAdd.invoke(annotation)
            save()
        }
    }

    fun removeFavorites(annotation: BaseAnnotation) {
        val new = favorites.filter { it !== annotation }
        if (new.size != favorites.size) {
            favorites = new
            onRemove.invoke(annotation)
            save()
        }
    }

    private fun save() = Storage.setList("favoritesID", favorites.map { it.imdfID.toString() })

    companion object { val shared = FavoritesStorage() }
}

class SearchHistoryStorage private constructor() {
    val onHistoryChange = Event<List<BaseAnnotation>>()

    var history: List<BaseAnnotation> = emptyList()
        private set

    fun setup(annotations: Map<UUID, BaseAnnotation>) {
        history = (Storage.stringList("histirysID") ?: emptyList())
            .mapNotNull { runCatching { UUID.fromString(it) }.getOrNull() }
            .mapNotNull { annotations[it] }
    }

    fun open(annotation: BaseAnnotation) {
        var h = history.filter { it !== annotation }.toMutableList()
        h.add(0, annotation)
        val lastIndex = minOf(4, h.size - 1)
        h = h.subList(0, lastIndex + 1).toMutableList()
        history = h
        onHistoryChange.invoke(history)
        Storage.setList("histirysID", history.map { it.imdfID.toString() })
    }

    companion object { val shared = SearchHistoryStorage() }
}

object ShareRouteCacheStorage {
    private const val KEY = "shareRouteCacheStorage"
    private const val KEY_FOR_KEYS = "shareRouteCacheStorageKeys"

    fun get(id: String): CodeGeneratorModel.DataResponse? {
        val key = key(id) ?: return null
        val json = Storage.string(key) ?: return null
        return runCatching { Gson().fromJson(json, CodeGeneratorModel.DataResponse::class.java) }.getOrNull()
    }

    fun save(id: String, route: CodeGeneratorModel.DataResponse) {
        val allKeys = (Storage.stringList(KEY_FOR_KEYS) ?: emptyList()).toMutableList()
        if (allKeys.size > 10) {
            Storage.remove(allKeys[0])
            allKeys.removeAt(0)
        }
        val key = key(id) ?: return
        Storage.set(key, Gson().toJson(route))
        if (!allKeys.contains(key)) allKeys += key
        Storage.setList(KEY_FOR_KEYS, allKeys)
    }

    private fun key(id: String): String? = if (id.isNotEmpty() && id.length < 10) "${KEY}_$id" else null
}

/** RouteParameters port. */
class RouteParameters(var asphalt: Boolean, var serviceRoute: Boolean) {
    val denyTags: List<IMDF.NavPathTag>
        get() {
            val result = mutableListOf<IMDF.NavPathTag>()
            if (asphalt) result += IMDF.NavPathTag.DIRT
            if (!serviceRoute) result += IMDF.NavPathTag.SERVICE
            return result
        }

    fun saveToStorage() {
        Storage.set(STORAGE_ASPHALT, asphalt)
        Storage.set(STORAGE_SERVICE_ROUTE, serviceRoute)
    }

    fun copy() = RouteParameters(asphalt, serviceRoute)

    override fun equals(other: Any?) = other is RouteParameters && other.asphalt == asphalt && other.serviceRoute == serviceRoute
    override fun hashCode() = (if (asphalt) 1 else 0) * 2 + (if (serviceRoute) 1 else 0)

    companion object {
        const val STORAGE_ASPHALT = "storageAsphalt"
        const val STORAGE_SERVICE_ROUTE = "storageServiceRoute"

        val fromStorage: RouteParameters
            get() = RouteParameters(Storage.bool(STORAGE_ASPHALT) ?: true, Storage.bool(STORAGE_SERVICE_ROUTE) ?: false)
    }
}
