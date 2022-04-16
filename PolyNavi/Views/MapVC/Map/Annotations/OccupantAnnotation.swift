//
//  OccupantAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class OccupantAnnotation: BaseAnnotation, MKAnnotation, Identifiable, IndoorAnnotation {
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
    var level: Level
    
    var building: Building { level.building }
    
    lazy var sprite: UIImage = {
        var imageName: String? = nil
        switch properties.category {
        case .classroom: imageName = "classroom"
        case .laboratory: imageName = "laboratorium"
        case .auditorium: imageName = "lecture"
        default: break
        }
        return UIImage(named: imageName ?? properties.category.rawValue) ?? Asset.Annotation.Amenity.default.image
    }()
    
    lazy var backgroundSpriteColor: UIColor = {
        var colorName: String
        switch properties.category {
        case .restroom, .restroomMale, .restroomFemale: colorName = "restroom"
        default: colorName = properties.category.rawValue
        }
        return UIColor(named: colorName + "-annotation") ?? .systemOrange
    }()
    
    var detailLevel: DetailLevel {
        switch properties.category {
        case .restroom, .restroomMale, .restroomFemale, .security: return .circleWithoutLabel
        case .administration, .wardrobe: return .circleWithoutLabel
        case .souvenirs, .foodserviceСoffee: return .circleWithoutLabel
        case .auditorium, .classroom: return .pointSecondary
        default: return .pointSecondary
        }
    }
    
    init(coordinate: CLLocationCoordinate2D, imdfID: UUID, properties: IMDF.Occupant.Properties, address: IMDF.Address?, level: Level) {
        self.coordinate = coordinate
        self.properties = properties
        self.address = address
        self.level = level
        super.init()
        self.imdfID = imdfID
    }
}

extension OccupantAnnotation: Searchable {
    var annotation: MKAnnotation { self }
    
    var annotationSprite: UIImage? { sprite }
    
    var mainTitle: String? {
        properties.name?.bestLocalizedValue
    }
    
    var place: String? {
        level.building?.properties.name?.bestLocalizedValue
    }
    
    var floor: String? { level.properties.name?.bestLocalizedValue }
    
    var searchTags: [String] { [] }
    

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
