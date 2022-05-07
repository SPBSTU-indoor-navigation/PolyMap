//
//  AmenityAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

protocol AmenityDetailLevel {
    var detailLevel: AmenityAnnotation.DetailLevel { get  }
}

class AmenityAnnotation: BaseAnnotation, MKAnnotation, ReusableCell, AmenityDetailLevel {
    enum DetailLevel: Int {
        case alwaysShowBig = 0
        case alwaysShow = 1
        case min = 2
        case hiddenMin = 3
        case alwaysShowMin = 4
    }
    
    var identifier: String = identifier
    static var identifier: String = String(describing: AmenityAnnotation.self)
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? {
        get {
            return properties.alt_name?.bestLocalizedValue
        }
    }
    
    lazy var sprite: UIImage = {
        return UIImage(named: properties.category.rawValue) ?? Asset.Annotation.Amenity.default.image
    }()
    
    var properties: IMDF.Amenity.Properties
    var detailLevel: DetailLevel
    var level: Level
    
    init(coordinate: CLLocationCoordinate2D, imdfID: UUID, properties: IMDF.Amenity.Properties, detailLevel: Int, level: Level) {
        self.coordinate = coordinate
        self.properties = properties
        self.detailLevel = .init(rawValue: detailLevel)!
        self.level = level
        super.init()
        self.imdfID = imdfID
    }
}

extension AmenityAnnotation: Searchable {
    var annotation: MKAnnotation { self }
    
    var annotationSprite: UIImage? { sprite }
    
    var backgroundSpriteColor: UIColor { .systemBlue }
    
    var mainTitle: String? {
        properties.alt_name?.bestLocalizedValue
    }
    
    var place: String? {
        level.building?.properties.name?.bestLocalizedValue
    }
    
    var floor: String? { level.properties.name?.bestLocalizedValue }
    
    var searchTags: [String] { [] }
}

extension AmenityAnnotation {
    
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
    
}
