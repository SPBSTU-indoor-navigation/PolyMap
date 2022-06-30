//
//  EnviromentUnit.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class EnviromentUnit: CustomOverlay, Styleble {
    var category: IMDF.EnviromentUnit.Category
    
    init(_ geometry: MKShape & MKOverlay, category: IMDF.EnviromentUnit.Category) {
        self.category = category
        super.init(geometry)
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        
        if let renderer = renderer as? MKPolylineRenderer {
            renderer.lineWidth = 2
            renderer.strokeColor = .systemGray4
        }
        
        else if let renderer = renderer as? MKOverlayPathRenderer {
            renderer.fillColor = UIColor(named: category.rawValue) ?? Asset.IMDFColors.default.color
            renderer.strokeColor = renderer.fillColor
            renderer.lineWidth = 0.5
            renderer.shouldRasterize = true
        }
        
    }
}

