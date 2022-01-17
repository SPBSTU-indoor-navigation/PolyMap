//
//  EnviromentAmenityAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

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
