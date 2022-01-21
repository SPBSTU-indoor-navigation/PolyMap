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
            return shortName?.bestLocalizedValue
        }
    }
    
    var category: IMDF.EnviromentAmenity.Category
    
    var shortName: LocalizedName?
    var detail: Int = 0
    
    init(coordinate: CLLocationCoordinate2D, category: IMDF.EnviromentAmenity.Category, title: LocalizedName?, detailLevel: Int) {
        self.coordinate = coordinate
        self.category = category
        self.detail = detailLevel
        self.shortName = title
        super.init()
    }
    
    func detailLevel() -> Int {
        return detail
    }
}
