//
//  ExtensionsTest.swift
//  PolyNaviTests
//
//  Created by Andrei Soprachev on 14.03.2022.
//

import XCTest
@testable import PolyNavi
import CoreLocation

class ExtensionsTest: XCTestCase {
    func testClamped() throws {
        XCTAssertEqual(10.clamped(0, 5), 5)
        XCTAssertEqual((-10).clamped(0, 5), 0)
        XCTAssertEqual(3.clamped(0, 5), 3)
    }
    
    func testShadowAdding() {
        let view = UIView()
        
        view.addShadow(shadowOpacity: 1)
        
        XCTAssertEqual(view.layer.shadowOffset, .zero)
        XCTAssertEqual(view.layer.shadowOpacity, 1)
        XCTAssertEqual(view.layer.shadowRadius, 5)
    }
    
    func testLocationDistance() {
        XCTAssertEqual(CLLocationCoordinate2D(latitude: 50, longitude: 50).distance(from: CLLocationCoordinate2D(latitude: 51, longitude: 51)), CLLocation(latitude: 50, longitude: 50).distance(from: CLLocation(latitude: 51, longitude: 51)), accuracy: 0.1)
    }
    
    func testUIScrollViewOffset() {
        let vc = UIViewController()
        let scroll = UIScrollView()
        
        vc.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        vc.additionalSafeAreaInsets = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        vc.view.addSubview(scroll)
        
        scroll.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        XCTAssertEqual(scroll.topOffset, 20) //тк там сейф ареа = 20
        
    }
    
    func testUIScrollTopContentOffsett() {
        let vc = UIViewController()
        let scroll = UIScrollView()
        
        vc.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        vc.additionalSafeAreaInsets = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        vc.view.addSubview(scroll)
        
        scroll.contentOffset = CGPoint(x: 0, y: 50)
        
        XCTAssertEqual(scroll.topContentOffset.y, 50 + 20)
        
    }

}
