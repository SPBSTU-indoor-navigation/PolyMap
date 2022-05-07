//
//  Level.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class Level: CustomOverlay, Styleble, MapRenderer {
    private var isShow = false
    var units: [Unit] = []
    var openings: [Opening] = []
    var amenitys: [AmenityAnnotation] = []
    var occupants: [OccupantAnnotation] = []
    var details: [Detail] = []
    var properties: IMDF.Level.Properties!
    
    var building: Building!
    
    var navPaths: [UUID:[PathOverlay]] = [:]
    
    var ordinal: Int { properties.ordinal }
    var shortName: LocalizedName? { properties.short_name }
    
    init(_ geometry: MKShape & MKOverlay, units: [Unit], openings: [Opening], properties: IMDF.Level.Properties, amenitys: [IMDF.Amenity], details: [Detail], occupants: [(IMDF.Occupant, IMDF.Anchor)], addresses: [IMDF.Address]) {
        super.init(geometry)
        self.properties = properties
        self.units = units
        self.openings = openings
        self.amenitys = amenitys.map({ AmenityAnnotation(coordinate: ($0.geometry.first as! MKPointAnnotation).coordinate,
                                                         imdfID: $0.identifier,
                                                         properties: $0.properties, detailLevel: $0.properties.detailLevel,
                                                         level: self) })
        self.details = details
        
        self.occupants = occupants.map({ occupant in
            OccupantAnnotation(coordinate: (occupant.1.geometry.first as! MKPointAnnotation).coordinate,
                               imdfID: occupant.0.identifier,
                               properties: occupant.0.properties,
                               address: addresses.first(where: { $0.identifier == occupant.1.properties.address_id }),
                               level: self)
        })
    
    }
    
    func addPath(_ mapView: MKMapView, path: [PathResultNode], id: UUID) {
        
        var splitByLevel: [[PathResultNode]] = []
        
        var currentPath: [PathResultNode] = [path[0]]
        for i in 1..<path.count {
            if path[i-1].level != path[i].level {
                
                let isUp = path[i-1].level!.ordinal < path[i].level!.ordinal
                
                if !isUp { currentPath.append(path[i]) }
                splitByLevel.append(currentPath)
                
                currentPath = []
                if isUp {
                    currentPath.append(path[i-1])
                }
                currentPath.append(path[i])
            } else {
                currentPath.append(path[i])
            }
        }
        
        splitByLevel.append(currentPath)
        
        splitByLevel = splitByLevel.filter({ $0.count >= 2 && $0[1].level == self })
        
        let overlays = splitByLevel.map({ PathOverlay(coordinates: $0.map({ $0.location }), count: $0.count) })
        navPaths[id] = overlays
        
        if isShow {
            for overlay in overlays {
                mapView.insertOverlay(overlay, above: geometry)
            }
        }
    }
    
    func removePath(_ mapView: MKMapView, id: UUID) {
        if let path = navPaths.removeValue(forKey: id), isShow {
            mapView.removeOverlays(path)
        }
    }
    
    func show(_ mapView: OverlayedMapView) {
        if isShow { return }
        mapView.addOverlays(units.filter({ $0.properties.category == .walkway }))
        mapView.addOverlays(units.filter({ $0.properties.category != .walkway }))
        mapView.addOverlays(openings)
        mapView.addOverlays(details)
        mapView.addOverlay(self)
        
        mapView.addAnnotations(occupants)
        mapView.addAnnotations(amenitys)
        isShow = true
        
        for paths in navPaths {
            mapView.addOverlays(paths.value)
        }
    }
    
    func hide(_ mapView: OverlayedMapView) {
        if !isShow { return }
        mapView.removeOverlays(units)
        mapView.removeOverlays(openings)
        mapView.removeOverlays(details)
        mapView.removeOverlay(self)
        
        mapView.removeAnnotations(occupants)
        mapView.removeAnnotations(amenitys)
        
        isShow = false
        
        for paths in navPaths {
            mapView.removeOverlays(paths.value)
        }
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        renderer.fillColor = .clear
        renderer.lineWidth = 2
        renderer.strokeColor = Asset.IMDFColors.levelLine.color
    }
}

