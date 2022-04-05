//
//  EnviromentAmenityAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class EnviromentAmenityAnnotation: BaseAnnotation, MKAnnotation, Identifiable, AmenityDetailLevel {
    var identifier: String = identifier
    static var identifier: String = String(describing: EnviromentAmenityAnnotation.self)
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? {
        get {
            return properties.alt_name?.bestLocalizedValue
        }
    }
    
    var properties: IMDF.EnviromentAmenity.Properties
    
    var detailLevel: AmenityAnnotation.DetailLevel
    
    init(coordinate: CLLocationCoordinate2D, imdfID: UUID, properties: IMDF.EnviromentAmenity.Properties, detailLevel: Int) {
        self.coordinate = coordinate
        self.properties = properties
        self.detailLevel = .init(rawValue: detailLevel)!
        super.init()
        self.imdfID = imdfID
    }
}
