//
//  EnviromentUnit.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class EnviromentUnit: CustomOverlay, Styleble {
    var category: IMDF.EnviromentUnit.Category
    
    init(_ geometry: MKOverlay, category: IMDF.EnviromentUnit.Category) {
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
            renderer.lineWidth = 1
        }
        
        
    }
}

class EnviromentDetail: CustomOverlay, Styleble {
    var category: IMDF.EnviromentDetail.Category
    
    override var overlayRenderer: MKOverlayRenderer? {
        get {
            return MultiPolylineDetailRenderer(overlay: geometry)
        }
    }
    
    init(geometry: MKOverlay, category: IMDF.EnviromentDetail.Category) throws {
        if !(geometry is MKMultiPolyline) {
            throw NSError(domain: "geometry must be MKMultiPolyline", code: 0, userInfo: nil)
        }
        self.category = category
        super.init(geometry)
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        
        renderer.strokeColor = Asset.IMDFColors.Enviroment.crosswalk.color
        
        switch category {
        case .crosswalk:
            renderer.lineWidth = 7.3
        case .roadMarkingMain:
            renderer.lineWidth = 2.5
        case .parkingMarking:
            renderer.lineWidth = 2
        case .parkingBig:
            renderer.lineWidth = 5
        case .fenceMain:
            renderer.lineWidth = 3
            renderer.strokeColor = Asset.IMDFColors.Enviroment.fenceMain.color
            renderer.lineDashPattern = [1, 4]
        case .fenceHeigth:
            renderer.lineWidth = 2
            renderer.strokeColor = .white
            
//        default:
//            renderer.strokeColor = UIColor.red
        }
        
    }
}
