//
//  PolyNaviTests.swift
//  PolyNaviTests
//
//  Created by Никита Фролов  on 24.02.2022.
//

import XCTest
@testable import PolyNavi

class PolyNaviTests: XCTestCase {
    
    var sut: TimetableProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = TimetableProvider()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        let promise = expectation(description: "Status code 200")
        var fact: Faculty?
        sut.loadFaculties { resp in
            switch resp {
            case .successWith(let data):
                if data.faculties.count == 0 { XCTFail("Count equal zero") }
                promise.fulfill()
            case .error:
                XCTFail("Failer = \(resp)")
            case .errorNoInternet:
                XCTFail("No internet")
            }
        }
        
        let loadGroup = expectation(description: "Status code 200")
        sut.loadGroups(faculty: Faculty(id: 0, name: "", abbr: "")) { resp in
            switch resp {
            case .successWith(let data):
                XCTFail("Invalid id")
            default:
                loadGroup.fulfill()
            }
        }
        
        wait(for: [promise, loadGroup], timeout: 5)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
