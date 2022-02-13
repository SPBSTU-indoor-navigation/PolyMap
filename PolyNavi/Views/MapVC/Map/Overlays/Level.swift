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
    var details: [Detail] = []
    var ordinal: Int = 0
    var shortName: LocalizedName?
    
    init(_ geometry: MKShape & MKOverlay, ordinal: Int, units: [Unit], openings: [Opening], shortName: LocalizedName?, amenitys: [IMDF.Amenity], details: [Detail] ) {
        super.init(geometry)
        self.ordinal = ordinal
        self.units = units
        self.openings = openings
        self.shortName = shortName
        self.amenitys = amenitys.map({ AmenityAnnotation(coordinate: ($0.geometry.first as! MKPointAnnotation).coordinate, category: $0.properties.category, title: $0.properties.alt_name, detailLevel: $0.properties.detailLevel) })
        self.details = details
        
        let amenityUnits = amenitys.flatMap({ $0.properties.unit_ids })
        
        for unit in self.units {
            if amenityUnits.contains(unit.id) {
                unit.annotation = nil
            }
        }
    }
    
    func show(_ mapView: OverlayedMapView) {
        if isShow { return }
        mapView.addOverlays(units.filter({ $0.categoty == .walkway }))
        mapView.addOverlays(units.filter({ $0.categoty != .walkway }))
        mapView.addOverlays(openings)
        mapView.addOverlays(details)
        mapView.addOverlay(self)
        
        mapView.addAnnotations(units.compactMap{ $0.annotation })
        mapView.addAnnotations(amenitys)
        isShow = true
    }
    
    func hide(_ mapView: OverlayedMapView) {
        if !isShow { return }
        mapView.removeOverlays(units)
        mapView.removeOverlays(openings)
        mapView.removeOverlays(details)
        mapView.removeOverlay(self)
        
        mapView.removeAnnotations(units.compactMap({ $0.annotation }))
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
