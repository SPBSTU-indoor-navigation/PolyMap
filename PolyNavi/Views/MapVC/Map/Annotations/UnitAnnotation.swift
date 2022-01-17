//
//  UnitAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

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
