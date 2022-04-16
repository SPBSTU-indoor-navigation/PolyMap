//
//  Opening.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class Opening: CustomOverlay, Styleble, StylebleMapSize {
    
    var unitCategory: IMDF.Unit.Category?
    
    init(geometry: MKShape & MKOverlay, unitCategory: IMDF.Unit.Category?) {
        super.init(geometry)
        self.unitCategory = unitCategory
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKPolylineRenderer else { return }
        switch unitCategory {
        case .stairs:
            renderer.strokeColor = Asset.IMDFColors.Units.stairs.color
        case .walkway:
            renderer.strokeColor = Asset.IMDFColors.Units.walkway.color
        case .restroom, .restroomFemale, .restroomMale:
            renderer.strokeColor = Asset.IMDFColors.Units.restroom.color
        default: renderer.strokeColor = Asset.IMDFColors.default.color
        }
        renderer.lineCap = .butt
        renderer.lineWidth = 2
    }
    
    
    func configurate(renderer: MKOverlayRenderer, mapSize: Float) {
        guard let renderer = renderer as? MKPolylineRenderer else { return }
        
        renderer.lineWidth = CGFloat(max(2, (mapSize - 20) * 1.5))
    }
}
