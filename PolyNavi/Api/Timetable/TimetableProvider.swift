//
//  TimetableProvider.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.10.2021.
//

import Foundation
import Alamofire

let BASE_URL = "https://ruz.spbstu.ru/api/v1/ruz"

enum ApiStatus<T> {
    case successWith(T)
    case errorNoInternet
    case error
    
    var data: T? {
        get {
            switch self {
            case .successWith(let t):
                return t
            case .errorNoInternet, .error:
                return nil
            }
        }
    }
}

protocol HTTPLoader {
    func load<T:Codable>(url: String, params: Dictionary<String, String>, completion: @escaping (ApiStatus<T>) -> Void)
}

class AFLoader: HTTPLoader {
    func load<T>(url: String, params: Dictionary<String, String>, completion: @escaping (ApiStatus<T>) -> Void) where T : Decodable, T : Encodable {
        AF.request(BASE_URL + url,
                   method: .get,
                   parameters: params)
            .responseDecodable(of: T.self) { response in
                if let responseCode = response.response?.statusCode {
                    switch responseCode {
                    case (200...300):
                        if let data = response.value {
                            completion(.successWith(data))
                        }
                        else {
                            completion(.error)
                        }
                    default:
                        completion(.error)
                    }
                } else {
                    if let error = response.error as NSError? {
                        switch error.code {
                        case 13:
                            completion(.errorNoInternet)
                        default:
                            completion(.error)
                        }
                    }
                    completion(.error)
                }
            }
    }
}

class MockLoader: HTTPLoader {

    func load<T:Codable>(url: String, params: Dictionary<String, String>, completion: @escaping (ApiStatus<T>) -> Void) {
        print(url)
        print(params)
        
        if url == "/faculties" {
            completion(ApiStatus.successWith(FacultiesList(faculties: [
                .init(id: 0, name: "faculty1", abbr: "faculty1"),
                .init(id: 1, name: "faculty2", abbr: "faculty2")
            ]) as! T))
            return
        } else if url.contains("/groups") {
            completion(ApiStatus.successWith(GroupsList(groups: [
                .init(id: 0, kind: 0, level: 0, name: "/1", spec: "", type: "", year: 1),
                .init(id: 1, kind: 0, level: 0, name: "/2", spec: "", type: "", year: 1)
            ], faculty: .init(id: 0, name: "", abbr: "")) as! T))
            return
        } else if url == "/teachers" {
            completion(ApiStatus.successWith(TeachersList(teachers: [
                .init(id: 0, oid: 0, full_name: "Teacher1", first_name: "Teacher1", middle_name: "Teacher1", last_name: "Teacher1", grade: "", chair: ""),
                .init(id: 1, oid: 0, full_name: "Teacher2", first_name: "Teacher2", middle_name: "Teacher2", last_name: "Teacher2", grade: "", chair: "")
            ]) as! T))
            return
        } else if url.contains("/scheduler") {
            
            completion(ApiStatus.successWith(
                Timetable(days: [
                    .init(date: "2022-01-07", weekday: 0, lessons: [
                        .init(additional_info: "123",
                              lms_url: "",
                              subject: "subject",
                              subject_short: "subject_short",
                              webinar_url: "",
                              time_end: "10:00",
                              time_start: "08:00",
                              type: 0,
                              parity: 0,
                              typeObj: .init(id: 0, abbr: "", name: ""),
                              groups: [ .init(id: 0, kind: 0, level: 0, name: "", spec: "", type: "", year: 0, faculty: .init(id: 0, name: "", abbr: "")) ],
                              teachers: [ .init(id: 0, oid: 0, full_name: "", first_name: "", middle_name: "", last_name: "", grade: "", chair: "") ],
                              auditories: [ .init(id: 0, name: "auditori", building: .init(id: 0, abbr: "building", address: "", name: ""))]) ])
                ],
                          week: .init(date_end: "2022-01-07", date_start: "2022-01-01", is_odd: false),
                          group: .init(id: 0, kind: 0, level: 0, name: "", spec: "", type: "", year: 0, faculty: .init(id: 0, name: "", abbr: "")),
                          teacher: .init(id: 0, oid: 0, full_name: "Teacher1", first_name: "Teacher1", middle_name: "Teacher1", last_name: "Teacher1", grade: "", chair: "")
                         ) as! T))
            
            return
        }

        completion(.error)
    }
}

