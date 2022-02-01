//
//  Objects.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 06.01.2022.
//

import MapKit

class Venue: CustomOverlay, Styleble {
    
    var buildings: [Building] = []
    var enviroments: [EnviromentUnit] = []
    var enviromentDetail: [Detail] = []
    var amenitys: [EnviromentAmenityAnnotation] = []
    var address: IMDF.Address?
    
    init(geometry: MKShape & MKOverlay, buildings: [Building], enviroments: [EnviromentUnit],
         enviromentDetail: [Detail], address: IMDF.Address?, amenitys: [IMDF.EnviromentAmenity]) {
        super.init(geometry)
        self.buildings = buildings
        self.address = address
        self.enviroments = enviroments
        self.enviromentDetail = enviromentDetail
        self.amenitys = amenitys.map({ EnviromentAmenityAnnotation(coordinate: ($0.geometry.first as! MKPointAnnotation).coordinate, category: $0.properties.category, title: $0.properties.alt_name, detailLevel: $0.properties.detailLevel) })
    }
    
    func show(_ mapView: OverlayedMapView) {
        mapView.addOverlay(self)
        
        let enviromentOrder: [IMDF.EnviromentUnit.Category] = [.forest,
                                                               .grass,
                                                               .tree,
                                                               .roadDirt,
                                                               .roadPedestrianSecond,
                                                               .roadPedestrianMain,
                                                               .roadMain,
                                                               .fenceMain,
                                                               .fenceSecond]
        
        for i in enviromentOrder {
            mapView.addOverlays(enviroments.filter({ $0.category == i }))
        }
        
        mapView.addOverlays(enviroments.filter({ !enviromentOrder.contains($0.category)}))
        mapView.addOverlays(enviromentDetail)
        mapView.addOverlays(buildings)
        mapView.addAnnotations(amenitys)
        mapView.addAnnotations(buildings.flatMap({ $0.attractions }))
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        renderer.strokeColor = Asset.IMDFColors.venueFill.color
        renderer.lineWidth = 5
        renderer.fillColor = Asset.IMDFColors.venueFill.color
    }
}
