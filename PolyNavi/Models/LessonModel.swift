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
        var lessons: [LessonModel]
    }
    
    static var dateFormmater: DateFormatter = {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy-MM-dd"
        return formmater
    }()

    
    static func convert(_ t: Timetable) -> TimetableWeek {
        let days = t.days.map { day -> TimetableDay in
            let lessons = day.lessons.map { lesson -> LessonModel in
                let aud = lesson.auditories[0]
                let audName = aud.building.name + ", " + aud.name
                
                return LessonModel(subjectName: lesson.subject,
                                   timeStart: lesson.time_start,
                                   timeEnd: lesson.time_end,
                                   type: lesson.typeObj.name,
                                   place: audName,
                                   teacher: lesson.teachers?[0].full_name ?? "")
                }
            
            return TimetableDay(date: dateFormmater.date(from: day.date), lessons: lessons)
        }
        
        return TimetableWeek(days: days)
    }
}

struct LessonModel {
    let subjectName: String
    let timeStart: String
    let timeEnd: String
    let type: String
    let place: String
    let teacher: String
    
    public func isEmptyLesson() -> Bool {
        return subjectName.isEmpty && type.isEmpty && place.isEmpty && teacher.isEmpty
    }
    
    public func isLecture() -> Bool {
        type == "Лекции"
    }
    
    static func createEmptyLesson(withStartTime: String, andEndTime: String) -> LessonModel {
        return LessonModel(subjectName: "", timeStart: withStartTime, timeEnd: andEndTime, type: "", place: "", teacher: "")
    }
    
    static func createCorrectTimeTable(currentArray: [LessonModel]) -> [LessonModel] {
        var correctArray: [LessonModel] = []
        correctArray.append(currentArray[0])
        if (currentArray.count == 1) {
            return correctArray
        }
        for i in 1..<currentArray.count {
            let indexTwoDotPrev = currentArray[i - 1].timeStart.firstIndex(where: {$0 == ":"})
            let indexTwoDotNext = currentArray[i].timeStart.firstIndex(where: {$0 == ":"})
            let timePrev = currentArray[i - 1].timeStart
            let timeNext = currentArray[i].timeStart
            let intTimePrev = Int(timePrev[timePrev.startIndex..<indexTwoDotPrev!])
            let intTimeNext = Int(timeNext[timeNext.startIndex..<indexTwoDotNext!])
            if intTimeNext! - intTimePrev! > 2 {
                correctArray.append(createEmptyLesson(withStartTime: currentArray[i - 1].timeStart, andEndTime: currentArray[i].timeStart))
            }
            correctArray.append(currentArray[i])
        }
        return correctArray
    }
}
