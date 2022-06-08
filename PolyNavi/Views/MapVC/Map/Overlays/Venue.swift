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
    
    var outdoorPath: [UUID:[PathOverlay]] = [:]
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
        
        var outdoor: [[PathResultNode]] = []
        
        var temp: [PathResultNode] = path[0].isIndoor ? [] : [path[0]]
        for i in 1..<path.count-1 {
            if path[i-1].isIndoor && path[i].isIndoor && path[i+1].isIndoor {
                if temp.count > 0 {
                    outdoor.append(temp)
                }
                temp = []
            } else {
                temp.append(path[i])
            }
        }
        
        if path.count >= 2 {
            if !(path[path.count-2].isIndoor && path[path.count-1].isIndoor) {
                temp.append(path[path.count-1])
                outdoor.append(temp)
            }
        }
        
        
        let overlays = outdoor.map({
            PathOverlay(coordinates: $0.map({ $0.location }), count: $0.count)
        })
        
        outdoorPath[id] = overlays
        
        for overlay in overlays {
            mapView.insertOverlay(overlay, below: buildings[0].geometry)
        }
        
        for building in buildings {
            building.addPath(mapView, path: path, id: id)
        }

        
        return id
    }
    
    func removePath(_ mapView: MKMapView, id: UUID) {
        if let path = outdoorPath.removeValue(forKey: id) {
            mapView.removeOverlays(path)
            
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
