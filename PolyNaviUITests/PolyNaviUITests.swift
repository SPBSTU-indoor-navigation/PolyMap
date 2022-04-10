//
//  PolyNaviUITests.swift
//  PolyNaviUITests
//
//  Created by Andrei Soprachev on 10.04.2022.
//

import XCTest

class PolyNaviUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    // открыть боттон шит
    // в поиске найти 186а кабинет
    // нажать на него, чтоб посмотреть информацию о нем
    // проложить маршрут до него
    func testCabinetPath() throws {
        
        let mapInfo = app.otherElements["MapInfo"]
        mapInfo.swipeUp()
        mapInfo.swipeUp()
        
        let searchBar = mapInfo.otherElements["SearchBar"]
        searchBar.searchFields.element.tap()
        
        searchBar.typeText("186а")
        
        mapInfo.tables.cells.staticTexts["Кабинет 186а"].tap()
        
        app.buttons["route"].tap()
        
    }
}
