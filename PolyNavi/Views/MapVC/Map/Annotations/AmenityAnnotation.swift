//
//  AmenityAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class AmenityAnnotation: NSObject, MKAnnotation, DetailLevel, Identifiable {
    enum DetailLevel: Int {
        case alwaysShowBig = 0
        case alwaysShow = 1
        case min = 2
        case hiddenMin = 3
        case alwaysShowMin = 4
    }
    
    static var levelProcessor: DetailLevelProcessor<DetailLevelState> = {
        
        $0.builder(for: DetailLevel.alwaysShowBig.rawValue)
            .add(mapSize: 0, state: .normal)
            .add(mapSize: 17, state: .big)
        
        $0.builder(for: DetailLevel.alwaysShow.rawValue)
            .add(mapSize: 10, state: .hide)
            .add(mapSize: 16, state: .min)
            .add(mapSize: 18.5, state: .big)
        
        $0.builder(for: DetailLevel.min.rawValue)
            .add(mapSize: 0, state: .hide)
            .add(mapSize: 17, state: .min)
            .add(mapSize: 18.5, state: .normal)
            .add(mapSize: 21, state: .big)
        
        $0.builder(for: DetailLevel.hiddenMin.rawValue)
            .add(mapSize: 0, state: .hide)
            .add(mapSize: 19.5, state: .min)
            .add(mapSize: 21.0, state: .normal)
            .add(mapSize: 22, state: .big)
        
        $0.builder(for: DetailLevel.alwaysShowMin.rawValue)
            .add(mapSize: 0, state: .normal)
            .add(mapSize: 22, state: .big)
        
        return $0
    }(DetailLevelProcessor<DetailLevelState>())
    
    var identifier: String = identifier
    static var identifier: String = String(describing: AmenityAnnotation.self)
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? {
        get {
            return shortName?.bestLocalizedValue
        }
    }
    
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
