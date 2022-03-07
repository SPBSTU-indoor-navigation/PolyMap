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
    func didSelect(_ annotation: MKAnnotation?)
    func didDeselect(_ annotation: MKAnnotation?)
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
    private var currentSelection: MKAnnotation?
    
    private var hidingEnable: Bool {
        return !(mooved || moovedByScroll) && currentSize == .big && state == .medium
    }
    
    func annotationDeselect(annotation: MKAnnotation?) {
        guard let currentSelection = currentSelection,
              let annotation = annotation else { return }
        
        if currentSelection.isEqual(annotation) && pages.last == .annotationInfo {
            popViewController(animated: true)
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if pages.last == .annotationInfo {
            mapView?.deselectAnnotation(currentSelection, animated: true)
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
    
    func didSelect(_ annotation: MKAnnotation?) {
        currentSelection = annotation
        guard let annotation = annotation as? Castable else { return }
        
        if pages.last == .annotationInfo {
            if let unitDetail = viewControllers.last as? UnitDetailVC {
                unitDetail.configurate(occupantInfo: annotation.cast())
            }
        } else {
            let vc = UnitDetailVC(closable: true)
            vc.configurate(occupantInfo: annotation.cast())
            pushViewController(vc, animated: true)
        }
        
        if state != .medium && currentSize == .big {
            changeState(state: .medium)
        }
    }
    
    func didDeselect(_ annotation: MKAnnotation?) {
        DispatchQueue.main.async { [weak self] in
            self?.annotationDeselect(annotation: annotation)
        }
    }

}
