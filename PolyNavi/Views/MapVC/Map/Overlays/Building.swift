//
//  Building.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.01.2022.
//

import MapKit

class Building: MKMultiPolygon, Styleble, MapRenderer {
    var levels: [Level] = []
    var attractions: [AttractionAnnotation] = []
    
    
    var ordinal = -1
    private var isShow = false
    
    init(_ polygons: [MKPolygon], levels: [Level], attractions: [IMDF.Attraction] ) {
        super.init(polygons)
        self.levels = levels
        self.attractions = attractions.map({ AttractionAnnotation(coordinate: ($0.geometry.first as! MKPointAnnotation).coordinate, localizedName: $0.properties.alt_name, localizedShort: $0.properties.short_name, image: $0.properties.image) })
        self.ordinal = levels.map({ $0.ordinal }).min() ?? -1
    }
    
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKMultiPolygonRenderer else { return }
        renderer.shouldRasterize = false
        renderer.strokeColor = Asset.IMDFColors.buildingLine.color
        renderer.lineWidth = isShow ? 0.001 : 1
        renderer.fillColor = (isShow && level(byOrdinal: ordinal) != nil) ? Asset.IMDFColors.buildingUnderLevel.color : Asset.IMDFColors.buildingFill.color
    }
    
    func changeOrdinal(_ ordinal: Int, _ mapView: MKMapView) {
        if self.ordinal == ordinal { return }
        
        if isShow {
            hide(mapView)
            self.ordinal = ordinal
            show(mapView)
        } else {
            self.ordinal = ordinal
        }
        
    }
    
    func show(_ mapView: MKMapView) {
        if isShow { return }
        isShow = true
        
        if let level = level(byOrdinal: ordinal) {
            level.show(mapView)
        }
        
        mapView.removeAnnotations(attractions)
        
    }
    
    func hide(_ mapView: MKMapView) {
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

