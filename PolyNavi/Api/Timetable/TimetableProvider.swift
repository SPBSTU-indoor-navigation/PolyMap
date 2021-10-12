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
    
    func loadTimetable(group: Group,
                       completion: @escaping (Timetable?) -> Void,
                       startDate: Date = Date()) {
        
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let date = cal.date(from: cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: startDate)) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        AF.request(BASE_URL + "/scheduler/\(group.id)",
                   method: .get,
                   parameters: [ "date": formatter.string(from: date) ])
            .validate(statusCode: 200...200)
            .responseDecodable(of: Timetable.self) { response in
                self.timetable = response.value
                completion(self.timetable)
        }
    }
}
