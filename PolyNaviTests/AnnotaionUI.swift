//
//  AnnotaionUI.swift
//  PolyNaviTests
//
//  Created by Andrei Soprachev on 13.03.2022.
//

import XCTest
@testable import PolyNavi
import CoreLocation
import MapKit

class AnnotaionUI: XCTestCase {
    
    var point: PointAnnotationView!
    var amenity: AmenityAnnotationView!
    var attraction: AttractionAnnotationView!
    
    var annotationName: LocalizedName!
    var coord: CLLocationCoordinate2D!
    var occupantProp: IMDF.Occupant.Properties!
    var amenityProp: IMDF.Amenity.Properties!
    var attractionProp: IMDF.Attraction.Properties!
    
    override func setUpWithError() throws {
        point = PointAnnotationView()
        amenity = AmenityAnnotationView()
        attraction = AttractionAnnotationView()
        
        annotationName = LocalizedName(localizations: ["RU": "TEST"])
        coord = CLLocationCoordinate2D(latitude: 100, longitude: 100)
        occupantProp = IMDF.Occupant.Properties(name: annotationName, shortName: annotationName, category: .classroom, anchor_id: .init(), hours: nil, phone: nil, email: nil, website: nil, correlation_id: nil)
        amenityProp = IMDF.Amenity.Properties(name: annotationName, alt_name: annotationName, unit_ids: [], category: .elevator, detailLevel: 1, hours: nil, phone: nil, website: nil, address_id: nil)
        attractionProp = IMDF.Attraction.Properties(name: annotationName, alt_name: annotationName, short_name: annotationName, building_id: .init(), category: .building, image: nil)
    }
    
    func testSelect() throws {
        for annotation: MKAnnotationView in [point, amenity, attraction] {
            annotation.setSelected(true, animated: false)
            XCTAssertEqual(annotation.isSelected, true)
            
            annotation.setSelected(false, animated: false)
            XCTAssertEqual(annotation.isSelected, false)
        }
    }
    
    func testSetPointAnnotation() throws {
        let annotation = OccupantAnnotation(coordinate: coord, properties: occupantProp, address: nil)
        point.annotation = annotation
        
        XCTAssertNotNil(point.annotation)
        XCTAssertEqual(point.annotation!.coordinate.latitude, coord.latitude)
        XCTAssertEqual(point.annotation!.coordinate.longitude, coord.longitude)
        XCTAssertEqual(point.label.text, annotation.title)
    }
    
    func testSetAmenityAnnotation() throws {
        let annotation = AmenityAnnotation(coordinate: coord, properties: amenityProp, detailLevel: 1)
        amenity.annotation = annotation
        
        XCTAssertNotNil(amenity.annotation)
        XCTAssertEqual(amenity.annotation!.coordinate.latitude, coord.latitude)
        XCTAssertEqual(amenity.annotation!.coordinate.longitude, coord.longitude)
        XCTAssertEqual(amenity.label.text, annotation.title)
    }
    
    func testSetAttractionAnnotation() throws {
        let annotation = AttractionAnnotation(coordinate: coord, properties: attractionProp)
        attraction.annotation = annotation
        
        XCTAssertNotNil(attraction.annotation)
        XCTAssertEqual(attraction.annotation!.coordinate.latitude, coord.latitude)
        XCTAssertEqual(attraction.annotation!.coordinate.longitude, coord.longitude)
        XCTAssertEqual(attraction.label.text, annotation.title)
    }
    
    func testImageVariant() {
        let annotation = OccupantAnnotation(coordinate: coord, properties: occupantProp, address: nil)

        point.annotation = annotation
        XCTAssertEqual(point.imageView.sourceImage, UIImage(named: "classroom"))
        
        point.annotation = annotation.withCategoty(category: .auditorium)
        XCTAssertEqual(point.imageView.sourceImage, UIImage(named: "lecture"))
        
        point.annotation = annotation.withCategoty(category: .laboratory)
        XCTAssertEqual(point.imageView.sourceImage, UIImage(named: "laboratorium"))
        
        point.annotation = annotation.withCategoty(category: .restroomMale)
        XCTAssertEqual(point.imageView.sourceImage, UIImage(named: "restroom.male"))
    }
    
    func testState() {
        let annotation = OccupantAnnotation(coordinate: coord, properties: occupantProp, address: nil)
        
        point.annotation = annotation
        
        for anim in [true, false] {
            for state: DetailLevelState in [.big, .normal, .hide, .min] {
                point.changeState(state: state, animate: anim)
                
                XCTAssertEqual(point.point.transform, CGAffineTransform(scaleX: point.pointSize, y: point.pointSize))
                XCTAssertEqual(point.label.transform, point.labelTransform)
                XCTAssertEqual(point.label.alpha, point.labelOpacity)
            }
        }
    }
    
    func testUpdateMapSize() {
        let annotation = OccupantAnnotation(coordinate: coord, properties: occupantProp, address: nil)
        point.annotation = annotation
        
        for size: Float in [10.0, 20.0, 50.0] {
            point.update(mapSize: size, animate: false)
            XCTAssertEqual(point.state, OccupantAnnotation.levelProcessor.evaluate(forDetailLevel: annotation.detailLevel.rawValue, mapSize: size) ?? .normal)
        }
    }
}

fileprivate extension IMDF.Occupant.Properties {
    func withCategoty(category: IMDF.Occupant.Category ) -> IMDF.Occupant.Properties {
        return IMDF.Occupant.Properties(name: self.name, shortName: self.shortName, category: category, anchor_id: self.anchor_id, hours: self.hours, phone: self.phone, email: self.email, website: self.website, correlation_id: self.correlation_id)
    }
}

fileprivate extension OccupantAnnotation {
    func withCategoty(category: IMDF.Occupant.Category ) -> OccupantAnnotation {
        
        self.properties = self.properties.withCategoty(category: category)
        
        return self
    }
}
