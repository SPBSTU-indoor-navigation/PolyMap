//
//  AmenityAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class AmenityAnnotation: NSObject, MKAnnotation, DetailLevel {
    public static var reusableIdentifier: String {
        return String(describing: self)
    }
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? {
        get {
            return shortName?.bestLocalizedValue
        }
    }
    var subtitle: String? = ""
    var category: IMDF.Amenity.Category
    
    var shortName: LocalizedName?
    var detail: Int = 0
    
    init(coordinate: CLLocationCoordinate2D, category: IMDF.Amenity.Category, title: LocalizedName?, detailLevel: Int) {
        self.coordinate = coordinate
        self.category = category
        shortName = title
        detail = detailLevel
        super.init()
    }
    
    func detailLevel() -> Int {
        return detail
    }
}
