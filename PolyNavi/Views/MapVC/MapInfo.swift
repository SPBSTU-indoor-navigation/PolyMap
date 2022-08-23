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
    func mkDidSelect(_ annotation: MKAnnotation?) //only for mapkit
    func mkDidDeselect(_ annotation: MKAnnotation?) //only for mapkit
    func select(_ annotation: MKAnnotation?)
    func getSafeZone() -> UIView
    func getHorizontalSize() -> BottomSheetViewController.HorizontalSize
}

protocol RouteDetail {
    func setFrom(_ annotation: MKAnnotation)
    func setTo(_ annotation: MKAnnotation)
    func setup(from: MKAnnotation, to: MKAnnotation, routeParams: RouteParameters)
}

protocol ExclusiveRouteDetail {
    func show(from: MKAnnotation, to: MKAnnotation, routeParams: RouteParameters, allowParameterChange: Bool)
    func currentRoute() -> (MKAnnotation, MKAnnotation, RouteParameters, Bool)?
}

class MapInfo: BottomSheetViewController {
    enum Page {
        case search
        case annotationInfo
        case route
        case exclusiveRoute
        case unknown
    }
    
    static private(set) var routeDetail: RouteDetail? = nil
    static private(set) var exclusiveRouteDetail: ExclusiveRouteDetail? = nil
    
    var searchable: [Searchable] = [] {
        didSet {
            searchVC.searchable = searchable
            routeDetailVC?.searchable = searchable
        }
    }
    var pages: [Page] = []
    var mapViewDelegate: MapViewDelegate? {
        didSet {
            searchVC.mapViewDelegate = mapViewDelegate
            
            for vc in viewControllers {
                if let unitDetail = vc as? UnitDetailVC {
                    unitDetail.mapViewDelegate = mapViewDelegate
                }
            }
        }
    }
    
    private var startZoom: Float = 0
    private var lastZoomChange = Date.timeIntervalSinceReferenceDate
    private var zoomHidden = false
    private var currentSelection: MKAnnotation?
    private var skipSelectStateChange = false
    
    weak var routeDetailVC: RouteDetailVC?
    weak var exclusiveRouteDetailVC: ExclusiveRouteDetailVC?
    var searchVC: SearchVC
    
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
    
    func onPopVC(_ vc: UIViewController) {
        switch vc {
        case is RouteDetailVC:
            routeDetailVC?.beforeClose()
            routeDetailVC = nil
        case is ExclusiveRouteDetailVC:
            exclusiveRouteDetailVC?.beforeClose()
            exclusiveRouteDetailVC = nil
        default: break
        }
    }
    
    func onPopToVC(_ vc: UIViewController) {
        if let unitDetail = vc as? UnitDetailVC,
           let annotation = unitDetail.unitDetailInfo?.annotation as? MKAnnotation {
            skipSelectStateChange = true
            skipSelectStateChange = mapViewDelegate?.focusAndSelect(annotation: annotation, focusVariant: .auto) ?? false
        }
    }
    
    @discardableResult
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let vcs = super.popToViewController(viewController, animated: animated)
        
        if let vcs = vcs {
            
            if !vcs.isEmpty {
                if pages.last == .annotationInfo {
                    mapViewDelegate?.deselectAnnotation(currentSelection, animated: true)
                }
            }
            
            for vc in vcs {
                pages.removeLast()
                onPopVC(vc)
            }
        }
        
        onPopToVC(viewController)
        
