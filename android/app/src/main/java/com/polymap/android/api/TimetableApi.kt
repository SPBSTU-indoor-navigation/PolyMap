package com.polymap.android.api

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

// ---------------------------------------------------------------- models (TimetableModel.swift port)

class SettingsModel(val ID: Int, val title: String)

interface SettingsModelConvertible {
    fun convert(): List<SettingsModel>
}

class Timetable(
    val days: List<Day> = emptyList(),
    val week: Week = Week("", "", false),
    val group: Group? = null,
    val teacher: Teacher? = null
) {
    class Day(val date: String = "", val weekday: Int = 0, val lessons: List<Lesson> = emptyList()) {
        class Lesson(
            val additional_info: String? = null,
            val lms_url: String? = null,
            val subject: String = "",
            val subject_short: String? = null,
            val webinar_url: String? = null,
            val time_end: String = "",
            val time_start: String = "",
            val type: Int = 0,
            val parity: Int = 0,
            val typeObj: TypeObj = TypeObj(),
            val groups: List<Group>? = null,
            val teachers: List<Teacher>? = null,
            val auditories: List<Auditorie> = emptyList()
        ) {
            class TypeObj(val id: Int = 0, val abbr: String = "", val name: String = "")
        }
    }

    class Auditorie(val id: Int = 0, val name: String = "", val building: Building = Building()) {
        class Building(val id: Int = 0, val abbr: String = "", val address: String = "", val name: String = "")
    }

    class Group(val id: Int = 0, val kind: Int = 0, val level: Int = 0, val name: String = "", val spec: String = "", val type: String = "", val year: Int = 0, val faculty: Faculty? = null)

    class Week(val date_end: String, val date_start: String, val is_odd: Boolean)
}

class Faculty(val id: Int = 0, val name: String = "", val abbr: String = "")

class Group(val id: Int = 0, val kind: Int = 0, val level: Int = 0, val name: String = "", val spec: String = "", val type: String = "", val year: Int = 0)

class Teacher(
    val id: Int = 0, val oid: Int = 0, val full_name: String = "", val first_name: String = "",
    val middle_name: String = "", val last_name: String = "", val grade: String = "", val chair: String = ""
)

class FacultiesList(val faculties: List<Faculty> = emptyList()) : SettingsModelConvertible {
    override fun convert() = faculties.map { SettingsModel(it.id, it.name) }
}

class GroupsList(val groups: List<Group> = emptyList(), val faculty: Faculty = Faculty()) : SettingsModelConvertible {
    override fun convert() = groups.map { SettingsModel(it.id, it.name) }
}

class TeachersList(val teachers: List<Teacher> = emptyList()) : SettingsModelConvertible {
    override fun convert() = teachers.map { SettingsModel(it.id, it.full_name) }
}

enum class TimetableFilter { GROUPS, TEACHERS }

// ---------------------------------------------------------------- provider (TimetableProvider.swift port)

object TimetableProvider {
    const val BASE_URL = "https://ruz.spbstu.ru/api/v1/ruz"

    var timetable: Timetable? = null
    var faculties: FacultiesList? = null
    var teachers: TeachersList? = null
    var groups: GroupsList? = null

    private val timetableCache = HashMap<String, Timetable>()

    private fun <T> load(url: String, params: Map<String, String>, type: Class<T>, completion: (ApiStatus<T>) -> Unit) {
        NetworkShared.load(BASE_URL + url, HttpMethod.GET, params, type, completion = completion)
    }

    fun loadFaculties(completion: (ApiStatus<FacultiesList>) -> Unit) {
        load("/faculties", emptyMap(), FacultiesList::class.java) { r -> faculties = r.data; completion(r) }
    }

    fun loadGroups(faculty: Faculty, completion: (ApiStatus<GroupsList>) -> Unit) {
        load("/faculties/${faculty.id}/groups", emptyMap(), GroupsList::class.java) { r -> groups = r.data; completion(r) }
    }

    fun loadTeachers(completion: (ApiStatus<TeachersList>) -> Unit) {
        load("/teachers", emptyMap(), TeachersList::class.java) { r -> teachers = r.data; completion(r) }
    }

    fun loadTimetable(id: Int, filter: TimetableFilter, startDate: Date = Date(), fromCache: Boolean = false, completion: (ApiStatus<Timetable>) -> Unit) {
        val startWeek = apiFormatDate(startOfWeek(startDate))
        val keyCache = "$id-$filter-$startWeek"
        if (fromCache) {
            timetableCache[keyCache]?.let { timetable = it; completion(ApiStatus.SuccessWith(it)); return }
        }
        val strURL = if (filter == TimetableFilter.GROUPS) "/scheduler/$id" else "/teachers/$id/scheduler/"
        load(strURL, mapOf("date" to startWeek), Timetable::class.java) { r ->
            timetable = r.data
            if (fromCache) r.data?.let { timetableCache[keyCache] = it }
            completion(r)
        }
    }

    fun startOfWeek(date: Date): Date {
        val cal = Calendar.getInstance(Locale("ru", "RU"))
        cal.firstDayOfWeek = Calendar.MONDAY
        cal.minimalDaysInFirstWeek = 4
        cal.time = date
        cal.set(Calendar.HOUR_OF_DAY, 0); cal.set(Calendar.MINUTE, 0); cal.set(Calendar.SECOND, 0); cal.set(Calendar.MILLISECOND, 0)
        val dow = cal.get(Calendar.DAY_OF_WEEK)
        val diff = (dow - Calendar.MONDAY + 7) % 7
        cal.add(Calendar.DAY_OF_MONTH, -diff)
        return cal.time
    }

    fun apiFormatDate(date: Date): String = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(date)

    fun iCalUrl(facultyID: Int, groupID: Int, date: Date): String =
        "https://ruz.spbstu.ru/faculty/$facultyID/groups/$groupID/ical?date=${apiFormatDate(startOfWeek(date))}"
}
