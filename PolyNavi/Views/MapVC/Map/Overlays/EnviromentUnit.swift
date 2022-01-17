//
//  EnviromentUnit.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class EnviromentUnit: MKMultiPolygon, Styleble {
    var categoty: IMDF.EnviromentUnit.Category
    
    init(polygons: [MKPolygon], categoty: IMDF.EnviromentUnit.Category) {
        self.categoty = categoty
        super.init(polygons)
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKMultiPolygonRenderer else { return }
        
        renderer.fillColor = UIColor(named: categoty.rawValue) ?? Asset.IMDFColors.Enviroment.default.color
        renderer.strokeColor = renderer.fillColor
        renderer.lineWidth = 1
    }
    
}
