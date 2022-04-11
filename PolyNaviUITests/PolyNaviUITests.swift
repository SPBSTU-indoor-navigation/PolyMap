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
        app.launchArguments += ["UI-TESTING", "-AppleLanguages", "(ru)"]
        app.launch()
    }
    
//    1. Через поиск найти кабинет 186а, посмотреть о нём информацию и его расположение на карте, построить маршрут до него
    func testCabinetPath() {
        
        let mapInfo = app.otherElements["MapInfo"]
        mapInfo.swipeUp()
        mapInfo.swipeUp()
        
        let searchBar = mapInfo.otherElements["SearchBar"]
        searchBar.searchFields.element.tap()
        
        searchBar.typeText("186а")
        
        mapInfo.tables.cells.staticTexts["Кабинет 186а"].tap()
        
        app.buttons["route"].tap()
        
    }
    
//    2. На карте нажать на аннотацию ГЗ, посмотреть информацию о нём, построить маршрут до него
    func testAnnotationTapAndPath() {
        let map = app.otherElements["MapView"]
        
        map.otherElements["Главный учебный корпус"].forceTapElement()
        
        app.buttons["route"].tap()
    }
    
//    3. При просмотре планировки переключатель этажа должен переключать этаж
    func testLevelSwitcher() {
        let map = app.otherElements["MapView"]
        let mapInfo = app.otherElements["MapInfo"]
        
        let searchBar = mapInfo.otherElements["SearchBar"]
        searchBar.searchFields.element.tap()
        searchBar.typeText("183")
        mapInfo.tables.cells.staticTexts["Кабинет 183"].tap()
        
        XCTAssert(map.otherElements["183"].exists)
        XCTAssert(!map.otherElements["329"].exists)
        
        XCTAssert(app.otherElements["MapView"].staticTexts["1"].exists)
        XCTAssert(app.otherElements["MapView"].staticTexts["3"].exists)
        
        app.otherElements["MapView"].staticTexts["3"].tap()
        XCTAssert(!map.otherElements["183"].exists)
        XCTAssert(map.otherElements["329"].exists)
        
        app.otherElements["MapView"].staticTexts["1"].tap()
        XCTAssert(map.otherElements["183"].exists)
        XCTAssert(!map.otherElements["329"].exists)
    }
    
//    4. По нажанию на аннотацию кабинета, должна показываьтся планировка здания
    func testAnnotationZoom() {
        let map = app.otherElements["MapView"]
        let mapInfo = app.otherElements["MapInfo"]
        
        let searchBar = mapInfo.otherElements["SearchBar"]
        searchBar.searchFields.element.tap()
        searchBar.typeText("186а")
        mapInfo.tables.cells.staticTexts["Кабинет 186а"].tap()
        
        XCTAssert(!map.otherElements["Главный учебный корпус"].exists)
        XCTAssert(map.otherElements["186а"].exists)
        XCTAssert(map.otherElements["155"].exists)
    }
    
//   5. Ввести в поиск несуществующий кабинет и увидить строчку что ничего не найдено
    func testSearchEmpty() {
        let mapInfo = app.otherElements["MapInfo"]
        
        let searchBar = mapInfo.otherElements["SearchBar"]
        searchBar.searchFields.element.tap()
        
        searchBar.typeText("186")
        XCTAssert(!mapInfo.staticTexts["Ничего не найдено"].exists)
        
        searchBar.typeText("qwerty")
        XCTAssert(mapInfo.staticTexts["Ничего не найдено"].exists)
    }
    
    //   6. Проверить что окно поиска увеличивается свайпом
    func testMapInfoOpenSwipe() {
        let mapInfo = app.otherElements["MapInfo"]
        
        let startHeight = mapInfo.frame.height
        
        mapInfo.swipeUp()
        let mediumHeight = mapInfo.frame.height
        
        mapInfo.swipeUp()
        let endHeight = mapInfo.frame.height
        
        XCTAssertGreaterThan(mediumHeight, startHeight)
        XCTAssertGreaterThan(endHeight, mediumHeight)
    }
    
    //   7. Проверить что окно поиска умеьшается свайпом
    func testMapInfoCloseSwipe() {
        let mapInfo = app.otherElements["MapInfo"]
        mapInfo.swipeUp()
        mapInfo.swipeUp()
        
        let startHeight = mapInfo.frame.height
        
        mapInfo.swipeDown()
        let mediumHeight = mapInfo.frame.height
        
        mapInfo.swipeDown()
        let endHeight = mapInfo.frame.height
        
        XCTAssertLessThan(mediumHeight, startHeight)
        XCTAssertLessThan(endHeight, mediumHeight)
    }
    
    //   8. Проверить что окно поиска увеличивается по нажатию на строку поиска
    func testMapInfoOpenBySearch() {
        let mapInfo = app.otherElements["MapInfo"]
        
        let startHeight = mapInfo.frame.height
        mapInfo.otherElements["SearchBar"].searchFields.element.tap()
        let endHeight = mapInfo.frame.height
        
        XCTAssertGreaterThan(endHeight, startHeight)
    }
    
    //   9. Проверить что окно поиска становится меньше при нажатие на аннотацию в поиске
    func testMapInfoCollapsByTapSearchResult() {
        let mapInfo = app.otherElements["MapInfo"]
        
        let searchBar = mapInfo.otherElements["SearchBar"]
        searchBar.searchFields.element.tap()
        searchBar.typeText("183")
        
        let startHeight = mapInfo.frame.height
        mapInfo.tables.cells.staticTexts["Кабинет 183"].tap()
        let endHeight = mapInfo.frame.height
        
        XCTAssertLessThan(endHeight, startHeight)
    }
    
    //   10. Проверить что окно поиска при нажатие на "отменить" в поиске
    func testMapInfoCollapsByCancelSearch() {
        let mapInfo = app.otherElements["MapInfo"]
        
        let searchBar = mapInfo.otherElements["SearchBar"]
        searchBar.searchFields.element.tap()
        
        let startHeight = mapInfo.frame.height
        searchBar.staticTexts["Отменить"].tap()
        let endHeight = mapInfo.frame.height
        
        XCTAssertLessThan(endHeight, startHeight)
    }
}

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }
}
