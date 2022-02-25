//
//  InitUI.swift
//  PolyNaviTests
//
//  Created by Andrei Soprachev on 25.02.2022.
//

import XCTest
@testable import PolyNavi

class InitUI: XCTestCase {

    override func setUpWithError() throws {
        let timeTable = TimetableViewController(date: .now)
        let lesson = LessonCellView()
        let transition = BottomSheetTransition(operation: .pop, fromState: .big, size: .big, duration: 0.5, complition: { })
        
        let point = PointAnnotationView()
        point.setSelected(true, animated: true)
        point.setSelected(false, animated: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
}
