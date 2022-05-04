//
//  TimetableProvider.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.10.2021.
//

import Foundation
import Alamofire

class TimetableProvider {
    
    enum Constants {
        static let BASE_URL = "https://ruz.spbstu.ru/api/v1/ruz"
    }
    
    static let shared = TimetableProvider()
    
    var timetable: Timetable? = nil
    var faculties: FacultiesList? = nil
    var teachers: TeachersList? = nil
    var groups: GroupsList? = nil
    
    var timetableCache: [String: Timetable] = [:]
    
    func load<T:Codable>(url: String, params: Dictionary<String, String>, completion: @escaping (ApiStatus<T>) -> Void) {
        NetworkShared.load(url: Constants.BASE_URL + url, metod: .get, params: params, completion: completion)
    }
    
    func loadFaculties(completion: @escaping (ApiStatus<FacultiesList>) -> Void) {
        let t: (ApiStatus<FacultiesList>) -> Void = { r in
            self.faculties = r.data
            completion(r)
        }
        
        load(url: "/faculties", params: [:], completion: t)
    }
    
    
    func loadGroups(faculty: Faculty, completion: @escaping (ApiStatus<GroupsList>) -> Void) {
        let t: (ApiStatus<GroupsList>) -> Void = { r in
            self.groups = r.data
            completion(r)
        }
        
        load(url: "/faculties/\(faculty.id)/groups", params: [:], completion: t)
    }
    
    func loadTeachers(completion: @escaping (ApiStatus<TeachersList>) -> Void) {
        let t: (ApiStatus<TeachersList>) -> Void = { r in
            self.teachers = r.data
            completion(r)
        }
        
        load(url: "/teachers", params: [:], completion: t)
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
        load(url: strURL, params: [ "date": startWeek ], completion: t)
        
    }
    
    func loadTimetable(group: ID, completion: @escaping (ApiStatus<Timetable>) -> Void, startDate: Date = Date()) {
        let t: (ApiStatus<Timetable>) -> Void = { r in
            self.timetable = r.data
            completion(r)
        }
        
        load(url: "/scheduler/\(group.id)", params: [ "date": apiFormatDate(startOfWeek(startDate)) ], completion: t)
    }
    
    func loadTimetable(teacher: ID, completion: @escaping (ApiStatus<Timetable>) -> Void, startDate: Date = Date()) {
        let t: (ApiStatus<Timetable>) -> Void = { r in
            self.timetable = r.data
            completion(r)
        }
        
        load(url: "/teachers/\(teacher.id)/scheduler/", params: [ "date": apiFormatDate(startOfWeek(startDate)) ], completion: t)
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
