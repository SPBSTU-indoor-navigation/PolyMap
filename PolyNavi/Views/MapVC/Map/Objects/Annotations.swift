//
//  Annotations.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.01.2022.
//

import MapKit

protocol DetailLevel {
    func detailLevel() -> Int
}

class UnitAnnotation: NSObject, MKAnnotation {
    public static var reusableIdentifier: String {
        return String(describing: self)
    }
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var category: IMDF.Unit.Category
    
    init(coordinate: CLLocationCoordinate2D, title: String?, category: IMDF.Unit.Category) {
        self.coordinate = coordinate
        self.title = title
        self.category = category
        super.init()
    }
}


class BuildingAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
}

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

class EnviromentAmenityAnnotation: NSObject, MKAnnotation, DetailLevel {
    public static var reusableIdentifier: String {
        return String(describing: self)
    }
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? = ""
    var subtitle: String? = ""
    var category: IMDF.EnviromentAmenity.Category
    var detail: Int = 0
    
    init(coordinate: CLLocationCoordinate2D, category: IMDF.EnviromentAmenity.Category, detailLevel: Int) {
        self.coordinate = coordinate
        self.category = category
        self.detail = detailLevel
        super.init()
    }
    
    func detailLevel() -> Int {
        return detail
    }
}


