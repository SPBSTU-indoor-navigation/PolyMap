//
//  TimeTableItegration.swift
//  TimeTableItegration
//
//  Created by Andrei Soprachev on 07.04.2022.
//

import XCTest
@testable import PolyNavi

class CustomLoader: HTTPLoader {
    
    let response: ApiStatus<Codable>
    
    init(response: ApiStatus<Codable>) {
        self.response = response
    }
    
    func load<T:Codable>(url: String, params: Dictionary<String, String>, completion: @escaping (ApiStatus<T>) -> Void) {
        switch response {
        case .errorNoInternet:
            completion(ApiStatus.errorNoInternet)
            return
        case .error:
            completion(ApiStatus.error)
            return
        case .successWith(let data):
            completion(ApiStatus.successWith(data as! T))
            return
        }
    }
}

class TimeTableItegration: XCTestCase {
    
    var auditory1 = Timetable.Auditorie(id: 0, name: "1", building: .init(id: 0, abbr: "GZ", address: "", name: "GZ"))
    var teacher1 = Teacher(id: 0, oid: 0, full_name: "full_name", first_name: "first_name", middle_name: "middle_name", last_name: "last_name", grade: "", chair: "")
    var lesson1: Timetable.Day.Lesson!
    var faculties = FacultiesList(faculties: [Faculty(id: 0, name: "Faculty1", abbr: "Faculty1")])
    var groups = GroupsList(groups: [Group(id: 0, kind: 0, level: 0, name: "Name", spec: "Name", type: "Name", year: 1)], faculty: Faculty(id: 0, name: "Faculty1", abbr: "Faculty1"))
    let teacherList = TeachersList(teachers: [Teacher(id: 0, oid: 0, full_name: "full_name", first_name: "first_name", middle_name: "middle_name", last_name: "last_name", grade: "", chair: "")])

    override func setUpWithError() throws {
        lesson1 = .init(additional_info: "",
                        lms_url: "",
                        subject: "lesson",
                        subject_short: "",
                        webinar_url: "",
                        time_end: "15:00",
                        time_start: "14:00",
                        type: 4,
                        parity: 2,
                        typeObj: .init(id: 1, abbr: "", name: ""),
                        groups: [.init(id: 0, kind: 0, level: 0, name: "", spec: "", type: "", year: 0, faculty: .init(id: 9, name: "", abbr: ""))],
                        teachers: [teacher1],
                        auditories: [auditory1])
    }

    override func tearDownWithError() throws {
    }

//  Проверка корректного отображения расписания после загрузки
    func testTimetableWithSuccess() throws {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .success, response: Timetable(
        days: [
            .init(date: "2022-01-01", weekday: 2, lessons: [lesson1]),
            .init(date: "2022-01-03", weekday: 3, lessons: [lesson1])
        ],
        week: .init(date_end: "", date_start: "",is_odd: false),
        group: nil,
        teacher: nil))
        
        
        let loadFaculties = expectation(description: "Correct loading of timetable")
        let timeTableVC = TimetableViewController(date: .now)
        
        timeTableVC.loadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(timeTableVC.arrayOfDaysWithLessons.count, 2)
            XCTAssertEqual(timeTableVC.arrayOfDaysWithLessons[0].timetableCell.count, 1)
            XCTAssertEqual(timeTableVC.arrayOfDaysWithLessons[1].timetableCell.count, 1)
            XCTAssertTrue(timeTableVC.arrayOfDaysWithLessons[0].timetableCell[0] is LessonModel)
            guard let lesson1 = timeTableVC.arrayOfDaysWithLessons[0].timetableCell[0] as? LessonModel,
                  let lesson2 = timeTableVC.arrayOfDaysWithLessons[1].timetableCell[0] as? LessonModel else { return XCTFail() }
            
            XCTAssertEqual(lesson1.subjectName, "lesson")
            XCTAssertEqual(lesson2.subjectName, "lesson")
            
