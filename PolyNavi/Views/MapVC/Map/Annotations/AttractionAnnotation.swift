//
//  BuildingAnnotation.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class AttractionAnnotation: BaseAnnotation, MKAnnotation, ReusableCell {
    var identifier: String = identifier
    static var identifier: String = String(describing: AttractionAnnotation.self)
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String? {
        return properties.name?.bestLocalizedValue
    }

    var properties: IMDF.Attraction.Properties
    
    init(coordinate: CLLocationCoordinate2D, imdfID: UUID, properties: IMDF.Attraction.Properties) {
        self.coordinate = coordinate
        self.properties = properties
        super.init()
        self.imdfID = imdfID
    }
    
    lazy var annotationSprite: UIImage? = {
        if let imageName = properties.image, let image = UIImage(named: imageName) {
            return image
        }
        return nil
    }()
}

extension AttractionAnnotation: Searchable {
    var annotation: MKAnnotation { self }
    
    var backgroundSpriteColor: UIColor { .clear }
    
    var mainTitle: String? { properties.name?.bestLocalizedValue }
    
    var place: String? { nil }
    
    var floor: String? { nil }
    
    var searchTags: [String] { [] }
    
    var additionalTitle: String? { properties.short_name?.bestLocalizedValue }
    
}
