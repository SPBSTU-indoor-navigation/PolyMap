//
//  BuildingAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class AttractionAnnotation: NSObject, MKAnnotation, Identifiable {
    var identifier: String = identifier
    static var identifier: String = String(describing: AttractionAnnotation.self)
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? {
        return properties.name?.bestLocalizedValue
    }

    var properties: IMDF.Attraction.Properties
    
    init(coordinate: CLLocationCoordinate2D, properties: IMDF.Attraction.Properties) {
        self.coordinate = coordinate
        self.properties = properties
        super.init()
    }
}
