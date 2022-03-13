//
//  EnviromentAmenityAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class EnviromentAmenityAnnotation: NSObject, MKAnnotation, DetailLevel, Identifiable {
    var identifier: String = identifier
    static var identifier: String = String(describing: EnviromentAmenityAnnotation.self)
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? {
        get {
            return properties.alt_name?.bestLocalizedValue
        }
    }
    
    var properties: IMDF.EnviromentAmenity.Properties
    
    var detail: Int = 0
    
    init(coordinate: CLLocationCoordinate2D, properties: IMDF.EnviromentAmenity.Properties, detailLevel: Int) {
        self.coordinate = coordinate
        self.properties = properties
        self.detail = detailLevel
        super.init()
    }
    
    func detailLevel() -> Int {
        return detail
    }
}
