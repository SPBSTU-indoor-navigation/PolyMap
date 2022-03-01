//
//  MapInfo.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 18.02.2022.
//

import UIKit
import MapKit

protocol MapInfoDelegate {
    func panAction(_ sender: UIPanGestureRecognizer)
    func zoomMap(zoom: Float)
    func didSelect(_ view: MKAnnotationView)
    func didDeselect(_ view: MKAnnotationView)
}

class MapInfo: BottomSheetViewController {
    enum Page {
        case search
        case annotationInfo
        case unknown
    }
    
    var pages: [Page] = [.search]
    var mapView: OverlayedMapView?
    
    private var startZoom: Float = 0
    private var lastZoomChange = Date.timeIntervalSinceReferenceDate
    private var zoomHidden = false
    private var currentSelection: MKAnnotationView?
    
    private var hidingEnable: Bool {
        return !(mooved || moovedByScroll) && currentSize == .big && state == .medium
    }
    
    func annotationDeselect(view: MKAnnotationView) {
        if currentSelection == view && pages.last == .annotationInfo {
            popViewController(animated: true)
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if pages.last == .annotationInfo {
            mapView?.deselectAnnotation(currentSelection?.annotation, animated: true)
        }
        pages.removeLast()
        return super.popViewController(animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        switch viewController {
        case is UnitDetailVC:
            pages.append(.annotationInfo)
            
        default:
            pages.append(.unknown)
        }
    }
}

extension MapInfo: MapInfoDelegate {
    func zoomMap(zoom: Float) {
        if Date.timeIntervalSinceReferenceDate - lastZoomChange > 0.3 {
            startZoom = zoom
            zoomHidden = false
        }
        lastZoomChange = Date.timeIntervalSinceReferenceDate
        
        if abs(zoom - startZoom) > 0.5  {
            if hidingEnable && !zoomHidden {
                changeState(state: .small)
            }
            zoomHidden = true
        }
    }
    
    func panAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: view)
        let transition = sender.translation(in: view)
        
        if hidingEnable {
            if transition.y > 0 && location.y > -50 {
                changeState(state: .small)
            }
        }
    }
    
    func didSelect(_ view: MKAnnotationView) {
        currentSelection = view
        if pages.last == .annotationInfo {
            
        } else {
            pushViewController(UnitDetailVC(closable: true), animated: true)
        }
        
        if state != .medium && currentSize == .big {
            changeState(state: .medium)
        }
    }
    
    func didDeselect(_ view: MKAnnotationView) {
        DispatchQueue.main.async { [weak self] in
            self?.annotationDeselect(view: view)
        }
    }

}
