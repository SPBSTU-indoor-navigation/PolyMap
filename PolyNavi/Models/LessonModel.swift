//
//  LessonModel.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 05.10.2021.
//


import Foundation

struct TimetableWeek {
    let days: [TimetableDay]
    
    struct TimetableDay {
        let date: Date?
        var lessons: [Base]
    }
    
    static var dateFormmater: DateFormatter = {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy-MM-dd"
        return formmater
    }()
    
    static var dateTimeParser: DateFormatter = {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy-MM-dd HH:mm"
        return formmater
    }()

    
    static func convert(_ t: Timetable) -> TimetableWeek {
        let days = t.days.map { day -> TimetableDay in
            let lessons = day.lessons.map { lesson -> LessonModel in
                let aud = lesson.auditories[0]
                let audName = aud.building.name + ", " + aud.name
                
                return LessonModel(subjectName: lesson.subject,
                                   timeStart: dateTimeParser.date(from: day.date + " " + lesson.time_start)!,
                                   timeEnd: dateTimeParser.date(from: day.date + " " + lesson.time_end)!,
                                   type: lesson.typeObj.name,
                                   place: audName,
                                   teacher: lesson.teachers?[0].full_name ?? "")
                }
            
            return TimetableDay(date: dateFormmater.date(from: day.date), lessons: lessons)
        }
        
        return TimetableWeek(days: days)
    }
}

protocol Base { }

struct BreakModel: Base {
    let timeStart: Date
    let timeEnd: Date
}

struct LessonModel: Base {
    let subjectName: String
    let timeStart: Date
    let timeEnd: Date
    let type: String
    let place: String
    let teacher: String
    
    public func isEmptyLesson() -> Bool {
        return subjectName.isEmpty && type.isEmpty && place.isEmpty && teacher.isEmpty
    }
    
    public func isLecture() -> Bool {
        type == "Лекции"
    }
    
    static func createCorrectTimeTable(currentArray: [Base]) -> [Base] {
        var correctArray: [Base] = []
        correctArray.append(currentArray[0])
        if (currentArray.count == 1) {
            return correctArray
        }
        for i in 1..<currentArray.count {
            if let currentLesson = currentArray[i] as? LessonModel {
                if let lastLesson = currentArray[i - 1] as? LessonModel {
                    if lastLesson.timeEnd.distance(to: currentLesson.timeStart) >= 0 * 2 * 60 * 60 {
                        correctArray.append(BreakModel(timeStart: lastLesson.timeEnd, timeEnd: currentLesson.timeStart))
                    }
                }
            }
            correctArray.append(currentArray[i])
        }
        return correctArray
    }
}