class TimetableProvider {
    static let shared = TimetableProvider()
    
    var timetable: Timetable? = nil
    var faculties: FacultiesList? = nil
    var teachers: TeachersList? = nil
    var groups: GroupsList? = nil
    
    var loader: HTTPLoader
    
    var timetableCache: [String: Timetable] = [:]
    
    init() {
        print(ProcessInfo.processInfo.arguments.contains("UI-TESTING"))
        loader = ProcessInfo.processInfo.arguments.contains("UI-TESTING") ? MockLoader() : AFLoader()
    }
    
    func loadFaculties(completion: @escaping (ApiStatus<FacultiesList>) -> Void) {
        let t: (ApiStatus<FacultiesList>) -> Void = { r in
            self.faculties = r.data
            completion(r)
        }
        
        loader.load(url: "/faculties", params: [:], completion: t)
    }
    
    func loadGroups(faculty: Faculty, completion: @escaping (ApiStatus<GroupsList>) -> Void) {
        let t: (ApiStatus<GroupsList>) -> Void = { r in
            self.groups = r.data
            completion(r)
        }
        
        loader.load(url: "/faculties/\(faculty.id)/groups", params: [:], completion: t)
    }
    
    func loadTeachers(completion: @escaping (ApiStatus<TeachersList>) -> Void) {
        let t: (ApiStatus<TeachersList>) -> Void = { r in
            self.teachers = r.data
            completion(r)
        }
        
        loader.load(url: "/teachers", params: [:], completion: t)
    }
    
    
    func loadTimetabe(id: Int, filter: TimetableFillter, startDate: Date = Date(), fromCache: Bool = false, completion: @escaping (ApiStatus<Timetable>) -> Void = { _ in }) {
        let startWeek = apiFormatDate(startOfWeek(startDate))
        let keyCache = "\(id)-\(filter)-\(startWeek)"
        
        if fromCache {
            if let cached = timetableCache[keyCache] {
                self.timetable = cached
                return completion(.successWith(cached))
            }
        }
        
        let t: (ApiStatus<Timetable>) -> Void = { r in
            self.timetable = r.data
            if fromCache && r.data != nil {
                self.timetableCache.updateValue(r.data!, forKey: keyCache)
            }
            completion(r)
        }
        
        let strURL = (filter == .groups) ? "/scheduler/\(id)" : "/teachers/\(id)/scheduler/"
        loader.load(url: strURL, params: [ "date": startWeek ], completion: t)
        
    }
    
    func loadTimetable(group: ID, completion: @escaping (ApiStatus<Timetable>) -> Void, startDate: Date = Date()) {
        let t: (ApiStatus<Timetable>) -> Void = { r in
            self.timetable = r.data
            completion(r)
        }
        
        loader.load(url: "/scheduler/\(group.id)", params: [ "date": apiFormatDate(startOfWeek(startDate)) ], completion: t)
    }
    
    func loadTimetable(teacher: ID, completion: @escaping (ApiStatus<Timetable>) -> Void, startDate: Date = Date()) {
        let t: (ApiStatus<Timetable>) -> Void = { r in
            self.timetable = r.data
            completion(r)
        }
        
        loader.load(url: "/teachers/\(teacher.id)/scheduler/", params: [ "date": apiFormatDate(startOfWeek(startDate)) ], completion: t)
    }
    
    //MARK:- Support Functions
    func startOfWeek(_ date: Date) -> Date {
        let cal = Calendar(identifier: .iso8601)
        
        return cal.date(from: cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)) ?? Date()
    }
    
    func apiFormatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
