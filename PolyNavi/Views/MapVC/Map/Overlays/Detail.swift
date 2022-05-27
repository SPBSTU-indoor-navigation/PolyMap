//
//  EnviromentDetail.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 22.01.2022.
//

import MapKit

class Detail: CustomOverlay, Styleble {
    var category: IMDF.Detail.Category
    
    override var overlayRenderer: MKOverlayRenderer? {
        get {
            return MultiPolylineDetailRenderer(overlay: geometry)
        }
    }
    
    init(geometry: MKShape & MKOverlay, category: IMDF.Detail.Category) throws {
        if !(geometry is MKMultiPolyline) {
            throw NSError(domain: "geometry must be MKMultiPolyline", code: 0, userInfo: nil)
        }
        self.category = category
        super.init(geometry)
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        
        renderer.strokeColor = UIColor(named: category.rawValue) ?? Asset.IMDFColors.Enviroment.crosswalk.color
        
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
        case .fenceHeigth:
            renderer.lineWidth = 2
        case .steps:
            renderer.lineWidth = 1
        case .indoorSteps, .indoorStairs:
            renderer.lineWidth = 0.5
        case .stadionGrassMarking:
            renderer.lineWidth = 3
        case .treadmillMarking:
            renderer.lineWidth = 2
        }
        
    }
}
