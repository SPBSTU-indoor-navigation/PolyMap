//
//  MapInfo.swift
//  PolyNaviTests
//
//  Created by Andrei Soprachev on 13.03.2022.
//

import XCTest
@testable import PolyNavi
import MapKit

class MapInfoTest: XCTestCase {
    
    var mapInfo: MapInfo!
    let annotationName = LocalizedName(localizations: ["RU": "TEST"])
    var occupantProp: IMDF.Occupant.Properties!

    override func setUpWithError() throws {
        let vc = UIViewController()
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        mapInfo = MapInfo(parentVC: vc, rootViewController: SearchVC())
        occupantProp = IMDF.Occupant.Properties(name: annotationName, shortName: annotationName, category: .classroom, anchor_id: .init(), hours: nil, phone: nil, email: nil, website: nil, correlation_id: nil)
    }

    func testSafeZone() throws {
        XCTAssertEqual(mapInfo.getSafeZone(), mapInfo.safeZone)
    }
    
    func testHorizontalSize() throws {
        XCTAssertEqual(mapInfo.getHorizontalSize(), mapInfo.horizontalSize())
    }
    
    func testZoomMap() {
        mapInfo.changeState(state: .medium)
        mapInfo.zoomMap(zoom: 5, animated: false)
        mapInfo.zoomMap(zoom: 6, animated: false)
        
        XCTAssertEqual(mapInfo.state, .small)
        
        
        mapInfo.changeState(state: .medium)
        mapInfo.parent?.view.frame = CGRect(x: 0, y: 0, width: 3000, height: 500)
        mapInfo.zoomMap(zoom: 5, animated: false)
        mapInfo.zoomMap(zoom: 6, animated: false)
        
        XCTAssertEqual(mapInfo.state, .medium)
    }
    
    func testSelectAnnotation() throws {
        let annotation = OccupantAnnotation(coordinate: .init(latitude: 100, longitude: 100), properties: occupantProp, address: nil)
        
        mapInfo.didSelect(annotation)
        
        XCTAssertEqual(mapInfo.pages.last, .annotationInfo)
        XCTAssertEqual(mapInfo.pages.count, 2)
    }
    
    func testSingleRoute() throws {
        let annotation = OccupantAnnotation(coordinate: .init(latitude: 100, longitude: 100), properties: occupantProp, address: nil)
        mapInfo.didSelect(annotation)
        
        let vc = mapInfo.getRouteVC()
        XCTAssertNotNil(vc)
        
        mapInfo.pushViewController(SearchVC(), animated: false)
        XCTAssertEqual(vc, mapInfo.getRouteVC())
    }
    
    func testAnnotationDeselect() {
        let annotation = OccupantAnnotation(coordinate: .init(latitude: 100, longitude: 100), properties: occupantProp, address: nil)
        
        mapInfo.didSelect(annotation)
        XCTAssertEqual(mapInfo.pages.count, 2)
        XCTAssertEqual(mapInfo.pages.last, .annotationInfo)
        
        mapInfo.annotationDeselect(annotation: annotation)
        XCTAssertEqual(mapInfo.pages.count, 1)
        XCTAssertEqual(mapInfo.pages.last, .search)
    }

    func testDidDeselect() {
        let annotation = OccupantAnnotation(coordinate: .init(latitude: 100, longitude: 100), properties: occupantProp, address: nil)
        
        let deselect = expectation(description: "Wait deselect")
        
        mapInfo.didSelect(annotation)
        mapInfo.didDeselect(annotation)
        
        XCTAssertEqual(mapInfo.pages.count, 2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            deselect.fulfill()
        })
        
        wait(for: [deselect], timeout: 1)
        
        XCTAssertEqual(mapInfo.pages.count, 1)
    }
    
    func testChangeSelected() {
        let annotation1 = OccupantAnnotation(coordinate: .init(latitude: 100, longitude: 100), properties: occupantProp, address: nil)
        let annotation2 = OccupantAnnotation(coordinate: .init(latitude: 100, longitude: 100), properties: occupantProp, address: nil)
        
        let deselect = expectation(description: "Wait deselect")
        
        mapInfo.didSelect(annotation1)
        mapInfo.didDeselect(annotation1)
        mapInfo.didSelect(annotation2)
        
        XCTAssertEqual(mapInfo.pages.count, 2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            deselect.fulfill()
        })
        
        wait(for: [deselect], timeout: 1)
        
        XCTAssertEqual(mapInfo.pages.count, 2)
        XCTAssertEqual(mapInfo.pages.last, .annotationInfo)
    }
    
    func testStateByPopup() {
        XCTAssertEqual(mapInfo.pages.last, .search)
        
        mapInfo.pushViewController(UnitDetailVC(), animated: false)
        XCTAssertEqual(mapInfo.pages.last, .annotationInfo)
        
        mapInfo.pushViewController(RouteDetailVC(), animated: false)
        XCTAssertEqual(mapInfo.pages.last, .route)
        
        mapInfo.pushViewController(UIViewController(), animated: false)
        XCTAssertEqual(mapInfo.pages.last, .unknown)
    }

}
