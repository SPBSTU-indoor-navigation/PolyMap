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
    func testExample() throws {
        TimetableProvider.shared.loader = TimeTableItegration.createMook(status: .success, response: Timetable(
        days: [
            .init(date: "2022-01-01", weekday: 2, lessons: [lesson1]),
            .init(date: "2022-01-03", weekday: 3, lessons: [lesson1])
        ],
        week: .init(date_end: "", date_start: "",is_odd: false),
        group: nil,
        teacher: nil))
        
        
        let loadFaculties = expectation(description: "Correct loading of faculties")
        let timeTableVC = TimetableViewController(date: .now)
        
        timeTableVC.loadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            print(timeTableVC.arrayOfDaysWithLessons)
            
            XCTAssertEqual(timeTableVC.arrayOfDaysWithLessons.count, 2)
            XCTAssertEqual(timeTableVC.arrayOfDaysWithLessons[0].timetableCell.count, 1)
            XCTAssertEqual(timeTableVC.arrayOfDaysWithLessons[1].timetableCell.count, 1)
            XCTAssertTrue(timeTableVC.arrayOfDaysWithLessons[0].timetableCell[0] is LessonModel)
            guard let lesson1 = timeTableVC.arrayOfDaysWithLessons[0].timetableCell[0] as? LessonModel,
                  let lesson2 = timeTableVC.arrayOfDaysWithLessons[1].timetableCell[0] as? LessonModel else { return XCTFail() }
            
            XCTAssertEqual(lesson1.subjectName, "lesson")
            XCTAssertEqual(lesson2.subjectName, "lesson")
            
            loadFaculties.fulfill()
        })
        
        wait(for: [loadFaculties], timeout: 5)
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
