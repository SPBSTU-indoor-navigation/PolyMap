//
//  TimeTable.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.10.2021.
//

import Foundation

protocol ID {
    var id: Int { get }
}

protocol SettingsModelProtocol {
    func convert() -> [SettingsModel]
}

struct Timetable: Codable {
    let days: [Day]
    let week: Week
    let group: Timetable.Group?
    let teacher: Teacher?
    
    struct Day: Codable {
        let date: String                    // "2021-10-04"
        let weekday: Int                    // 1
        let lessons: [Lesson]
        
        struct Lesson: Codable {
            let additional_info: String     // "Поток"
            let lms_url: String             // "https://dl.spbstu.ru//course/view.php?id=3104"
            let subject: String             // "Компьютерная графика"
            let subject_short: String       // "Компьютерная графика"
            let webinar_url: String         // ""
            let time_end: String            // "13:40"
            let time_start: String          // "12:00"
            let type: Int                   // 2
            let parity: Int                 // 0
            let typeObj: TypeObj
            let groups: [Timetable.Group]
            let teachers: [Teacher]?
            let auditories: [Auditorie]
            
            struct TypeObj: Codable, ID {
                let id: Int                 // 35
                let abbr: String            // "Кпр"
                let name: String            // "Курсовое проектирование"
            }
        }
    }
    
    struct Auditorie: Codable, ID {
        let id: Int                         // 892
        let name: String                    // "102"
        let building: Building
        
        struct Building: Codable, ID {
            let id: Int                     // 18
            let abbr: String                // "3 к."
            let address: String             // ""
            let name: String                // "3-й учебный корпус"
        }
    }
    
    struct Group: Codable, ID {
        let id: Int                         // 33843
        let kind: Int                       // 0
        let level: Int                      // 4
        let name: String                    // "3530904/80105"
        let spec: String                    // "09.03.04 Программная инженерия"
        let type: String                    // "common"
        let year: Int                       // 2021
        let faculty: Faculty
    }
    
    struct Week: Codable {
        let date_end: String                //"2021.10.10"
        let date_start: String              //"2021.10.04"
        let is_odd: Bool                    //false
    }
}


struct Faculty: Codable, ID {
    let id: Int                             // 117
    let name: String                        // "Университетский политехнический колледж"
    let abbr: String                        // "УПКР"
}

struct Group: Codable, ID {
    let id: Int                             // 33870,
    let kind: Int                           // 0,
    let level: Int                          // 1,
    let name: String                        // "4931101/10001",
    let spec: String                        // "",
    let type: String                        // "common",
    let year: Int                           // 2021
}

struct Teacher: Codable, ID {
    let id: Int                             // 5302
    let oid: Int                            // 29307
    let full_name: String                   // "Леонтьева Татьяна Владимировна"
    let first_name: String                  // "Леонтьева"
    let middle_name: String                 // "Татьяна"
    let last_name: String                   // "Владимировна"
    let grade: String                       // ""
    let chair: String                       // "35/04 Кафедра \"Информационные и управляющие системы\""
}

struct FacultiesList: Codable, SettingsModelProtocol {
    let faculties: [Faculty]
    
    public func convert() -> [SettingsModel] {
        return self.faculties.map { SettingsModel(ID: $0.id, title: $0.name) }
    }
}

struct GroupsList: Codable, SettingsModelProtocol {
    let groups: [Group]
    let faculty: Faculty
    
    public func convert() -> [SettingsModel] {
        return self.groups.map { SettingsModel(ID: $0.id, title: $0.name) }
    }
}

struct TeachersList: Codable, SettingsModelProtocol {
    let teachers: [Teacher]
    
    public func convert() -> [SettingsModel] {
        return self.teachers.map { SettingsModel(ID: $0.id, title: $0.full_name) }
    }
}
