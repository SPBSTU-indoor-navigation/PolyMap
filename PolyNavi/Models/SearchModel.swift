//
//  SearchModel.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 23.03.2022.
//

import MapKit

protocol Searchable {
    var annotation: MKAnnotation { get }
    var annotationSprite: UIImage? { get }
    var backgroundSpriteColor: UIColor { get }
    
    var mainTitle: String? { get }
    var additionalTitle: String? { get }
    var place: String? { get }
    var floor: String? { get }
    
    var searchTags: [String] { get }
}

extension Searchable {
    var additionalTitle: String? { "" }
}

