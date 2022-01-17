//
//  Opening.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class Opening: MKPolyline, Styleble {
    var unitCategory: IMDF.Unit.Category?
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKPolylineRenderer else { return }
        switch unitCategory {
        case .stairs:
            renderer.strokeColor = Asset.IMDFColors.Units.stairs.color
            renderer.lineCap = .butt
        case .restroom, .restroomFemale, .restroomMale:
            renderer.strokeColor = Asset.IMDFColors.Units.restroom.color
        default: renderer.strokeColor = Asset.IMDFColors.Units.default.color
        }
        renderer.lineWidth = 4
    }
}
