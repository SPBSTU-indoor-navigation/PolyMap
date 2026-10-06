package com.polymap.android.timetable

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.polymap.android.R
import com.polymap.android.api.ApiStatus
import com.polymap.android.api.Faculty
import com.polymap.android.api.SettingsModel
import com.polymap.android.api.Timetable
import com.polymap.android.api.TimetableFilter
import com.polymap.android.api.TimetableProvider
import com.polymap.android.ui.GroupedRow
import com.polymap.android.ui.GroupedSection
import com.polymap.android.ui.IosColors
import com.polymap.android.ui.PolyMapTheme
import com.polymap.android.ui.screens.NavTextButton
import com.polymap.android.ui.screens.SheetNavBar
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/** TimetablePageVC + SettingTimetableVC host. */
class TimetableActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        GroupsAndTeacherStorage.init(this)
        setContent {
            PolyMapTheme {
                var showSettings by remember { mutableStateOf(!GroupsAndTeacherStorage.isReady()) }
                var reloadKey by remember { mutableIntStateOf(0) }
                Box(Modifier.fillMaxSize().background(IosColors.groupedBackground)) {
                    if (GroupsAndTeacherStorage.isReady()) {
                        key(reloadKey) { TimetablePagerScreen(onClose = { finish() }, onSettings = { showSettings = true }) }
                    }
                    if (showSettings) {
                        SettingTimetableScreen(onDone = {
                            showSettings = false
                            reloadKey++
                            if (!GroupsAndTeacherStorage.isReady()) finish()
                        }, onCancel = {
                            if (GroupsAndTeacherStorage.isReady()) showSettings = false else finish()
                        })
                    }
                }
            }
        }
    }
}

@Composable
private fun key(k: Int, content: @Composable () -> Unit) = androidx.compose.runtime.key(k) { content() }

private const val CENTER_PAGE = 5000

private fun addWeeks(date: Date, count: Int): Date = Calendar.getInstance().apply { time = date; add(Calendar.WEEK_OF_YEAR, count) }.time
private fun sameDay(a: Date, b: Date): Boolean {
    val ca = Calendar.getInstance().apply { time = a }; val cb = Calendar.getInstance().apply { time = b }
    return ca.get(Calendar.YEAR) == cb.get(Calendar.YEAR) && ca.get(Calendar.DAY_OF_YEAR) == cb.get(Calendar.DAY_OF_YEAR)
}

