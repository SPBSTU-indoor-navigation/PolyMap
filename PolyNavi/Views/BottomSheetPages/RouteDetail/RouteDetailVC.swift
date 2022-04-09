//
//  RouteDetailVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 08.03.2022.
//

import UIKit
import MapKit

class RouteDetailVC: NavbarBottomSheetPage {
    static var toPoint: MKAnnotation?
    static var fromPoint: MKAnnotation?
    
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
        if let from = RouteDetailVC.fromPoint { mapViewDelegate.unpinAnnotation(from, animated: true) }
        mapViewDelegate.pinAnnotation(annotation, animated: true)

        from = annotation
        
        drawPath()
    }
    
    func setTo(_ annotation: MKAnnotation) {
        if let to = RouteDetailVC.toPoint { mapViewDelegate.unpinAnnotation(to, animated: true) }
        
        self.mapViewDelegate.pinAnnotation(annotation, animated: true)
        self.mapViewDelegate.deselectAnnotation(annotation, animated: true)
        
        
        to = annotation
        
        drawPath()
    }
    
    func drawPath() {
        guard let from = from ?? IMDFDecoder.defaultPathStartPoint,
              let to = to else { return }
        
        RouteDetailVC.fromPoint = from
        RouteDetailVC.toPoint = to
        
        if let pathID = pathID {
            mapViewDelegate.removePath(id: pathID)
        }
        
        [to, from].forEach({
            mapViewDelegate.pinAnnotation($0, animated: true)
        })
        
        let result = PathFinder.shared.findPath(from: from, to: to)
        
        if let result = result {
            pathID = mapViewDelegate.addPath(path: result.path)
        } else {
            pathID = nil
        }
    }
    
    override func beforeClose() {
        super.beforeClose()
        RouteDetailVC.toPoint = nil
        RouteDetailVC.fromPoint = nil
        
        DispatchQueue.main.async { [self] in
            [to, from].compactMap({ $0 }).forEach({
                mapViewDelegate.unpinAnnotation($0, animated: true)
            })
            
            if let pathID = pathID {
                if from == nil,
                   let from = IMDFDecoder.defaultPathStartPoint {
                    mapViewDelegate.unpinAnnotation(from, animated: true)
                }
                
                mapViewDelegate.removePath(id: pathID)
            }
        }
        
    }
}
