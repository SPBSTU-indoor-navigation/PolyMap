import XCTest
@testable import PolyNavi

class TimetableTest: XCTestCase {
    
    let storage = GroupsAndTeacherStorage.shared
    let timeTableProvider = TimetableProvider.shared
    let groupNumber: Int = 33843 // our group number - 3530904/80105
    let facultyNumber: Int = 95 // Institute of Computer Science and Technology
    let teacherNumber: Int = 5034 // Kotlirova Lina Pavlovna
    
    var timetablePageVC: TimetablePageVC!
    var dateFormmater: DateFormatter!
    var timetableVC: TimetableViewController!
    var settingsVC: SettingTimetableVC!
    var choosingVC: ChoosingWithSearchTableView!
    
    override func setUpWithError() throws {
        timetablePageVC = TimetablePageVC()
        timetablePageVC.viewDidLoad()
        dateFormmater = DateFormatter()
        dateFormmater.dateFormat = "dd.MM.yyyy"
        
        timetableVC = TimetableViewController(date: Date())
        timetableVC.viewDidLoad()
        choosingVC = ChoosingWithSearchTableView()
        choosingVC.viewDidLoad()
        settingsVC = SettingTimetableVC()
        settingsVC.viewDidLoad()
    }
    
    func testLoadFaculties() {
        let loadFaculties = expectation(description: "Correct loading of faculties")
        timeTableProvider.loadFaculties { resp in
            switch resp {
            case .successWith(let data):
                if data.faculties.count == 0 { XCTFail("Count equal zero") }
                loadFaculties.fulfill()
            default:
                XCTFail("No internet")
            }
        }
        
        wait(for: [loadFaculties], timeout: 5)
    }
    
    func testLoadGroups() {
        let loadGroups = expectation(description: "Load group and find our group")
        let correctFacultyNumber = Faculty(id: 95, name: "", abbr: "")
        let incorrectFacultyNumber = Faculty(id: 3228, name: "", abbr: "")
        
        timeTableProvider.loadGroups(faculty: correctFacultyNumber) { resp in
            switch resp {
            case .successWith(let data):
                if data.groups.count == 0 { XCTFail("Count equal zero") }
                let group = data.groups
                let findGroup = group.first(where: { $0.id == self.groupNumber })
                if findGroup == nil {
                    XCTFail("Don't find group")
                }
                loadGroups.fulfill()
            default:
                XCTFail("Unable to load groups")
            }
        }
        
        let loadIncorectGroup = expectation(description: "Load group and find our group")
        
        timeTableProvider.loadGroups(faculty: incorrectFacultyNumber) { resp in
            switch resp {
            case .successWith( _):
                XCTFail("Don't find group")
            default:
                loadIncorectGroup.fulfill()
            }
        }
        
        wait(for: [loadGroups, loadIncorectGroup], timeout: 5)
    }
    
    func testLoadTeacher() {
        let loadTeacher = expectation(description: "Loaded correct info about teacher")
        timeTableProvider.loadTeachers { res in
            switch res {
            case.successWith(let data):
                if data.teachers.count == 0 { XCTFail(" Zero teachers count" ) }
                
                let teachers = data.teachers
                let tryToFoundKnownTeachersID = teachers.first(where: { $0.id == self.teacherNumber })
                if tryToFoundKnownTeachersID == nil {
                    XCTFail("Didn't find known teacher id")
                }
                loadTeacher.fulfill()
            default:
                XCTFail("error loading")
            }
        }
        
        wait(for: [loadTeacher], timeout: 5)
    }
    
    func testLoadTeacherTimetableFromNetwork() {
        let loadTeacherTimetableFromNetwork = expectation(description: "Success load of teacher timetable from netweork")
        let zombieTeacher = Teacher(id: teacherNumber, oid: 1, full_name: "", first_name: "", middle_name: "", last_name: "", grade: "", chair: "")
        timeTableProvider.loadTimetable(teacher: zombieTeacher) { res in
            switch res {
            case .successWith(let data):
                guard
                    let teacherID = data.teacher?.id,
                    teacherID == self.teacherNumber
                else {
                    XCTFail("Incorrect teacher number")
                    return
                }
                loadTeacherTimetableFromNetwork.fulfill()
            default:
                XCTFail("Loading error")
            }
        }
        
        wait(for: [loadTeacherTimetableFromNetwork], timeout: 5)
    }
    
