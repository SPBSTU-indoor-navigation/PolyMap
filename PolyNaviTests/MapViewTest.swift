//
//  MapViewTest.swift
//  PolyNaviTests
//
//  Created by Andrei Soprachev on 14.03.2022.
//

import XCTest
import MapKit
@testable import PolyNavi

class MapViewTest: XCTestCase, MapInfoDelegate {

    var mapView: MapView!
    
    override func setUpWithError() throws {
        mapView = MapView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        mapView.mapInfoDelegate = self
    }
    
    func testSelectAnnotationMoveMap() {
        let t = mapView.mapView(mapView.mapView, viewFor: mapView.mapView.annotations[1])!
        mapView.mapView(mapView.mapView, didSelect: t)
        
        XCTAssert(mapView.frame.contains(mapView.mapView.convert(mapView.mapView.centerCoordinate, toPointTo: mapView)))
    }
    
    func testFocusAnnotaion() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 50, longitude: 50)
        
        mapView.focus(on: annotation)
        
        XCTAssertEqual(mapView.mapView.convert(mapView.mapView.centerCoordinate, toPointTo: mapView), CGPoint(x: 250, y: 250))
    }
    
    func panAction(_ sender: UIPanGestureRecognizer) { }
    
    func zoomMap(zoom: Float, animated: Bool) { }
    
    func didSelect(_ annotation: MKAnnotation?) { }
    
    func didDeselect(_ annotation: MKAnnotation?) { }
    
    func getSafeZone() -> UIView {
        return UIView(frame: CGRect(x: 300, y: 0, width: 200, height: 200))
    }
    
    func getHorizontalSize() -> BottomSheetViewController.HorizontalSize {
        return .small
    }
}
