//
//  Shared.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 20.01.2022.
//

import MapKit

class CustomOverlay: NSObject {
    var geometry: MKShape & MKOverlay
    
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
    
    init(_ geometry: MKShape & MKOverlay) {
        self.geometry = geometry
    }
    
    
}