/** TimetablePageVC port: week pager with navbar and toolbar. */
@Composable
fun TimetablePagerScreen(onClose: () -> Unit, onSettings: () -> Unit) {
    val context = LocalContext.current
    val pagerState = rememberPagerState(initialPage = CENTER_PAGE) { CENTER_PAGE * 2 }
    val scope = rememberCoroutineScope()
    val today = remember { Date() }
    var lastLoadedWeek by remember { mutableStateOf<Timetable.Week?>(null) }
    val weekLoaded = remember { mutableStateOf<Map<Int, Timetable.Week?>>(emptyMap()) }
    val scrollOffsets = remember { mutableStateOf<Map<Int, Int>>(emptyMap()) }
    var currentHasToday by remember { mutableStateOf(true) }

    val currentPage = pagerState.currentPage
    val currentDate = addWeeks(today, currentPage - CENTER_PAGE)

    // navbar date + odd/even (updateNavbar port)
    val startOfWeek = TimetableProvider.startOfWeek(currentDate)
    val endOfWeek = Calendar.getInstance().apply { time = startOfWeek; add(Calendar.DAY_OF_MONTH, 6) }.time
    val fmt = remember { SimpleDateFormat("dd MMM", Locale.getDefault()) }
    val weekInfo = weekLoaded.value[currentPage]
    val isOdd: Boolean? = weekInfo?.is_odd ?: lastLoadedWeek?.let { llw ->
        val lastStart = runCatching { TimetableWeek.dateParser.parse(llw.date_start) }.getOrNull()
        if (lastStart == null) null else {
            val delta = kotlin.math.abs(((startOfWeek.time - TimetableProvider.startOfWeek(lastStart).time) / (7L * 24 * 3600 * 1000)).toInt())
            if (delta % 2 == 0) llw.is_odd else !llw.is_odd
        }
    }
    val blur = ((scrollOffsets.value[currentPage] ?: 0) / 20f).coerceIn(0f, 1f)

    Column(Modifier.fillMaxSize()) {
        // navbar (100dp)
        Column(Modifier.fillMaxWidth().background(IosColors.groupedBackground.copy(alpha = 0.9f)).statusBarsPadding()) {
            Box(Modifier.fillMaxWidth().height(50.dp)) {
                Image(painterResource(R.drawable.ic_sf_xmark), null, Modifier.align(Alignment.CenterStart).padding(start = 18.dp).size(30.dp).clip(CircleShape).background(IosColors.gray.copy(alpha = 0.2f)).padding(7.dp).clickable { onClose() }, colorFilter = ColorFilter.tint(IosColors.secondaryLabel))
                Text(stringResource(R.string.timetable_title), fontSize = 17.sp, fontWeight = FontWeight.Bold, color = IosColors.label, modifier = Modifier.align(Alignment.Center))
                Text(stringResource(R.string.timetable_editbutton), fontSize = 17.sp, color = IosColors.accent, modifier = Modifier.align(Alignment.CenterEnd).clickable { onSettings() }.padding(horizontal = 20.dp, vertical = 8.dp))
            }
            Box(Modifier.fillMaxWidth().height(50.dp)) {
                Image(painterResource(R.drawable.ic_sf_chevron_backward), null, Modifier.align(Alignment.CenterStart).padding(start = 20.dp).size(28.dp).clickable { scope.launch { pagerState.animateScrollToPage(pagerState.currentPage - 1) } }, colorFilter = ColorFilter.tint(IosColors.accent))
                Column(Modifier.align(Alignment.Center), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("${fmt.format(startOfWeek)} - ${fmt.format(endOfWeek)}", fontSize = 16.sp, color = IosColors.label)
                    Text(if (isOdd == null) "" else stringResource(if (isOdd) R.string.timetable_dataoddweek else R.string.timetable_dateevenweek), fontSize = 12.sp, color = IosColors.label)
                }
                Image(painterResource(R.drawable.ic_sf_chevron_forward), null, Modifier.align(Alignment.CenterEnd).padding(end = 20.dp).size(28.dp).clickable { scope.launch { pagerState.animateScrollToPage(pagerState.currentPage + 1) } }, colorFilter = ColorFilter.tint(IosColors.accent))
            }
            HorizontalDivider(color = IosColors.separator.copy(alpha = blur * 0.4f))
        }

        HorizontalPager(state = pagerState, modifier = Modifier.weight(1f), beyondViewportPageCount = 1) { page ->
            val date = addWeeks(today, page - CENTER_PAGE)
            TimetableWeekPage(
                date = date,
                isCurrentPage = page == pagerState.currentPage,
                onWeekLoaded = { w -> if (w != null) lastLoadedWeek = w; weekLoaded.value = weekLoaded.value + (page to w) },
                onScroll = { off -> scrollOffsets.value = scrollOffsets.value + (page to off) },
                onHasToday = { has -> if (page == pagerState.currentPage) currentHasToday = has },
                scrollToTodayKey = if (page == pagerState.currentPage) scrollToTodayTick else 0
            )
        }

        // toolbar
        Row(Modifier.fillMaxWidth().background(IosColors.groupedBackground.copy(alpha = 0.95f)).navigationBarsPadding().height(55.dp).padding(horizontal = 20.dp), verticalAlignment = Alignment.CenterVertically) {
            val isTodayWeek = sameDay(TimetableProvider.startOfWeek(currentDate), TimetableProvider.startOfWeek(today))
            val enabled = !(isTodayWeek && !currentHasToday)
            Text(
                stringResource(if (isTodayWeek && !currentHasToday) R.string.timetable_nothavecurrentday else R.string.timetable_totodaytimetable),
                fontSize = 18.sp, color = if (enabled) IosColors.accent else IosColors.secondaryLabel,
                modifier = Modifier.clickable(enabled = enabled) {
                    if (isTodayWeek) scrollToTodayTick++ else scope.launch { pagerState.animateScrollToPage(CENTER_PAGE) }
                }
            )
            Spacer(Modifier.weight(1f))
            Text(stringResource(R.string.timetable_ical), fontSize = 18.sp, color = IosColors.accent, modifier = Modifier.clickable {
                val f = GroupsAndTeacherStorage.institute?.ID ?: return@clickable
                val g = GroupsAndTeacherStorage.groupNumber?.ID ?: return@clickable
                runCatching { context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(TimetableProvider.iCalUrl(f, g, currentDate)))) }
            })
        }
    }
}

