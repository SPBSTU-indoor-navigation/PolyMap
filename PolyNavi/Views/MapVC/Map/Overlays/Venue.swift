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
    
    var outdoorPath: [UUID:PathOverlay] = [:]
    var defaultPathStartPoint: MKAnnotation? = nil
    
    init(geometry: MKShape & MKOverlay, buildings: [Building], enviroments: [EnviromentUnit],
         enviromentDetail: [Detail], address: IMDF.Address?, amenitys: [IMDF.EnviromentAmenity]) {
        super.init(geometry)
        self.buildings = buildings
        self.address = address
        self.enviroments = enviroments
        self.enviromentDetail = enviromentDetail
        self.amenitys = amenitys.map({ EnviromentAmenityAnnotation(coordinate: ($0.geometry.first as! MKPointAnnotation).coordinate,
                                                                   imdfID: $0.identifier, properties: $0.properties,
                                                                   detailLevel: $0.properties.detailLevel)})
    }
    
    func addPath(_ mapView: MKMapView, path: [PathResultNode]) -> UUID {
        let id = UUID()
        let outdoor = path
        
        let overlay = PathOverlay(coordinates: outdoor.map({ $0.location }), count: outdoor.count)
        outdoorPath[id] = overlay
        
        for building in buildings {
            building.addPath(mapView, path: path, id: id)
        }

        mapView.insertOverlay(overlay, below: buildings[0].geometry)
        
        return id
    }
    
    func removePath(_ mapView: MKMapView, id: UUID) {
        if let path = outdoorPath.removeValue(forKey: id) {
            mapView.removeOverlay(path)
            
            for building in buildings {
                building.removePath(mapView, id: id)
            }
        }
    }
    
    func show(_ mapView: OverlayedMapView) {
        mapView.addOverlay(self)
        
        let enviromentOrder: [IMDF.EnviromentUnit.Category] = [.forest,
                                                               .grass,
                                                               .grassStadion,
                                                               .water,
                                                               .sand,
                                                               .tree,
                                                               .roadDirt,
                                                               .roadPedestrianSecond,
                                                               .roadPedestrianMain,
                                                               .roadPedestrianTreadmill,
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
    
    func hide(_ mapView: OverlayedMapView) {
        mapView.removeOverlay(self)
        mapView.removeOverlays(enviroments)
        mapView.removeOverlays(enviromentDetail)
        mapView.removeOverlays(buildings)
        mapView.removeAnnotations(amenitys)
        mapView.removeAnnotations(buildings.flatMap({ $0.attractions }))
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        renderer.strokeColor = Asset.IMDFColors.venueFill.color
        renderer.lineWidth = 5
        renderer.fillColor = Asset.IMDFColors.venueFill.color
    }
}
