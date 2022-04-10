//
//  PolyNaviTestsTimeTable.swift
//  PolyNaviUITests
//
//  Created by Andrei Soprachev on 11.04.2022.
//

import XCTest

class PolyNaviTestsTimeTable: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launch()
        
        app.buttons["timetable"].tap()
        
        if app.cells["Институт"].exists {
            app.cells["Институт"].tap()
            app.cells["faculty1"].tap()
            app.navigationBars["Институт"].buttons["Настройки"].tap()
            app.cells["Группа"].tap()
            app.cells["/1"].tap()
            app.navigationBars["Группа"].buttons["Готово"].tap()
        }
        
        app.buttons["закрыть"].tap()
    }
    
    //   1. Открыть расписание, перейти в настройкам, выбрать институт и группу, вернуться к расписанию
    func testTimteTableOpenSettings() {
        app.buttons["timetable"].tap()
        
        app.buttons["settings"].tap()
        app.buttons["Группы"].tap()
        
        app.cells["Институт"].tap()
        app.cells["faculty2"].tap()
        app.cells["faculty1"].tap()
        
        app.navigationBars["Институт"].buttons["Настройки"].tap()
        
        app.cells["Группа"].tap()
        app.cells["/2"].tap()
        app.cells["/1"].tap()
        
        app.navigationBars["Группа"].buttons["Готово"].tap()
        XCTAssert(app.staticTexts["Расписание"].exists)
    }
    
    //   2. Открыть расписание, перейти в настройкам, выбрать перподавателя, вернуться к расписанию
    func testTimteTableOpenSettingsTeachers() {
        app.buttons["timetable"].tap()
        
        app.buttons["settings"].tap()
        app.buttons["Преподаватели"].tap()
        
        app.cells["Преподаватель"].tap()
        app.cells["Teacher2"].tap()
        app.cells["Teacher1"].tap()
        
        app.navigationBars["Преподаватель"].buttons["Готово"].tap()
        XCTAssert(app.staticTexts["Расписание"].exists)
    }
    
    //   3. Открыть расписание через кнопку на главной странице
    func testOpenTimeTable() {
        app.buttons["timetable"].tap()
        XCTAssert(app.staticTexts["Расписание"].exists)
    }
    
    //   4. Посмотреть прошлую неделю расписания
    func testTimeTableLastWeak() {
        app.buttons["timetable"].tap()
        XCTAssert(app.staticTexts["ttDay"].label.contains(dateLabel()))
        
        app.buttons["Назад"].tap()
        XCTAssert(app.staticTexts["ttDay"].label.contains(
            dateLabel(for: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!)
        ))
        
        app.buttons["закрыть"].tap()
    }
    
    //   5. Посмотреть следующую неделю расписания кнопкой
    func testTimeTableNextWeak() {
        app.buttons["timetable"].tap()
        XCTAssert(app.staticTexts["ttDay"].label.contains(dateLabel()))
        
        app.buttons["Вперед"].tap()
        XCTAssert(app.staticTexts["ttDay"].label.contains(
            dateLabel(for: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!)
        ))
        
        app.buttons["закрыть"].tap()
    }
    
    //   6. Посмотреть прошлую неделю расписания свайпом
    func testTimeTableLastWeakSwipe() {
        app.buttons["timetable"].tap()
        XCTAssert(app.staticTexts["ttDay"].label.contains(dateLabel()))
        app.scrollViews.firstMatch.swipeRight()
        
        XCTAssert(app.staticTexts["ttDay"].label.contains(
            dateLabel(for: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!)
        ))
        
        app.buttons["закрыть"].tap()
    }
    
    //  7. Посмотреть следующую неделю расписания свайпом
    func testTimeTableNextWeakSwipe() {
        app.buttons["timetable"].tap()
        XCTAssert(app.staticTexts["ttDay"].label.contains(dateLabel()))
        app.scrollViews.firstMatch.swipeLeft()
        XCTAssert(app.staticTexts["ttDay"].label.contains(
            dateLabel(for: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!)
        ))
        
        app.buttons["закрыть"].tap()
    }
    
    //  8. Кнопка "сегодня" в расписании переадресовывает на сегодня
    func testTimeTableToday() {
        
        app.buttons["timetable"].tap()
        app.scrollViews.firstMatch.swipeLeft()
        
        app.buttons["today"].tap()
        
        XCTAssert(app.staticTexts["ttDay"].label.contains(dateLabel()))
    }
    
    
    func dateLabel(for date: Date = Date()) -> String {
        let stringDateFormatter: DateFormatter = {
            $0.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMdd", options: 0, locale: Locale.current)!
            return $0
        }(DateFormatter())
        
        let cal = Calendar(identifier: .iso8601)
        let start = cal.date(from: cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)) ?? Date()
        
        return stringDateFormatter.string(from: start)
    }
    

}
