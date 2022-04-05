//
//  Building.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class Building: CustomOverlay, Styleble, MapRenderer {
    var levels: [Level] = []
    var attractions: [AttractionAnnotation] = []
    var properties: IMDF.Building.Properties!
    
    var ordinal = -1
    private var isShow = false
    
    var rotation: CGFloat? {
        properties.rotation
    }
    
    init(_ geometry: MKShape & MKOverlay, levels: [Level], attractions: [IMDF.Attraction], properties: IMDF.Building.Properties) {
        super.init(geometry)
        
        self.levels = levels
        self.attractions = attractions.map({ AttractionAnnotation(coordinate: ($0.geometry.first as! MKPointAnnotation).coordinate,
                                                                  imdfID: $0.identifier,
                                                                  properties: $0.properties) })
        self.ordinal = levels.map({ $0.ordinal }).min() ?? -1
        self.properties = properties
        
        for level in levels {
            level.building = self
        }
    }
    
    
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        renderer.shouldRasterize = false
        renderer.strokeColor = Asset.IMDFColors.buildingLine.color
        renderer.lineWidth = isShow ? 0.001 : 1
        renderer.fillColor = (isShow && level(byOrdinal: ordinal) != nil) ? Asset.IMDFColors.buildingUnderLevel.color : Asset.IMDFColors.buildingFill.color
    }
    
    func changeOrdinal(_ ordinal: Int, _ mapView: OverlayedMapView) {
        if self.ordinal == ordinal { return }
        if isShow {
            hide(mapView)
            self.ordinal = ordinal
            show(mapView)
        } else {
            self.ordinal = ordinal
        }
        
    }
    
    func show(_ mapView: OverlayedMapView) {
        if isShow { return }
        isShow = true
        
        if let level = level(byOrdinal: ordinal) {
            level.show(mapView)
        }
        
        mapView.removeAnnotations(attractions)
        
    }
    
    func hide(_ mapView: OverlayedMapView) {
        if !isShow { return }
        isShow = false
        
        if let level = level(byOrdinal: ordinal) {
            level.hide(mapView)
        }
        
        mapView.addAnnotations(attractions)
        
    }
    
    
    private func level(byOrdinal: Int) -> Level? {
        return levels.first(where: { $0.ordinal == byOrdinal })
    }
    
}

