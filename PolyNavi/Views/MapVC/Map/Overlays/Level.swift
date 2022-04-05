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
    
    
    var ordinal: Int { properties.ordinal }
    var shortName: LocalizedName? { properties.short_name }
    
    init(_ geometry: MKShape & MKOverlay, units: [Unit], openings: [Opening], properties: IMDF.Level.Properties, amenitys: [IMDF.Amenity], details: [Detail], occupants: [(IMDF.Occupant, IMDF.Anchor)], addresses: [IMDF.Address]) {
        super.init(geometry)
        self.properties = properties
        self.units = units
        self.openings = openings
        self.amenitys = amenitys.map({ AmenityAnnotation(coordinate: ($0.geometry.first as! MKPointAnnotation).coordinate,
                                                         imdfID: $0.identifier,
                                                         properties: $0.properties, detailLevel: $0.properties.detailLevel) })
        self.details = details
        
        self.occupants = occupants.map({ occupant in
            OccupantAnnotation(coordinate: (occupant.1.geometry.first as! MKPointAnnotation).coordinate,
                               imdfID: occupant.0.identifier,
                               properties: occupant.0.properties,
                               address: addresses.first(where: { $0.identifier == occupant.1.properties.address_id }),
                               level: self)
        })
    
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
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        renderer.fillColor = .clear
        renderer.lineWidth = 2
        renderer.strokeColor = Asset.IMDFColors.levelLine.color
    }
}

