//
//  Opening.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class Opening: CustomOverlay, Styleble, StylebleMapSize {
    
    var unitCategory: IMDF.Unit.Category?
    var unitRestriction: Restriction?
    
    init(geometry: MKShape & MKOverlay, unitCategory: IMDF.Unit.Category?, unitRestriction: Restriction?) {
        super.init(geometry)
        self.unitCategory = unitCategory
        self.unitRestriction = unitRestriction
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKPolylineRenderer else { return }
        
        renderer.lineCap = .butt
        renderer.lineWidth = 2.25
        
        if unitRestriction == .restricted {
            renderer.strokeColor = Asset.IMDFColors.Units.restricted.color
            return
        }
        
        switch unitCategory {
        case .stairs:
            renderer.strokeColor = Asset.IMDFColors.Units.stairs.color
        case .walkway:
            renderer.strokeColor = Asset.IMDFColors.Units.walkway.color
        case .restroom, .restroomFemale, .restroomMale:
            renderer.strokeColor = Asset.IMDFColors.Units.restroom.color
        default: renderer.strokeColor = Asset.IMDFColors.default.color
        }
    }
    
    
    func configurate(renderer: MKOverlayRenderer, mapSize: Float) {
        guard let renderer = renderer as? MKPolylineRenderer else { return }
        
        renderer.lineWidth = CGFloat(max(2, (mapSize - 20) * 1.5))
    }
}
