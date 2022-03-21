//
//  OccupantAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class OccupantAnnotation: NSObject, MKAnnotation, Identifiable {
    enum DetailLevel: Int {
        case circlePrimary = 0
        case circleSecondary = 1
        case circleWithoutLabel = 2
        case pointPrimary = 3
        case pointSecondary = 4
    }
    var identifier: String = identifier
    static var identifier: String = String(describing: OccupantAnnotation.self)
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? {
        return properties.shortName?.bestLocalizedValue
    }
    var properties: IMDF.Occupant.Properties
    var address: IMDF.Address?
    
    var detailLevel: DetailLevel {
        switch properties.category {
        case .restroom, .restroomMale, .restroomFemale, .security: return .circleWithoutLabel
        case .administration, .wardrobe: return .circleWithoutLabel
        case .souvenirs, .foodserviceСoffee: return .circleWithoutLabel
        case .auditorium, .classroom: return .pointSecondary
        default: return .pointSecondary
        }
    }
    
    init(coordinate: CLLocationCoordinate2D, properties: IMDF.Occupant.Properties, address: IMDF.Address?) {
        self.coordinate = coordinate
        self.properties = properties
        self.address = address
        super.init()
    }
}


extension OccupantAnnotation {
    static var levelProcessor: DetailLevelProcessor<DetailLevelState> = {
        $0.builder(for: DetailLevel.circleWithoutLabel.rawValue)
            .add(mapSize: 0, state: .min)
            .add(mapSize: 19, state: .normal)
            .add(mapSize: 21, state: .big)
        
        $0.builder(for: DetailLevel.pointPrimary.rawValue)
            .add(mapSize: 19.6, state: .min)
            .add(mapSize: 20.2, state: .normal)
            .add(mapSize: 21.5, state: .big)
        
        $0.builder(for: DetailLevel.pointSecondary.rawValue)
            .add(mapSize: 17.0, state: .hide)
            .add(mapSize: 19.6, state: .min)
            .add(mapSize: 20.2, state: .normal)
            .add(mapSize: 21.5, state: .big)
        return $0
    }(DetailLevelProcessor<DetailLevelState>())
}
