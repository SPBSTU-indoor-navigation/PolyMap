//
//  LessonModel.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 05.10.2021.
//

import Foundation

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
