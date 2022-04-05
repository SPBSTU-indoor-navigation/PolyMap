//
//  PathOverlay.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 05.04.2022.
//

import MapKit

class PathOverlay: MKPolyline, Styleble {
    func configurate(renderer: MKOverlayRenderer) {
        guard let renderer = renderer as? MKOverlayPathRenderer else { return }
        renderer.strokeColor = .systemBlue
        renderer.lineCap = .round
        renderer.lineJoin = .bevel
        renderer.lineWidth = 10
    }
    
    
}
