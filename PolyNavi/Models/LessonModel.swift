//
//  LessonModel.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 05.10.2021.
//


import Foundation

struct TimetableWeek {
    let days: [TimetableDay]
    let week: Timetable.Week
    
    struct TimetableDay {
        let date: Date?
        var timetableCell: [TimetableCellModel]
    }
    
    static var dateParser: DateFormatter = {
        $0.dateFormat = "yyyy-MM-dd"
        return $0
    }(DateFormatter())
    
    static var dateTimeParser: DateFormatter = {
        $0.locale = Locale(identifier: "ru_RU")
        $0.dateFormat = "yyyy-MM-dd HH:mm"
        return $0
    }(DateFormatter())

    
    static func convert(_ t: Timetable) -> TimetableWeek {
        let days = t.days.map { day -> TimetableDay in
            let lessons = day.lessons.map { lesson -> LessonModel in
                let aud = lesson.auditories[0]
                let audName = aud.building.name + ", " + aud.name
                
                return LessonModel(subjectName: lesson.subject,
                                   timeStart: dateTimeParser.date(from: day.date + " " + lesson.time_start)!,
                                   timeEnd: dateTimeParser.date(from: day.date + " " + lesson.time_end)!,
                                   type: LessonModel.LessonType.parse(lesson.typeObj.name),
                                   typeName: lesson.typeObj.name,
                                   place: audName,
                                   teacher: lesson.teachers?[0].full_name ?? "")
                }
            
            return TimetableDay(date: dateParser.date(from: day.date), timetableCell: lessons)
        }
        
        return TimetableWeek(days: days, week: t.week)
    }
}

protocol TimetableCellModel { }

struct BreakModel: TimetableCellModel {
    let timeStart: Date
    let timeEnd: Date
}

struct LessonModel: TimetableCellModel {
    let subjectName: String
    let timeStart: Date
    let timeEnd: Date
    let type: LessonType
    let typeName: String
    let place: String
    let teacher: String
    
    enum LessonType {
        case Lecture
        case Practice
        case Other
        
        static func parse(_ name: String) -> LessonType {
            switch name {
            case "Лекции":
                return .Lecture
            case "Практика":
                return .Practice
            default:
                return .Other
            }
        }
    }
    
    static func createCorrectTimeTable(currentArray: [TimetableCellModel]) -> [TimetableCellModel] {
        var correctArray: [TimetableCellModel] = []
        correctArray.append(currentArray[0])
        
        for i in 1..<currentArray.count {
            if let currentLesson = currentArray[i] as? LessonModel {
                if let lastLesson = currentArray[i - 1] as? LessonModel {
                    if lastLesson.timeEnd.distance(to: currentLesson.timeStart) >= 1 * 60 * 60 {
                        correctArray.append(BreakModel(timeStart: lastLesson.timeEnd, timeEnd: currentLesson.timeStart))
                    }
                }
            }
            correctArray.append(currentArray[i])
        }
        return correctArray
    }
}
