//
//  Unit.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class Unit: CustomOverlay, Styleble, StylebleMapSize {

    var id: UUID
    var properties: IMDF.Unit.Properties
    
    var isHidden = false {
        didSet {
            overlayRenderer?.setNeedsDisplay()
        }
    }
    
    init(_ geometry: MKShape & MKOverlay,
         id: UUID,
         displayPoint: CLLocationCoordinate2D?,
         properties: IMDF.Unit.Properties) {
        
        self.id = id
        self.properties = properties
        super.init(geometry)
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        
        if isHidden {
            renderer.alpha = 0
            return
        }
        
        renderer.alpha = 1
        renderer.strokeColor = Asset.IMDFColors.Units.defaultLine.color
        renderer.fillColor = UIColor(named: properties.category.rawValue) ?? Asset.IMDFColors.default.color
        renderer.lineWidth = 1
        
        if properties.restriction == .employeesonly || properties.restriction == .restricted {
            renderer.fillColor = Asset.IMDFColors.Units.restricted.color
        } else {
            switch properties.category {
            case .restroom, .restroomFemale, .restroomMale:
                renderer.fillColor = Asset.IMDFColors.Units.restroom.color
            default: break
            }
            
            switch properties.category {
            default: break
            }
        }
    }
    
    func configurate(renderer: MKOverlayRenderer, mapSize: Float) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        
        if isHidden {
            renderer.alpha = 0
            return
        } else {
            renderer.alpha = 1
        }
        
        renderer.lineWidth = CGFloat(max(1, mapSize - 20))
    }
}
