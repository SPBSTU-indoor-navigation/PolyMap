package com.polymap.android.timetable

import android.content.Context
import com.polymap.android.api.SettingsModel
import com.polymap.android.api.Timetable
import com.polymap.android.api.TimetableFilter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** TimetableWeek / LessonModel / BreakModel port */
sealed class TimetableCellModel

class BreakModel(val timeStart: Date, val timeEnd: Date) : TimetableCellModel()

class LessonModel(
    val subjectName: String,
    val timeStart: Date,
    val timeEnd: Date,
    val type: LessonType,
    val typeName: String,
    val place: String,
    val teacher: String
) : TimetableCellModel() {
    enum class LessonType { LECTURE, PRACTICE, OTHER;
        companion object {
            fun parse(name: String) = when (name) { "Лекции" -> LECTURE; "Практика" -> PRACTICE; else -> OTHER }
        }
    }

    companion object {
        /** Inserts BreakModel between lessons with >= 1h gap. */
        fun createCorrectTimeTable(current: List<TimetableCellModel>): List<TimetableCellModel> {
            if (current.isEmpty()) return current
            val result = ArrayList<TimetableCellModel>()
            result += current[0]
            for (i in 1 until current.size) {
                val cur = current[i]; val last = current[i - 1]
                if (cur is LessonModel && last is LessonModel) {
                    if (cur.timeStart.time - last.timeEnd.time >= 60 * 60 * 1000L) result += BreakModel(last.timeEnd, cur.timeStart)
                }
                result += cur
            }
            return result
        }
    }
}

class TimetableDay(val date: Date?, val timetableCell: List<TimetableCellModel>)

class TimetableWeek(val days: List<TimetableDay>, val week: Timetable.Week) {
    companion object {
        val dateParser = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        val dateTimeParser = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale("ru", "RU"))

        fun convert(t: Timetable): TimetableWeek {
            val days = t.days.map { day ->
                val lessons = day.lessons.mapNotNull { lesson ->
                    val aud = lesson.auditories.firstOrNull()
                    val audName = if (aud != null) aud.building.name + ", " + aud.name else ""
                    val start = runCatching { dateTimeParser.parse(day.date + " " + lesson.time_start) }.getOrNull() ?: return@mapNotNull null
                    val end = runCatching { dateTimeParser.parse(day.date + " " + lesson.time_end) }.getOrNull() ?: return@mapNotNull null
                    LessonModel(
                        subjectName = lesson.subject,
                        timeStart = start, timeEnd = end,
                        type = LessonModel.LessonType.parse(lesson.typeObj.name),
                        typeName = lesson.typeObj.name,
                        place = audName,
                        teacher = lesson.teachers?.firstOrNull()?.full_name ?: ""
                    )
                }
                TimetableDay(runCatching { dateParser.parse(day.date) }.getOrNull(), lessons)
            }
            return TimetableWeek(days, t.week)
        }
    }
}

/** GroupsAndTeacherStorage port (UserDefaults.standard keys). */
object GroupsAndTeacherStorage {
    private const val PREFS = "timetable_settings"
    private const val FILTER_VAL = "filterVal"
    private const val INSTITUTE_ID = "instituteID"
    private const val INSTITUTE_NAME = "instituteName"
    private const val GROUP_ID = "groupID"
    private const val GROUP_NAME = "groupName"
    private const val TEACHER_ID = "teacherID"
    private const val TEACHER_NAME = "teacherName"

    private lateinit var prefs: android.content.SharedPreferences
    private var initialized = false

    var currentInstitute: SettingsModel? = null
    var institute: SettingsModel? = null
        set(value) { field = value; groupNumber = null }
    var currentGroupNumber: SettingsModel? = null
    var groupNumber: SettingsModel? = null
    var currentTeachersName: SettingsModel? = null
    var teachersName: SettingsModel? = null
    var currentFilter: TimetableFilter = TimetableFilter.GROUPS
    var filter: TimetableFilter = TimetableFilter.GROUPS

    fun init(context: Context) {
        if (initialized) return
        initialized = true
        prefs = context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        readAll()
    }

    fun getInstituteStringWithStatus(context: Context) = institute?.title ?: context.getString(com.polymap.android.R.string.settings_statusofinstitute)
    fun getGroupStringWithStatus(context: Context) = groupNumber?.title ?: context.getString(com.polymap.android.R.string.settings_statusofgroup)
    fun getTeacherStringWithStatus(context: Context) = teachersName?.title ?: context.getString(com.polymap.android.R.string.settings_statusofinstitute)

    fun isReady(): Boolean = (filter == TimetableFilter.GROUPS && groupNumber != null && institute != null) || (filter == TimetableFilter.TEACHERS && teachersName != null)

    fun doneAction() {
        prefs.edit()
            .putInt(FILTER_VAL, if (filter == TimetableFilter.GROUPS) 0 else 1)
            .putInt(INSTITUTE_ID, institute?.ID ?: 0).putString(INSTITUTE_NAME, institute?.title)
            .putInt(GROUP_ID, groupNumber?.ID ?: 0).putString(GROUP_NAME, groupNumber?.title)
            .putInt(TEACHER_ID, teachersName?.ID ?: 0).putString(TEACHER_NAME, teachersName?.title)
            .apply()
        currentFilter = filter
        currentInstitute = institute
        currentGroupNumber = groupNumber
        currentTeachersName = teachersName
    }

    private fun readAll() {
        prefs.getString(INSTITUTE_NAME, null)?.let { institute = SettingsModel(prefs.getInt(INSTITUTE_ID, 0), it); currentInstitute = institute }
        prefs.getString(GROUP_NAME, null)?.let { groupNumber = SettingsModel(prefs.getInt(GROUP_ID, 0), it); currentGroupNumber = groupNumber }
        prefs.getString(TEACHER_NAME, null)?.let { teachersName = SettingsModel(prefs.getInt(TEACHER_ID, 0), it); currentTeachersName = teachersName }
        filter = if (prefs.getInt(FILTER_VAL, 0) == 0) TimetableFilter.GROUPS else TimetableFilter.TEACHERS
        currentFilter = filter
    }

    fun reload() {
        institute = currentInstitute
        groupNumber = currentGroupNumber
        teachersName = currentTeachersName
    }
}
