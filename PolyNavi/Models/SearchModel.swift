//
//  SearchModel.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 23.03.2022.
//

import MapKit

class SearchModel {
    var annotation: MKAnnotation
    var sprite: UIImage?
    var title: LocalizedName
    var subtitle: LocalizedName?
    
    init(annotation: MKAnnotation, title: LocalizedName, subtitle: LocalizedName? = nil, sprite: UIImage? = nil) {
        self.annotation = annotation
        self.title = title
        self.subtitle = subtitle
        self.sprite = sprite
    }
}

class SearchAttractionModel: SearchModel {
    var shortLabel: LocalizedName?
}

class SearchAmenityModel: SearchModel {
    var indoor: Bool
    
    init(annotation: MKAnnotation, indoor: Bool, title: LocalizedName, subtitle: LocalizedName? = nil, sprite: UIImage? = nil) {
        self.indoor = indoor
        super.init(annotation: annotation, title: title, subtitle: subtitle, sprite: sprite)
    }
}

class SearchOccupantModel: SearchModel { }
