//
//  Shared.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 20.01.2022.
//

import MapKit

class CustomOverlay: MKShape, MKOverlay {
    var geometry: MKOverlay
    
    var boundingMapRect: MKMapRect {
        get {
            return geometry.boundingMapRect
        }
    }
    
    var overlayRenderer: MKOverlayRenderer? { get { return nil } }
    
    var polygons: [MKPolygon]? {
        if let polygon = geometry as? MKPolygon {
            return [polygon]
        } else if let polygons = geometry as? MKMultiPolygon {
            return polygons.polygons
        }
        
        return nil
    }
    
    init(_ geometry: MKOverlay) {
        self.geometry = geometry
    }
    
    
}
