//
//  TimetableProvider.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.10.2021.
//

import Foundation
import Alamofire

class TimetableProvider {
    static let shared = TimetableProvider()
    
    var timetable: Timetable? = nil
    
    func loadTimetable(startDate: Date?, completion: @escaping (Timetable?) -> Void) {
        
        
        var c = Calendar(identifier: .iso8601)
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let date = c.date(from: c.dateComponents([.weekOfYear, .yearForWeekOfYear], from: startDate ?? Date()))!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        AF.request("https://ruz.spbstu.ru/api/v1/ruz/scheduler/33843", method: .get, parameters: [ "date": formatter.string(from: date) ])
            .validate(statusCode: 200...200)
            .responseDecodable(of: Timetable.self) { response in
                self.timetable = response.value
                completion(self.timetable)
        }
    }
}
