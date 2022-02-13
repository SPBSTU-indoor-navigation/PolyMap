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
        get {
            return localizedName?.bestLocalizedValue
        }
    }
    var subtitle: String?
    var image: String?
    var localizedName: LocalizedName?
    var localizedShort: LocalizedName?
    
    init(coordinate: CLLocationCoordinate2D, localizedName: LocalizedName?, localizedShort: LocalizedName?, image: String?) {
        self.coordinate = coordinate
        self.image = image
        self.localizedName = localizedName
        self.localizedShort = localizedShort
        super.init()
    }
}