            loadFaculties.fulfill()
        }
        
        wait(for: [loadFaculties], timeout: 10)
    }
    
    // Отображение что интернета нет при скачивание расписание
    func testTimetableWithNoInternet() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .inetError, response: nil)
        let loadFaculties = expectation(description: "Trouble with internet connection")
        let timeTableVC = TimetableViewController(date: .now)
        
        timeTableVC.refreshDate {
            XCTAssert(!timeTableVC.label.isHidden)
            XCTAssertEqual(timeTableVC.label.text, "Please, check internet connection")
            loadFaculties.fulfill()
        }

        wait(for: [loadFaculties], timeout: 12)
    }
    
    // Отображение что произошла ошибка при скачивание расписания
    func testTimetableWithError() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .error, response: nil)
        let loadFaculties = expectation(description: "Incorrect loading")
        let timeTableVC = TimetableViewController(date: .now)
        
        timeTableVC.refreshDate {
            XCTAssert(!timeTableVC.label.isHidden)
            XCTAssertEqual(timeTableVC.label.text, "Error with loading timetable")
            loadFaculties.fulfill()
        }

        wait(for: [loadFaculties], timeout: 10)
    }
    
    func testChoosingFacultiesWithSuccess() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .success, response: faculties)
        let load = expectation(description: "Correct loading of faculties")
        let settingsVC = ChoosingWithSearchTableView()
        settingsVC.loadFunction = { completion, _ in
            TimetableProvider.shared.loadFaculties { response in
                guard let data = response.data?.convert() else {
                    XCTFail()
                    return
                }
                completion(data)
                XCTAssertEqual(settingsVC.currentArray.count, 1)
                XCTAssertEqual(settingsVC.currentArray[0].title, self.faculties.faculties[0].name)
                load.fulfill()
            }
        }
        settingsVC.loadData()

        wait(for: [load], timeout: 10)
    }
    
    func testChoosingFacultiesWithInternetError() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .inetError, response: nil)
        let settingsVC = ChoosingWithSearchTableView()
        let load = expectation(description: "Trouble with internet while faculties loading")
        settingsVC.loadFunction = { _, error in
            TimetableProvider.shared.loadFaculties { response in
                switch response {
                case .errorNoInternet:
                    error(.errorWithInternet)
                    DispatchQueue.main.async {
                        XCTAssert(!settingsVC.label.isHidden)
                        XCTAssertEqual(settingsVC.label.text, "Please, check internet connection")
                        load.fulfill()
                    }
                case .error:
                    XCTFail()
                default:
                    XCTFail()
                }
            }
        }
        settingsVC.loadData()
        wait(for: [load], timeout: 10)
    }
    
    func testChoosingFacultiesWithError() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .error, response: nil)
        let settingsVC = ChoosingWithSearchTableView()
        let load = expectation(description: "Error with faculties loading")
        settingsVC.loadFunction = { _, error in
            TimetableProvider.shared.loadFaculties { response in
                switch response {
                case .errorNoInternet:
                    XCTFail()
                case .error:
                    error(.error)
                    DispatchQueue.main.async {
                        XCTAssert(!settingsVC.label.isHidden)
                        XCTAssertEqual(settingsVC.label.text, "Error with loading timetable")
                        load.fulfill()
                    }
                default:
                    XCTFail()
                }
            }
        }
        settingsVC.loadData()
        wait(for: [load], timeout: 10)
    }
    
    func testChoosingGroupWithSuccess() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .success, response: groups)
        let load = expectation(description: "Correct loading of groups")
        let settingsVC = ChoosingWithSearchTableView()
        settingsVC.loadFunction = { completion, _ in
            TimetableProvider.shared.loadGroups(faculty: Faculty(id: 0, name: "Name", abbr: "Name")) { response in
                guard let data = response.data?.convert() else {
                    XCTFail()
                    return
                }
                completion(data)
                XCTAssertEqual(settingsVC.currentArray.count, 1)
                XCTAssertEqual(settingsVC.currentArray[0].title, self.groups.groups[0].name)
                load.fulfill()
            }
        }
        settingsVC.loadData()

        wait(for: [load], timeout: 10)
    }
    
    func testChoosingGroupWithInternetError() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .inetError, response: nil)
        let settingsVC = ChoosingWithSearchTableView()
        let load = expectation(description: "Trouble with internet while loading groups")
        settingsVC.loadFunction = { _, error in
            TimetableProvider.shared.loadGroups(faculty: Faculty(id: 0, name: "Name", abbr: "Name")) { response in
                switch response {
                case .errorNoInternet:
                    error(.errorWithInternet)
                    DispatchQueue.main.async {
                        XCTAssert(!settingsVC.label.isHidden)
                        XCTAssertEqual(settingsVC.label.text, "Please, check internet connection")
                        load.fulfill()
                    }
                case .error:
                    XCTFail()
                default:
                    XCTFail()
                }
            }
        }
        settingsVC.loadData()
        wait(for: [load], timeout: 10)
    }
    
    func testChoosingGroupWithError() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .error, response: nil)
        let settingsVC = ChoosingWithSearchTableView()
        let load = expectation(description: "Error with groups loading")
        settingsVC.loadFunction = { _, error in
            TimetableProvider.shared.loadGroups(faculty: Faculty(id: 0, name: "Name", abbr: "Name")) { response in
                switch response {
                case .errorNoInternet:
                    XCTFail()
                case .error:
                    error(.error)
                    DispatchQueue.main.async {
                        XCTAssert(!settingsVC.label.isHidden)
                        XCTAssertEqual(settingsVC.label.text, "Error with loading timetable")
                        load.fulfill()
                    }
                default:
                    XCTFail()
                }
            }
        }
        settingsVC.loadData()
        wait(for: [load], timeout: 10)
    }
    
    func testChoosingTeacherWithSuccess() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .success, response: teacherList)
        let settingsVC = ChoosingWithSearchTableView()
        let load = expectation(description: "Correct loading of teachers")
        settingsVC.loadFunction = { completion, _ in
            TimetableProvider.shared.loadTeachers { response in
                guard let data = response.data?.convert() else {
                    XCTFail()
                    return
                }
                completion(data)
                XCTAssertEqual(settingsVC.currentArray.count, 1)
                XCTAssertEqual(settingsVC.currentArray[0].title, self.teacherList.teachers[0].full_name)
                load.fulfill()
            }
        }
        settingsVC.loadData()

        wait(for: [load], timeout: 10)
    }
    
    func testChoosingTeacherWithInternetError() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .inetError, response: nil)
        let settingsVC = ChoosingWithSearchTableView()
        let load = expectation(description: "Trouble with internet while loading teachers")
        settingsVC.loadFunction = { _, error in
            TimetableProvider.shared.loadTeachers { response in
                switch response {
                case .errorNoInternet:
                    error(.errorWithInternet)
                    DispatchQueue.main.async {
                        XCTAssert(!settingsVC.label.isHidden)
                        XCTAssertEqual(settingsVC.label.text, "Please, check internet connection")
                        load.fulfill()
                    }
                case .error:
                    XCTFail()
                default:
                    XCTFail()
                }
            }
        }
        settingsVC.loadData()
        wait(for: [load], timeout: 10)
    }
    
    func testChoosingTeacherWithError() {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .error, response: nil)
        let settingsVC = ChoosingWithSearchTableView()
        let load = expectation(description: "Error with loading of teachers")
        settingsVC.loadFunction = { _, error in
            TimetableProvider.shared.loadTeachers { response in
                switch response {
                case .errorNoInternet:
                    XCTFail()
                case .error:
                    error(.error)
                    DispatchQueue.main.async {
                        XCTAssert(!settingsVC.label.isHidden)
                        XCTAssertEqual(settingsVC.label.text, "Error with loading timetable")
                        load.fulfill()
                    }
                default:
                    XCTFail()
                }
            }
        }
        settingsVC.loadData()
        wait(for: [load], timeout: 10)
    }
    
    enum Status {
        case success
        case error
        case inetError
    }
    
    static func createMook(status: Status, response: Any? = nil) -> CustomLoader {
        
        var res: ApiStatus<Codable>
        switch status {
        case .success:
            res = ApiStatus.successWith(response as! Codable)
        case .error:
            res = ApiStatus.error
        case .inetError:
            res = ApiStatus.errorNoInternet
        }
        
        return CustomLoader(response: res)
    }
}
