//
//  EnviromentUnit.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class EnviromentUnit: MKMultiPolygon, Styleble {
    var category: IMDF.EnviromentUnit.Category
    
    init(polygons: [MKPolygon], category: IMDF.EnviromentUnit.Category) {
        self.category = category
        super.init(polygons)
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKMultiPolygonRenderer else { return }
        
        renderer.fillColor = UIColor(named: category.rawValue) ?? Asset.IMDFColors.Enviroment.default.color
        renderer.strokeColor = renderer.fillColor
        renderer.lineWidth = 1
    }
}

class EnviromentUnitLine: MKPolyline, Styleble {
    var category: IMDF.EnviromentUnit.Category?
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKPolylineRenderer else { return }
        renderer.lineWidth = 2
        renderer.strokeColor = .systemGray4
    }
    
    static func create(polyline: MKPolyline, category: IMDF.EnviromentUnit.Category) -> EnviromentUnitLine {
        let res = EnviromentUnitLine(points: polyline.points(), count: polyline.pointCount)
        res.category = category
        return res
    }
}

class EnviromentDetail: MKMultiPolyline, Styleble {
    var category: IMDF.EnviromentDetail.Category?
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MultiPolylineDetailRenderer else { return }
        
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
        default:
            renderer.strokeColor = UIColor.red
        }
        
    }
    
    static func create(polylines: [MKPolyline], category: IMDF.EnviromentDetail.Category) -> EnviromentDetail {
        let res = EnviromentDetail(polylines)
        res.category = category
        return res
    }
}
