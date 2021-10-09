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

        AF.request("https://ruz.spbstu.ru/api/v1/ruz/scheduler/33843", method: .get).validate(statusCode: 200...200).responseDecodable(of: Timetable.self) { response in
            self.timetable = response.value
            completion(self.timetable)
        }
    }
}
