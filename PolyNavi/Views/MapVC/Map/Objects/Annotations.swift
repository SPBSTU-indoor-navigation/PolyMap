//
//  Annotations.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.01.2022.
//

import MapKit

class UnitAnnotation: NSObject, MKAnnotation {
    public static var reusableIdentifier: String {
        return String(describing: self)
    }
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?) {
        self.coordinate = coordinate
        self.title = title
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

class AmenityAnnotation: NSObject, MKAnnotation {
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
    
    init(coordinate: CLLocationCoordinate2D, category: IMDF.Amenity.Category, title: LocalizedName?) {
        self.coordinate = coordinate
        self.category = category
        shortName = title
        super.init()
    }
}

class EnviromentAmenityAnnotation: NSObject, MKAnnotation {
    public static var reusableIdentifier: String {
        return String(describing: self)
    }
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? = ""
    var subtitle: String? = ""
    var category: IMDF.EnviromentAmenity.Category
    
    init(coordinate: CLLocationCoordinate2D, category: IMDF.EnviromentAmenity.Category) {
        self.coordinate = coordinate
        self.category = category
        super.init()
    }
}


