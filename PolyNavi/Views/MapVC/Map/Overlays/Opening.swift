//
//  Opening.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class Opening: CustomOverlay, Styleble {
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
            renderer.lineCap = .butt
        case .walkway:
            renderer.strokeColor = Asset.IMDFColors.Units.walkway.color
        case .restroom, .restroomFemale, .restroomMale:
            renderer.strokeColor = Asset.IMDFColors.Units.restroom.color
        default: renderer.strokeColor = Asset.IMDFColors.default.color
        }
        renderer.lineWidth = 4
    }
}
