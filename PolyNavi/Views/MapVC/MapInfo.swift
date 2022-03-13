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
    func zoomMap(zoom: Float, animated: Bool)
    func didSelect(_ annotation: MKAnnotation?)
    func didDeselect(_ annotation: MKAnnotation?)
    func getSafeZone() -> UIView
    func getHorizontalSize() -> BottomSheetViewController.HorizontalSize
}

protocol RouteDetail {
    func setFrom()
    func setTo()
}

class MapInfo: BottomSheetViewController {
    enum Page {
        case search
        case annotationInfo
        case route
        case unknown
    }
    
    static private(set) var routeDetail: RouteDetail? = nil
    
    var pages: [Page] = [.search]
    var mapView: OverlayedMapView?
    
    private var startZoom: Float = 0
    private var lastZoomChange = Date.timeIntervalSinceReferenceDate
    private var zoomHidden = false
    private var currentSelection: MKAnnotation?
    
    var routeDetailVC: RouteDetailVC?
    
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
    
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        if pages.last == .annotationInfo {
            mapView?.deselectAnnotation(currentSelection, animated: true)
        }
        pages.removeLast()
        let vc = super.popViewController(animated: animated)
        
        switch vc {
        case is RouteDetailVC:
            routeDetailVC = nil
        default: break
        }
        
        return vc
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        switch viewController {
        case is UnitDetailVC:
            pages.append(.annotationInfo)
        case is RouteDetailVC:
            pages.append(.route)
        default:
            pages.append(.unknown)
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override init(parentVC: UIViewController, rootViewController: UIViewController) {
        super.init(parentVC: parentVC, rootViewController: rootViewController)
        
        MapInfo.routeDetail = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapInfo: MapInfoDelegate {

    
    func zoomMap(zoom: Float, animated: Bool) {
        
        if animated { return }
        
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
                unitDetail.configurate(mapDetailInfo: annotation.cast())
            }
        } else {
            let vc = UnitDetailVC(closable: true)
            vc.configurate(mapDetailInfo: annotation.cast())
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
    
    func getSafeZone() -> UIView {
        return safeZone
    }
    
    func getHorizontalSize() -> BottomSheetViewController.HorizontalSize {
        return horizontalSize()
    }

}

extension MapInfo: RouteDetail {
    func setFrom() {
        let vc = getRouteVC()
    }
    
    func setTo() {
        let vc = getRouteVC()
    }
    
    func getRouteVC() -> RouteDetailVC {
        if routeDetailVC == nil {
            let vc = RouteDetailVC(closable: true)
            routeDetailVC = vc
            pushViewController(vc, animated: true)
            return vc
        }
        
        while pages.last != .route {
            popViewController(animated: true)
        }
        
        return self.routeDetailVC!
    }
    
    
}
