//
//  RouteDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.03.2022.
//

import UIKit
import MapKit

class RouteDetailVC: NavbarBottomSheetPage {
    var mapViewDelegate: MapViewDelegate
    var from: MKAnnotation? = nil
    var to: MKAnnotation? = nil
    
    var pathID: UUID?
    
    init(closable: Bool = false, mapViewDelegate: MapViewDelegate) {
        self.mapViewDelegate = mapViewDelegate
        super.init(closable: closable)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setFrom(_ annotation: MKAnnotation) {
        
        if (from != nil) {
            setTo(annotation)
            return
        }
        
        if let from = from { mapViewDelegate.unpinAnnotation(from, animated: true) }
        mapViewDelegate.pinAnnotation(annotation, animated: true)
        
        from = annotation
        
        drawPath()
    }
    
    func setTo(_ annotation: MKAnnotation) {
        if let to = to { mapViewDelegate.unpinAnnotation(to, animated: true) }
        mapViewDelegate.pinAnnotation(annotation, animated: true)
        
        to = annotation
        
        drawPath()
    }
    
    func drawPath() {
        guard let from = from,
              let to = to else { return }

        if let pathID = pathID {
            mapViewDelegate.removePath(id: pathID)
        }
        
        pathID = mapViewDelegate.addPath(path: PathFinder.shared.findPath(from: from, to: to))
    }
    
    override func beforeClose() {
        super.beforeClose()
        
        DispatchQueue.main.async { [self] in
            [to, from].compactMap({ $0 }).forEach({
                mapViewDelegate.unpinAnnotation($0, animated: true)
            })
            
            if let pathID = pathID {
                mapViewDelegate.removePath(id: pathID)
            }
        }

        
        
    }
}