        return vcs
    }
    
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        
        if pages.last == .annotationInfo {
            mapViewDelegate?.deselectAnnotation(currentSelection, animated: true)
        }

        if let vc = vc {
            pages.removeLast()
            if let last = self.viewControllers.last {
                onPopToVC(last)
            }
            onPopVC(vc)
        }
        
        return vc
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        let count = viewControllers.count
        
        super.pushViewController(viewController, animated: animated)
        
        if count != viewControllers.count {
            switch viewController {
            case is UnitDetailVC:
                pages.append(.annotationInfo)
            case is RouteDetailVC:
                pages.append(.route)
            case is ExclusiveRouteDetailVC:
                pages.append(.exclusiveRoute)
            case is SearchVC:
                pages.append(.search)
            default:
                pages.append(.unknown)
            }
        }
    }
    
    init (parentVC: UIViewController) {
        searchVC = SearchVC()
        super.init(parentVC: parentVC, rootViewController: searchVC)
        
        searchVC.mapInfoDelegate = self
        MapInfo.routeDetail = self
        MapInfo.exclusiveRouteDetail = self
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
    
    func mkDidSelect(_ annotation: MKAnnotation?) {
        currentSelection = annotation
        select(annotation)
    }
    
    func mkDidDeselect(_ annotation: MKAnnotation?) {
        DispatchQueue.main.async { [weak self] in
            self?.annotationDeselect(annotation: annotation)
        }
    }
    
    func select(_ annotation: MKAnnotation?) {
        guard let annotation = annotation as? UnitDetailInfoCastable else { return }
        
        if let annotation = annotation as? BaseAnnotation {
            SearchHistoryStorage.shared.open(annotation: annotation)
        }
        
        if pages.last == .annotationInfo {
            if let unitDetail = viewControllers.last as? UnitDetailVC {
                unitDetail.configurate(unitDetailInfo: UnitDetailInfo(castable: annotation, unitDetail: unitDetail), showRouteButton: !pages.contains(.exclusiveRoute))
            }
        } else {
            let vc = UnitDetailVC(mapViewDelegate: mapViewDelegate)
            vc.configurate(unitDetailInfo: UnitDetailInfo(castable: annotation, unitDetail: vc), showRouteButton: !pages.contains(.exclusiveRoute))
            pushViewController(vc, animated: true)
        }
        
        if state != .medium && currentSize == .big && !skipSelectStateChange {
            changeState(state: .medium)
        }
        
        skipSelectStateChange = false
    }
    
    func getSafeZone() -> UIView {
        return safeZone
    }
    
    func getHorizontalSize() -> BottomSheetViewController.HorizontalSize {
        return horizontalSize()
    }

}

extension MapInfo: RouteDetail {
    func setup(from: MKAnnotation, to: MKAnnotation, routeParams: RouteParameters) {
        
        if let annotation = currentSelection {
            mapViewDelegate?.deselectAnnotation(annotation, animated: true)
        }
        
        let vc = getRouteVC()
        vc.setup(from: from, to: to, routeParams: routeParams)
    }
    
    func setFrom(_ annotation: MKAnnotation) {
        let vc = getRouteVC()
        vc.setFrom(annotation)
    }
    
    func setTo(_ annotation: MKAnnotation) {
        let vc = getRouteVC()
        vc.setTo(annotation)
    }
    
    func getRouteVC() -> RouteDetailVC {
        if let routeDetailVC = routeDetailVC, viewControllers.contains(routeDetailVC) {
            DispatchQueue.main.async { [self] in
                popToViewController(routeDetailVC, animated: true)
            }
            return routeDetailVC
        } else {
            let vc = RouteDetailVC(closable: true, mapViewDelegate: mapViewDelegate!, searchable: searchable)
            routeDetailVC = vc
            pushViewController(vc, animated: true)
            return vc
        }
    }
}

extension MapInfo: ExclusiveRouteDetail {
    func show(from: MKAnnotation, to: MKAnnotation, routeParams: RouteParameters, allowParameterChange: Bool) {
        if pages.last == .annotationInfo {
            mapViewDelegate?.deselectAnnotation(currentSelection, animated: true)
        }
        
        getExclusiveRouteVC(completion: { $0.show(from: from, to: to, routeParams: routeParams, allowParameterChange: allowParameterChange) })
    }
    
    func currentRoute() -> (MKAnnotation, MKAnnotation, RouteParameters, Bool)? {
        if let exclusiveRouteDetailVC = exclusiveRouteDetailVC,
           viewControllers.contains(exclusiveRouteDetailVC),
           let from = exclusiveRouteDetailVC.from,
           let to = exclusiveRouteDetailVC.to,
           let params = exclusiveRouteDetailVC.routeParams,
           let allowParameterChange = exclusiveRouteDetailVC.allowParameterChange {
            return (from, to, params, allowParameterChange)
        }
        return nil
    }
    
    func getExclusiveRouteVC(completion: @escaping (ExclusiveRouteDetailVC) -> Void) {
        if let exclusiveRouteDetailVC = exclusiveRouteDetailVC, viewControllers.contains(exclusiveRouteDetailVC) {
            popToViewController(exclusiveRouteDetailVC, animated: true)
            completion(exclusiveRouteDetailVC)
        } else {
            
            func create() {
                let vc = ExclusiveRouteDetailVC(closable: false, mapViewDelegate: mapViewDelegate!)
                exclusiveRouteDetailVC = vc
                pushViewController(vc, animated: true)
                completion(vc)
            }
            
            if viewControllers.count > 1,
                let firstVC = viewControllers.first {
                popToViewController(firstVC, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55, execute: {
                    create()
                })
            } else {
                create()
            }
        }
    }
}
