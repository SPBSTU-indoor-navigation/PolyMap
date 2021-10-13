//
//  TimetableProvider.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.10.2021.
//

import Foundation
import Alamofire

let BASE_URL = "https://ruz.spbstu.ru/api/v1/ruz"

class TimetableProvider {
    static let shared = TimetableProvider()
    
    var timetable: Timetable? = nil
    var faculties: FacultiesList? = nil
    var teachers: TeachersList? = nil
    
    func loadFaculties(completion: @escaping (FacultiesList?) -> Void) {
        AF.request(BASE_URL + "/faculties", method: .get)
            .validate(statusCode: 200...200)
            .responseDecodable(of: FacultiesList.self) { response in
                self.faculties = response.value
                completion(self.faculties)
        }
    }
    
    func loadGroups(faculty: Faculty, completion: @escaping (GroupsList?) -> Void) {
        AF.request(BASE_URL + "/faculties/\(faculty.id)/groups", method: .get)
            .validate(statusCode: 200...200)
            .responseDecodable(of: GroupsList.self) { response in
                completion(response.value)
        }
    }
    
    func loadTeachers(completion: @escaping (TeachersList?) -> Void) {
        AF.request(BASE_URL + "/teachers", method: .get)
            .validate(statusCode: 200...200)
            .responseDecodable(of: TeachersList.self) { response in
                self.teachers = response.value
                completion(self.teachers)
        }
    }
    
    func loadTimetable(group: ID, completion: @escaping (Timetable?) -> Void, startDate: Date = Date()) {
        AF.request(BASE_URL + "/scheduler/\(group.id)",
                   method: .get,
                   parameters: [ "date": apiFormatDate(startOfWeek(Date())) ])
            .validate(statusCode: 200...200)
            .responseDecodable(of: Timetable.self) { response in
                self.timetable = response.value
                completion(self.timetable)
        }
    }
    
    func loadTimetable(teacher: ID, completion: @escaping (Timetable?) -> Void, startDate: Date = Date()) {
        AF.request(BASE_URL + "/teachers/\(teacher.id)/scheduler/",
                   method: .get,
                   parameters: [ "date": apiFormatDate(startOfWeek(startDate))])
            .validate(statusCode: 200...200)
            .responseDecodable(of: Timetable.self) { response in
                self.timetable = response.value
                completion(self.timetable)
        }
    }
    
    //MARK:- Support Functions
    func startOfWeek(_ date: Date) -> Date
    {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        
        return cal.date(from: cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)) ?? Date()
    }
    
    func apiFormatDate(_ date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