    func testLoadGroupTimetableWithCache() {
        let loadGroupTimetableWithCache = expectation(description: "Success load of groups timetable from network or cash")
        
        timeTableProvider.loadTimetabe(id: groupNumber, filter: .groups, startDate: Date(), fromCache: true) { res in
            switch res {
            case .successWith(let data):
                guard
                    let groupID = data.group?.id,
                    groupID == self.groupNumber
                else {
                    XCTFail("Incorrect group number")
                    return
                }
                loadGroupTimetableWithCache.fulfill()
            default:
                XCTFail("Loading error")
            }
        }
        
        wait(for: [loadGroupTimetableWithCache], timeout: 5)
    }
    
    func testLoadTeacherTimetableWithCache() {
        let loadTeacherTimetableWithCache = expectation(description: "Success load of teachers timetable from network or cash")
        
        timeTableProvider.loadTimetabe(id: teacherNumber, filter: .teachers, startDate: Date(), fromCache: true) { res in
            switch res {
            case.successWith(let data):
                guard
                    let teacher = data.teacher?.id,
                    teacher == self.teacherNumber
                else {
                    XCTFail("Incorrect teacher number")
                    return
                }
                loadTeacherTimetableWithCache.fulfill()
            default:
                XCTFail("Loading error")
            }
            
        }
        
        wait(for: [loadTeacherTimetableWithCache], timeout: 5)
    }
    
    func testLoadGroupTimetableFromNetwork() {
        let loadGroupTimetableFromNetwork = expectation(description: "Success load of group timetable from network")
        let zombieGroup = Group(id: groupNumber, kind: 1, level: 1, name: "", spec: "", type: "", year: 1)
        timeTableProvider.loadTimetable(group: zombieGroup) { res in
            switch res {
            case.successWith(let data):
                guard
                    let groupID = data.group?.id,
                    groupID == self.groupNumber
                else {
                    XCTFail("Incorrect group number")
                    return
                }
                loadGroupTimetableFromNetwork.fulfill()
            default:
                XCTFail("Loading error")
            }
        }
        
        wait(for: [loadGroupTimetableFromNetwork], timeout: 5)
    }
    
    func testUpdateWeek() {
        let stringDate = "20.02.2022"
        guard let date = dateFormmater.date(from: stringDate) else {
            XCTFail("Incorrect date")
            return
        }

        let nextWeek = dateFormmater.string(from: timetablePageVC.addWeak(date: date, count: +1))
        XCTAssertEqual(nextWeek, "27.02.2022")
    }
    
    func testLerp() {
        let lerpValue = timetablePageVC.lerp(0, 20, 5)
        XCTAssertEqual(lerpValue, 100)
    }
    
    func testLoader() {
        timetableVC.loadData()
        XCTAssert(timetableVC.loader.isAnimating)
    }
    