private var scrollToTodayTick by mutableIntStateOf(0)

/** TimetableViewController port: one week. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TimetableWeekPage(date: Date, isCurrentPage: Boolean, onWeekLoaded: (Timetable.Week?) -> Unit, onScroll: (Int) -> Unit, onHasToday: (Boolean) -> Unit, scrollToTodayKey: Int) {
    var days by remember { mutableStateOf<List<TimetableDay>?>(null) }
    var loading by remember { mutableStateOf(true) }
    var refreshing by remember { mutableStateOf(false) }
    val listState = rememberLazyListState()
    val scope = rememberCoroutineScope()
    val today = remember { Date() }

    fun applyResponse(r: ApiStatus<Timetable>) {
        val t = r.data
        if (t != null) {
            val week = TimetableWeek.convert(t)
            days = week.days.map { TimetableDay(it.date, LessonModel.createCorrectTimeTable(it.timetableCell)) }
            onWeekLoaded(week.week)
            onHasToday(days!!.any { d -> d.date?.let { sameDay(it, today) } == true })
        } else days = emptyList()
        loading = false; refreshing = false
    }

    fun load(fromCache: Boolean) {
        val id = if (GroupsAndTeacherStorage.currentFilter == TimetableFilter.GROUPS) GroupsAndTeacherStorage.currentGroupNumber?.ID else GroupsAndTeacherStorage.currentTeachersName?.ID
        TimetableProvider.loadTimetable(id ?: -1, GroupsAndTeacherStorage.currentFilter, date, fromCache) { applyResponse(it) }
    }

    LaunchedEffect(Unit) { load(true) }
    LaunchedEffect(listState.firstVisibleItemIndex, listState.firstVisibleItemScrollOffset) {
        onScroll(if (listState.firstVisibleItemIndex > 0) 1000 else listState.firstVisibleItemScrollOffset)
    }
    LaunchedEffect(scrollToTodayKey) {
        if (scrollToTodayKey == 0) return@LaunchedEffect
        val d = days ?: return@LaunchedEffect
        var index = 0
        for (day in d) {
            if (day.date?.let { sameDay(it, today) } == true) { listState.animateScrollToItem(index); return@LaunchedEffect }
            index += 1 + day.timetableCell.size + 1
        }
    }

    val d = days
    when {
        loading -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator(color = IosColors.accent) }
        d.isNullOrEmpty() -> TimetableEmptyView { loading = true; load(false) }
        else -> PullToRefreshBox(isRefreshing = refreshing, onRefresh = { refreshing = true; load(false) }) {
            LazyColumn(state = listState, modifier = Modifier.fillMaxSize(), contentPadding = PaddingValues(top = 8.dp, bottom = 16.dp)) {
                for (day in d) {
                    item { DateHeader(day.date, today) }
                    day.timetableCell.forEachIndexed { i, cell ->
                        item {
                            Column(Modifier.padding(horizontal = 16.dp).background(IosColors.secondaryGroupedBackground)) {
                                when (cell) {
                                    is LessonModel -> LessonCell(cell)
                                    is BreakModel -> BreakCell(cell)
                                }
                                if (i < day.timetableCell.size - 1) HorizontalDivider(color = IosColors.separator, thickness = 0.5.dp, modifier = Modifier.padding(start = 16.dp))
                            }
                        }
                    }
                    item { Box(Modifier.padding(horizontal = 16.dp).fillMaxWidth().height(10.dp).clip(RoundedCornerShape(bottomStart = 10.dp, bottomEnd = 10.dp)).background(IosColors.secondaryGroupedBackground)); Spacer(Modifier.height(20.dp)) }
                }
            }
        }
    }
}

/** DateTableViewCell port: centered pill with the day, accent dot if today. */
@Composable
private fun DateHeader(date: Date?, today: Date) {
    val fmt = remember { SimpleDateFormat("EE dd MMM", Locale.getDefault()) }
    Box(Modifier.fillMaxWidth().padding(horizontal = 16.dp).padding(top = 10.dp), contentAlignment = Alignment.Center) {
        Box(Modifier.widthIn(min = 150.dp).clip(RoundedCornerShape(topStart = 15.dp, topEnd = 15.dp)).background(IosColors.secondaryGroupedBackground).padding(horizontal = 25.dp, vertical = 4.dp), contentAlignment = Alignment.Center) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (date != null && sameDay(date, today)) Box(Modifier.size(10.dp).clip(CircleShape).background(IosColors.accent).padding(end = 10.dp)); Spacer(Modifier.width(10.dp))
                if (date != null) Text(fmt.format(date), fontSize = 17.sp, color = IosColors.label)
                else Box(Modifier.width(75.dp).height(2.dp).background(IosColors.separator))
            }
        }
    }
}

