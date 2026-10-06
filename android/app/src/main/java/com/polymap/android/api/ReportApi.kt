package com.polymap.android.api

import android.content.Context
import android.os.Build
import com.polymap.android.BuildConfig
import com.polymap.android.map.annotations.BaseAnnotation
import com.polymap.android.storage.RouteParameters
import java.util.Locale

/** SectionCollection.Report.ReportBase hierarchy port */
sealed class ReportTarget {
    class Annotation(val annotation: BaseAnnotation) : ReportTarget()
    class Route(val from: BaseAnnotation, val to: BaseAnnotation, val params: RouteParameters) : ReportTarget()
}

object ReportApiProvider {
    private const val BASE_URL = NetworkShared.BASE_URL

    class Result(val message: String = "")

    fun sendReport(context: Context, message: String, report: ReportTarget, completion: (ApiStatus<Result>) -> Unit) {
        when (report) {
            is ReportTarget.Route -> {
                val params = mutableMapOf(
                    "message" to message,
                    "from" to report.from.imdfID.toString().uppercase(),
                    "to" to report.to.imdfID.toString().uppercase(),
                    "asphalt" to report.params.asphalt.toString(),
                    "serviceRoute" to report.params.serviceRoute.toString()
                )
                addDeviceInfo(context, params)
                NetworkShared.load("$BASE_URL/api/report/route", HttpMethod.POST, params, Result::class.java, jsonEncoding = true, timeoutSec = 10, completion = completion)
            }
            is ReportTarget.Annotation -> {
                val params = mutableMapOf(
                    "message" to message,
                    "annotation" to report.annotation.imdfID.toString().uppercase()
                )
                addDeviceInfo(context, params)
                NetworkShared.load("$BASE_URL/api/report/annotation", HttpMethod.POST, params, Result::class.java, jsonEncoding = true, timeoutSec = 10, completion = completion)
            }
        }
    }

    private fun addDeviceInfo(context: Context, params: MutableMap<String, String>) {
        params["modelCode"] = "${Build.MANUFACTURER} ${Build.MODEL}"
        params["os"] = "Android ${Build.VERSION.RELEASE}"
        val orientation = context.resources.configuration.orientation
        params["orientation"] = if (orientation == android.content.res.Configuration.ORIENTATION_LANDSCAPE) "Landscape" else "Portrait"
        params["appVersion"] = BuildConfig.VERSION_NAME
        params["locale"] = Locale.getDefault().language
        val dm = context.resources.displayMetrics
        params["screen"] = "${(dm.widthPixels / dm.density).toInt()}x${(dm.heightPixels / dm.density).toInt()}"
    }
}
