package com.polymap.android.api

import android.os.Handler
import android.os.Looper
import com.google.gson.Gson
import okhttp3.Call
import okhttp3.Callback
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import java.io.File
import java.io.IOException
import java.net.UnknownHostException
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

/** ApiStatus<T> port */
sealed class ApiStatus<out T> {
    data class SuccessWith<T>(val value: T) : ApiStatus<T>()
    object ErrorNoInternet : ApiStatus<Nothing>()
    object Error : ApiStatus<Nothing>()

    val data: T? get() = (this as? SuccessWith<T>)?.value
    val isErrorNoInternet get() = this is ErrorNoInternet
    val isGenericError get() = this is Error
}

enum class HttpMethod { GET, POST }

object NetworkShared {
    const val BASE_URL = "https://polymap.ru"

    val gson: Gson = Gson()
    private val mainHandler = Handler(Looper.getMainLooper())

    val client: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .addInterceptor { chain ->
            chain.proceed(chain.request().newBuilder().header("User-Agent", "PolyMap-Android/1.1.0").build())
        }
        .build()

    private fun buildRequest(url: String, method: HttpMethod, params: Map<String, String>, jsonEncoding: Boolean, timeoutSec: Long): Request? {
        val builder = Request.Builder()
        when (method) {
            HttpMethod.GET -> {
                val httpUrl = url.toHttpUrlOrNull()?.newBuilder() ?: return null
                params.forEach { (k, v) -> httpUrl.addQueryParameter(k, v) }
                builder.url(httpUrl.build())
            }
            HttpMethod.POST -> {
                builder.url(url)
                if (jsonEncoding) {
                    builder.post(gson.toJson(params).toRequestBody("application/json; charset=utf-8".toMediaType()))
                } else {
                    val fb = okhttp3.FormBody.Builder()
                    params.forEach { (k, v) -> fb.add(k, v) }
                    builder.post(fb.build())
                }
            }
        }
        return builder.build()
    }

    /** Callback style (completion on the main thread), like the Alamofire-based iOS helper. */
    fun <T> load(
        url: String, method: HttpMethod, params: Map<String, String>, type: Class<T>,
        jsonEncoding: Boolean = false, timeoutSec: Long = 30, completion: (ApiStatus<T>) -> Unit
    ) {
        val request = buildRequest(url, method, params, jsonEncoding, timeoutSec) ?: run { completion(ApiStatus.Error); return }
        val c = if (timeoutSec != 30L) client.newBuilder().callTimeout(timeoutSec, TimeUnit.SECONDS).build() else client
        c.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                val status = if (e is UnknownHostException || e is java.net.ConnectException || e is java.net.SocketTimeoutException) ApiStatus.ErrorNoInternet else ApiStatus.Error
                mainHandler.post { completion(status) }
            }

            override fun onResponse(call: Call, response: Response) {
                val status: ApiStatus<T> = response.use { r ->
                    if (r.code in 200..300) {
                        val body = r.body?.string()
                        val parsed = runCatching { gson.fromJson(body, type) }.getOrNull()
                        if (parsed != null) ApiStatus.SuccessWith(parsed) else ApiStatus.Error
                    } else ApiStatus.Error
                }
                mainHandler.post { completion(status) }
            }
        })
    }

    suspend fun <T> loadSuspend(
        url: String, method: HttpMethod, params: Map<String, String>, type: Class<T>,
        jsonEncoding: Boolean = false, timeoutSec: Long = 30
    ): ApiStatus<T> = suspendCoroutine { cont ->
        load(url, method, params, type, jsonEncoding, timeoutSec) { cont.resume(it) }
    }

    /** Downloads raw bytes to a file in the cache dir. */
    fun download(url: String, params: Map<String, String>, target: File, completion: (ApiStatus<File>) -> Unit) {
        val request = buildRequest(url, HttpMethod.GET, params, false, 30) ?: run { completion(ApiStatus.Error); return }
        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                val status = if (e is UnknownHostException) ApiStatus.ErrorNoInternet else ApiStatus.Error
                mainHandler.post { completion(status) }
            }

            override fun onResponse(call: Call, response: Response) {
                val status: ApiStatus<File> = response.use { r ->
                    val bytes = r.body?.bytes()
                    if (r.isSuccessful && bytes != null) {
                        runCatching { target.parentFile?.mkdirs(); target.writeBytes(bytes); ApiStatus.SuccessWith(target) }.getOrDefault(ApiStatus.Error)
                    } else ApiStatus.Error
                }
                mainHandler.post { completion(status) }
            }
        })
    }
}