/** LessonCellView port */
@Composable
private fun LessonCell(m: LessonModel) {
    val tf = remember { SimpleDateFormat("HH:mm", Locale.getDefault()) }
    var now by remember { mutableStateOf(Date()) }
    LaunchedEffect(Unit) { while (true) { delay(5000); now = Date() } }
    val progress = ((now.time - m.timeStart.time).toFloat() / (m.timeEnd.time - m.timeStart.time)).let { if (it in 0f..1f) it else null }
    Row(Modifier.fillMaxWidth().padding(vertical = 5.dp)) {
        Column(Modifier.width(70.dp).fillMaxHeight(), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.SpaceBetween) {
            Text(tf.format(m.timeStart), fontSize = 17.sp, color = IosColors.label, modifier = Modifier.padding(top = 5.dp))
            Text(tf.format(m.timeEnd), fontSize = 17.sp, color = IosColors.label, modifier = Modifier.padding(bottom = 5.dp))
        }
        Box(Modifier.width(2.dp).fillMaxHeight().padding(vertical = 5.dp)) {
            Box(Modifier.fillMaxSize().clip(RoundedCornerShape(2.dp)).background(if (m.type == LessonModel.LessonType.LECTURE) colorResource(R.color.system_green) else colorResource(R.color.system_pink)))
            if (progress != null) {
                androidx.compose.foundation.layout.BoxWithConstraints(Modifier.fillMaxSize()) {
                    val h = maxHeight
                    Box(Modifier.padding(top = (h - 13.dp) * progress).size(13.dp).align(Alignment.TopCenter).clip(CircleShape).background(IosColors.secondaryGroupedBackground), contentAlignment = Alignment.Center) {
                        Box(Modifier.size(8.dp).clip(CircleShape).background(IosColors.red))
                    }
                }
            }
        }
        Column(Modifier.weight(1f).padding(start = 5.dp, end = 10.dp, top = 5.dp, bottom = 5.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(m.subjectName, fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = IosColors.label)
            Text(m.typeName, fontSize = 17.sp, color = IosColors.label)
            if (m.teacher.isNotEmpty()) Text(m.teacher, fontSize = 17.sp, color = IosColors.label)
            Text(m.place, fontSize = 17.sp, color = IosColors.label)
        }
    }
}

@Composable
private fun colorResource(id: Int) = androidx.compose.ui.res.colorResource(id)

/** TimetableBreakTableViewCell port */
@Composable
private fun BreakCell(m: BreakModel) {
    val tf = remember { SimpleDateFormat("HH:mm", Locale.getDefault()) }
    Column(Modifier.fillMaxWidth().padding(vertical = 10.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Text(stringResource(R.string.timetable_lessonsbreak), fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = IosColors.label)
        Text("${tf.format(m.timeStart)} - ${tf.format(m.timeEnd)}", fontSize = 17.sp, color = IosColors.label, modifier = Modifier.padding(top = 5.dp))
    }
}

/** TimetableEmptyView port */
@Composable
private fun TimetableEmptyView(onRefresh: () -> Unit) {
    Column(Modifier.fillMaxSize().padding(30.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Spacer(Modifier.weight(1f))
        Image(painterResource(R.drawable.ic_sf_bed), null, Modifier.size(100.dp).clickable { onRefresh() }, colorFilter = ColorFilter.tint(IosColors.label))
        Text(stringResource(R.string.timetable_emptyweek), fontSize = 16.sp, textAlign = TextAlign.Center, color = IosColors.label, modifier = Modifier.padding(top = 10.dp))
        Spacer(Modifier.weight(1f))
        Text(stringResource(R.string.timetable_emptyviewrefreshbutton), fontSize = 17.sp, color = IosColors.accent, modifier = Modifier.clickable { onRefresh() }.padding(16.dp))
    }
}

// ------------------------------------------------------------------ settings

/** SettingTimetableVC port */
@Composable
fun SettingTimetableScreen(onDone: () -> Unit, onCancel: () -> Unit) {
    val context = LocalContext.current
    var selectedIndex by remember { mutableIntStateOf(if (GroupsAndTeacherStorage.currentFilter == TimetableFilter.GROUPS) 0 else 1) }
    var choosing by remember { mutableStateOf<ChoosingSpec?>(null) }
    var tick by remember { mutableIntStateOf(0) }
    LaunchedEffect(Unit) { GroupsAndTeacherStorage.reload() }

    BackHandler { if (choosing != null) choosing = null else onCancel() }

    val spec = choosing
    if (spec != null) {
        ChoosingScreen(spec, onBack = { choosing = null; tick++ })
        return
    }
    Column(Modifier.fillMaxSize().background(IosColors.groupedBackground).statusBarsPadding()) {
        SheetNavBar(stringResource(R.string.settings_title),
            leading = { NavTextButton(stringResource(R.string.present_cancel)) { onCancel() } },
            trailing = { NavTextButton(stringResource(R.string.share_result_done), enabled = GroupsAndTeacherStorage.isReady().also { tick }) { GroupsAndTeacherStorage.doneAction(); onDone() } })
        // segmented control
        Row(Modifier.padding(horizontal = 20.dp, vertical = 8.dp).fillMaxWidth().clip(RoundedCornerShape(9.dp)).background(IosColors.gray.copy(alpha = 0.15f)).padding(2.dp)) {
            listOf(stringResource(R.string.settings_titleofgroupsview), stringResource(R.string.settings_titleofteachersview)).forEachIndexed { i, t ->
                Box(Modifier.weight(1f).clip(RoundedCornerShape(7.dp)).background(if (selectedIndex == i) IosColors.secondaryGroupedBackground else Color.Transparent)
                    .clickable { selectedIndex = i; GroupsAndTeacherStorage.filter = if (i == 0) TimetableFilter.GROUPS else TimetableFilter.TEACHERS; tick++ }
                    .padding(vertical = 6.dp), contentAlignment = Alignment.Center) {
                    Text(t, fontSize = 13.sp, fontWeight = if (selectedIndex == i) FontWeight.SemiBold else FontWeight.Normal, color = IosColors.label)
                }
            }
        }
        val rows = mutableListOf<@Composable () -> Unit>()
        @Composable fun row(title: String, value: String, onClick: () -> Unit) {
            GroupedRow(onClick = onClick) {
                Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Column(Modifier.weight(1f)) {
                        Text(title, fontSize = 17.sp, color = IosColors.label)
                        Text(value, fontSize = 15.sp, color = IosColors.secondaryLabel)
                    }
                    Image(painterResource(R.drawable.ic_sf_chevron_forward), null, Modifier.size(20.dp), colorFilter = ColorFilter.tint(IosColors.secondaryLabel))
                }
            }
        }
        if (selectedIndex == 0) {
            rows += { row(stringResource(R.string.settings_titleofinstitutecell), GroupsAndTeacherStorage.getInstituteStringWithStatus(context)) {
                choosing = ChoosingSpec(context.getString(R.string.settings_titleofinstitutecell), GroupsAndTeacherStorage.institute?.ID, load = { done ->
                    TimetableProvider.faculties?.let { done(it.convert()); return@ChoosingSpec }
                    TimetableProvider.loadFaculties { r -> done(r.data?.convert() ?: emptyList()) }
                }, choose = { GroupsAndTeacherStorage.institute = it })
            } }
            if (GroupsAndTeacherStorage.institute != null) rows += { row(stringResource(R.string.settings_titleofgroupcell), GroupsAndTeacherStorage.getGroupStringWithStatus(context)) {
                val inst = GroupsAndTeacherStorage.institute ?: return@row
                choosing = ChoosingSpec(context.getString(R.string.settings_titleofgroupcell), GroupsAndTeacherStorage.groupNumber?.ID, load = { done ->
                    TimetableProvider.groups?.let { if (it.faculty.id == inst.ID) { done(it.convert()); return@ChoosingSpec } }
                    TimetableProvider.loadGroups(Faculty(inst.ID, inst.title, "")) { r -> done(r.data?.convert() ?: emptyList()) }
                }, choose = { GroupsAndTeacherStorage.groupNumber = it })
            } }
        } else {
            rows += { row(stringResource(R.string.settings_titleofteachercell), GroupsAndTeacherStorage.getTeacherStringWithStatus(context)) {
                choosing = ChoosingSpec(context.getString(R.string.settings_titleofteachercell), GroupsAndTeacherStorage.teachersName?.ID, load = { done ->
                    TimetableProvider.teachers?.let { done(it.convert()); return@ChoosingSpec }
                    TimetableProvider.loadTeachers { r -> done(r.data?.convert() ?: emptyList()) }
                }, choose = { GroupsAndTeacherStorage.teachersName = it })
            } }
        }
        GroupedSection(header = stringResource(if (selectedIndex == 0) R.string.settings_settingofgroup else R.string.settings_settingofteacher), rows = rows)
    }
}

class ChoosingSpec(val title: String, val selectedID: Int?, val load: ((List<SettingsModel>) -> Unit) -> Unit, val choose: (SettingsModel) -> Unit)

/** ChoosingWithSearchTableView port */
@Composable
fun ChoosingScreen(spec: ChoosingSpec, onBack: () -> Unit) {
    var all by remember { mutableStateOf<List<SettingsModel>?>(null) }
    var query by remember { mutableStateOf("") }
    var selected by remember { mutableStateOf(spec.selectedID) }
    LaunchedEffect(Unit) {
        spec.load { list ->
            all = list.sortedWith { a, b ->
                when {
                    a.ID == spec.selectedID -> -1
                    b.ID == spec.selectedID -> 1
                    else -> a.title.compareTo(b.title)
                }
            }
        }
    }
    Column(Modifier.fillMaxSize().background(IosColors.groupedBackground).statusBarsPadding()) {
        SheetNavBar(spec.title, leading = {
            Row(Modifier.clickable { onBack() }.padding(horizontal = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                Image(painterResource(R.drawable.ic_sf_chevron_backward), null, Modifier.size(24.dp), colorFilter = ColorFilter.tint(IosColors.accent))
                Text(stringResource(R.string.settings_title), fontSize = 17.sp, color = IosColors.accent)
            }
        }, trailing = { NavTextButton(stringResource(R.string.share_result_done)) { onBack() } })
        Row(Modifier.padding(horizontal = 16.dp, vertical = 6.dp).fillMaxWidth().height(36.dp).clip(RoundedCornerShape(10.dp)).background(androidx.compose.ui.res.colorResource(R.color.ios_searchbarbackground)).padding(horizontal = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            Image(painterResource(R.drawable.ic_sf_search), null, Modifier.size(20.dp), colorFilter = ColorFilter.tint(IosColors.gray))
            Spacer(Modifier.width(6.dp))
            Box(Modifier.weight(1f)) {
                if (query.isEmpty()) Text(stringResource(R.string.choosingsearchcontroller_searchplaceholder), fontSize = 17.sp, color = IosColors.secondaryLabel)
                BasicTextField(query, { query = it }, singleLine = true, textStyle = TextStyle(fontSize = 17.sp, color = IosColors.label), cursorBrush = SolidColor(IosColors.accent), modifier = Modifier.fillMaxWidth())
            }
        }
        val list = all
        if (list == null) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator(color = IosColors.accent) }
        } else {
            val filtered = if (query.isEmpty()) list else list.filter { it.title.lowercase().contains(query.lowercase()) }
            LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(top = 10.dp, bottom = 5.dp)) {
                items(filtered.size) { i ->
                    val el = filtered[i]
                    Row(Modifier.fillMaxWidth().clickable { selected = el.ID; spec.choose(el) }.padding(start = 20.dp, end = 10.dp, top = 12.dp, bottom = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text(el.title, fontSize = 17.sp, color = IosColors.label, modifier = Modifier.weight(1f))
                        if (selected == el.ID) Image(painterResource(R.drawable.ic_sf_checkmark), null, Modifier.size(24.dp), colorFilter = ColorFilter.tint(IosColors.accent))
                    }
                }
            }
        }
    }
}