    func testLoaderWhileRefresh() {
        storage.currentFilter = .groups
        storage.currentGroupNumber = SettingsModel(ID: groupNumber, title: "")
        let promise = expectation(description: "Data was refreshed")
        timetableVC.refreshDate { [weak self] in
            guard let self = self else { return }
            XCTAssertNotEqual(self.timetableVC.arrayOfDaysWithLessons.count, 0)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
    }
    
    func testIndicatorWhileLoadingInChoosingVC() {
        choosingVC.loadData()
        XCTAssert(choosingVC.indicator.isAnimating)
    }
    
    func testLessonModelParsing() {
        let promise = expectation(description: "Correct parsing")
        let zombieGroup = Group(id: groupNumber, kind: 1, level: 1, name: "", spec: "", type: "", year: 1)
        timeTableProvider.loadTimetable(group: zombieGroup) { res in
            switch res {
            case .successWith(let data):
                let timetableWeek = TimetableWeek.convert(data)
                XCTAssertEqual(timetableWeek.week, data.week)
                promise.fulfill()
            default:
                XCTFail("Fail loading")
            }
        }
        wait(for: [promise], timeout: 5)
    }
    
    func testLoadCells() {
        _ = LessonCellView(style: .default, reuseIdentifier: "")
        _ = DateTableViewCell(reuseIdentifier: "")
        _ = TimetableBreakTableViewCell(style: .default, reuseIdentifier: "")
        _ = ChoosingTableViewCell(style: .default, reuseIdentifier: "")
    }
    
    func testApiFormatDate() {
//        let dateString = "22.02.2022"
//        guard let date = dateFormmater.date(from: dateString) else {
//            XCTFail("Incorrect date")
//            return
//        }
//        let providerStr = timeTableProvider.apiFormatDate(date)
//        XCTAssertEqual(providerStr, "2022-02-22")
    }
    
    func testStartDate() {
        let dateString = "22.02.2022"
        guard let date = dateFormmater.date(from: dateString) else {
            XCTFail("Incorrect date")
            return
        }
        let startWeekDate = timeTableProvider.startOfWeek(date)
        let strDate = dateFormmater.string(from: startWeekDate)
        XCTAssertEqual(strDate, "21.02.2022")
    }
    
    func testConvertTeachers() {
        let promise = expectation(description: "Convert Teachers")
        
        timeTableProvider.loadTeachers { res in
            switch res {
            case.successWith(let data):
                let teacherConvert = data.convert()
                var flag = true
                for i in 0..<teacherConvert.count {
                    if data.teachers[i].id != teacherConvert[i].ID {
                        flag = false
                    }
                }
                XCTAssert(flag)
                promise.fulfill()
            default:
                XCTFail("")
            }
        }
        
        wait(for: [promise], timeout: 5)
    }
    
    func testConvertFaculties() {
        let promise = expectation(description: "Convert Group")
        
        timeTableProvider.loadFaculties { res in
            switch res {
            case.successWith(let data):
                let facultesConvert = data.convert()
                var flag = true
                for i in 0..<facultesConvert.count {
                    if data.faculties[i].id != facultesConvert[i].ID {
                        flag = false
                    }
                }
                XCTAssert(flag)
                promise.fulfill()
            default:
                XCTFail("")
            }
        }
        
        wait(for: [promise], timeout: 5)
    }
    
    func testConvertGroup() {
        let promise = expectation(description: "Convert Group")
        let zombie = Faculty(id: facultyNumber, name: "", abbr: "")
        
        timeTableProvider.loadGroups(faculty: zombie) { res in
            switch res {
            case .successWith(let data):
                let group = data.convert()
                var flag = true
                for i in 0..<group.count {
                    if data.groups[i].id != group[i].ID {
                        flag = false
                    }
                }
                XCTAssert(flag)
                promise.fulfill()
            default:
                XCTFail()
            }
        }
        
        wait(for: [promise], timeout: 5)
    }
    
    func testCellForRowAtInTimetableVC() {
        timetableVC.loadData()
//        while timetableVC.loader.isAnimating {
//            sleep(1)
//        }
//
//        let cellForRow: (IndexPath) -> UITableViewCell = { indexPath in
//            self.timetableVC.tableView(self.timetableVC.tableView, cellForRowAt: indexPath)
//        }
//
//        guard timetableVC.arrayOfDaysWithLessons.count != 0 else {
//            XCTFail("Empty array after loading")
//            return
//        }
//
//        XCTAssert(cellForRow(IndexPath(row: 0, section: 1)) is LessonCellView)
    }
    
    func testHeaderViewAtInTimetableVC() {
        timetableVC.loadData()
//        while timetableVC.loader.isAnimating {
//            sleep(1)
//        }
//        
//        guard timetableVC.arrayOfDaysWithLessons.count != 0 else {
//            XCTFail("Empty array after loading")
//            return
//        }
        
        XCTAssert(timetableVC.tableView(timetableVC.tableView, viewForHeaderInSection: 0) is DateTableViewCell)
    }
    
    func testRefreshIsHiddenAfterLoad() {
        let promise = expectation(description: "Refresh is hidden")
        timetableVC.refreshDate {
            guard let refresh = self.timetableVC.tableView.refreshControl else {
                XCTFail("Refresh isn't included into table")
                return
            }
            
            XCTAssert(!refresh.isRefreshing)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
    }
}
