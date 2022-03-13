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
        TimetableViewController(date: .now)
        LessonCellView()
        BottomSheetTransition(operation: .pop, fromState: .big, size: .big, duration: 0.5, complition: { })
    }
    
    func testInitUI() throws {
    }
}
