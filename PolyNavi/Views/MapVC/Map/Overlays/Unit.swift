//
//  Unit.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class Unit: CustomOverlay, Styleble {
    
    var annotation: UnitAnnotation? = nil
    var id: UUID
    var categoty: IMDF.Unit.Category
    var restriction: Restriction?
    
    init(_ geometry: MKShape & MKOverlay,
         id: UUID,
         displayPoint: CLLocationCoordinate2D?,
         name: LocalizedName?,
         altName: LocalizedName?,
         categoty: IMDF.Unit.Category,
         restriction: Restriction?) {
        
        self.id = id
        self.categoty = categoty
        self.restriction = restriction
        
        if let displayPoint = displayPoint, let altName = altName {
            annotation = UnitAnnotation(coordinate: displayPoint, title: altName.bestLocalizedValue, category: self.categoty)
        }
        
        super.init(geometry)
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        
        renderer.strokeColor = Asset.IMDFColors.Units.defaultLine.color
        renderer.lineWidth = 1
        
        if restriction == .employeesonly || restriction == .restricted {
            renderer.fillColor = Asset.IMDFColors.Units.restricted.color
        } else {
            switch categoty {
            case .restroom, .restroomFemale, .restroomMale:
                renderer.fillColor = Asset.IMDFColors.Units.restroom.color
            default:
                renderer.fillColor = UIColor(named: categoty.rawValue) ?? Asset.IMDFColors.default.color
            }
            
            switch categoty {
                //        case .stairs:
                //            renderer.strokeColor = Asset.IMDFColors.Units.defaultLine.color.withAlphaComponent(0.5)
            default: break
            }
        }
        
        
        
    }
}

