//
//  IMDFMapIntegration.swift
//  TimeTableItegration
//
//  Created by Andrei Soprachev on 09.04.2022.
//

import XCTest
@testable import PolyNavi

class CustomDecoder: IMDFDecoder {
    func decode(_ path: URL) -> Venue? {
        return nil
    }
}

class IMDFMapIntegration: XCTestCase {
    var vc: MapViewController!
    
    override func setUpWithError() throws {
        vc = MapViewController()
    }

    func testExample() throws {
        
    }
}
