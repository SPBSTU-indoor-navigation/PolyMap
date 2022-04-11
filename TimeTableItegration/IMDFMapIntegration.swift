//
//  IMDFMapIntegration.swift
//  TimeTableItegration
//
//  Created by Andrei Soprachev on 09.04.2022.
//

import XCTest
@testable import PolyNavi
import MapKit

class CustomDecoder: IMDFDecoder {
    
    let venue: Venue?
    
    init(venue: Venue?) {
        self.venue = venue
    }
    
    func decode(_ path: URL) -> Venue? {
        return venue
    }
}

class IMDFMapIntegration: XCTestCase {
    var vc: MapViewController!
    
    let points: [CLLocationCoordinate2D] = [
        .init(latitude: 60, longitude: 30),
        .init(latitude: 60, longitude: 31),
        .init(latitude: 61, longitude: 31),
        .init(latitude: 61, longitude: 30),
        .init(latitude: 60, longitude: 30)
    ]
    
    override func setUpWithError() throws {
        vc = MapViewController()
    }

    func testShowMKPolygon() throws {
        let polygon = MKPolygon(coordinates: points, count: points.count)
        let decoder = CustomDecoder(venue: Venue(geometry: polygon, buildings: [], enviroments: [], enviromentDetail: [], address: nil, amenitys: []))
        
        vc.decoder = decoder
        vc.loadIMDF()
        
        let overlays = vc.mapView.mapView.overlays
        XCTAssertEqual(overlays.count, 1)
        XCTAssert(overlays[0] is MKPolygon)
    }
    
    func testShowMKPoliline() throws {
        let polyline = MKPolyline(coordinates: points, count: points.count)
        let decoder = CustomDecoder(venue: Venue(geometry: polyline, buildings: [], enviroments: [], enviromentDetail: [], address: nil, amenitys: []))
        
        vc.decoder = decoder
        vc.loadIMDF()
        
        let overlays = vc.mapView.mapView.overlays
        XCTAssertEqual(overlays.count, 1)
        XCTAssert(overlays[0] is MKPolyline)
    }
    
    func testShowMKMultiPoliline() throws {
        let polylines = MKMultiPolyline([
            MKPolyline(coordinates: points, count: points.count),
            MKPolyline(coordinates: points, count: points.count)
        ])
        let decoder = CustomDecoder(venue: Venue(geometry: polylines, buildings: [], enviroments: [], enviromentDetail: [], address: nil, amenitys: []))
        
        vc.decoder = decoder
        vc.loadIMDF()
        
        let overlays = vc.mapView.mapView.overlays
        XCTAssertEqual(overlays.count, 1)
        XCTAssert(overlays[0] is MKMultiPolyline)
    }
    
    func testShowMKMultiPolygon() throws {
        let multiPolygon = MKMultiPolygon([
            MKPolygon(coordinates: points, count: points.count),
            MKPolygon(coordinates: points, count: points.count)
        ])
        
        let decoder = CustomDecoder(venue: Venue(geometry: multiPolygon, buildings: [], enviroments: [], enviromentDetail: [], address: nil, amenitys: []))
        
        vc.decoder = decoder
        vc.loadIMDF()
        
        let overlays = vc.mapView.mapView.overlays
        XCTAssertEqual(overlays.count, 1)
        XCTAssert(overlays[0] is MKMultiPolygon)
    }
    
    func testShowMultipleGeometry() throws {
        let multiPolygon = MKMultiPolygon([
            MKPolygon(coordinates: points, count: points.count),
            MKPolygon(coordinates: points, count: points.count)
        ])
        
        let polylines = MKMultiPolyline([
            MKPolyline(coordinates: points, count: points.count),
            MKPolyline(coordinates: points, count: points.count)
        ])
        
        let polygon = MKPolygon(coordinates: points, count: points.count)
        
        let prop = IMDF.Building.Properties(name: nil, alt_name: nil, category: "", restriction: nil, address_id: nil, rotation: nil, display_point: nil)
        
        let decoder = CustomDecoder(venue: Venue(geometry: multiPolygon, buildings: [
            Building(multiPolygon, levels: [], attractions: [], properties: prop),
            Building(polylines, levels: [], attractions: [], properties: prop),
            Building(polygon, levels: [], attractions: [], properties: prop)
        ], enviroments: [], enviromentDetail: [], address: nil, amenitys: []))
        
        vc.decoder = decoder
        vc.loadIMDF()
        
        let overlays = vc.mapView.mapView.overlays
        XCTAssertEqual(overlays.count, 3)
        XCTAssert(!overlays.filter({ $0 is MKPolygon}).isEmpty)
        XCTAssert(!overlays.filter({ $0 is MKMultiPolyline}).isEmpty)
        XCTAssert(!overlays.filter({ $0 is MKMultiPolygon}).isEmpty)
    }
}
