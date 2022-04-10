//
//  PolyNaviUITestsFirstLaunch.swift
//  PolyNaviUITests
//
//  Created by Andrei Soprachev on 11.04.2022.
//

import XCTest

class PolyNaviUITestsFirstLaunch: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["UI-TESTING", "RESET-STORAGE"]
        app.launch()
    }
    
    //  9.Отурыть расписание в первый раз, выбрать источник, перейти к просмотру расписания
    func testTimteTableFirstOpen() {
        
        app.buttons["timetable"].tap()
        app.cells["Институт"].tap()
        app.cells["faculty1"].tap()
        
        app.navigationBars["Институт"].buttons["Настройки"].tap()
        
        app.cells["Группа"].tap()
        app.cells["/1"].tap()
        
        app.navigationBars["Группа"].buttons["Готово"].tap()
        
        XCTAssert(app.staticTexts["ttDay"].exists)
    }

}
