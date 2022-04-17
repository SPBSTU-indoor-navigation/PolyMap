//
//  PathMapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 05.04.2022.
//

import Foundation

class PathMapView: OverlayedMapView {
    private var paths: [UUID:PathOverlay] = [:]
    
    func addPath(path: [PathResultNode]) -> UUID {
        let id = UUID()
        
        let path = PathOverlay(coordinates: path.map({ $0.location }), count: path.count)
        paths[id] = path
        addOverlay(path)
        
        return id
    }
    
    func removePath(id: UUID){
        guard let path = paths.removeValue(forKey: id) else { return }
        removeOverlay(path)
    }
}
