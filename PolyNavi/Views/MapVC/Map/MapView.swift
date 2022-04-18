//
//  MapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 15.11.2021.
//

import UIKit
import MapKit

protocol MapViewDelegate {
    @discardableResult
    func focusAndSelect(annotation: MKAnnotation, focusVariant: MapView.FocusVariant) -> Bool
    func focus(on annotation: MKAnnotation, focusVariant: MapView.FocusVariant)
    func deselectAnnotation(_ annotation: MKAnnotation?, animated: Bool)
    func pinAnnotation(_ annotation: MKAnnotation, animated: Bool)
    func unpinAnnotation(_ annotation: MKAnnotation, animated: Bool)
    func addPath(path: [PathResultNode]) -> UUID
    func removePath(id: UUID)
}


class MapView: UIView {
    
    enum Constants {
        static let minShowZoom: Float = 18.5
        static let horizontalOffset = -7.0
    }
    
    enum FocusVariant {
        case auto
        case center
        case safeArea
    }
    
    var mapInfoDelegate: MapInfoDelegate? {
        didSet {
            mapView.onPan = mapInfoDelegate?.panAction
        }
    }
    
    var mapContainerView : UIView?
    var lastZoom : Float = 16
    var currentBuilding: Building?
    
    var venue: Venue? {
        willSet {
            venue?.hide(mapView)
        }
        
        didSet {
            guard let venue = venue else {
                return
            }

            venue.show(mapView)
            mapView.setVisibleMapRect(venue.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
            mapView.setCameraBoundary(MKMapView.CameraBoundary(mapRect: venue.boundingMapRect), animated: false)
        }
    }
    
    
    var levelSwitcherConstraint: NSLayoutConstraint?
    private var zoomByAnimation = false
    private var preventFocus = false
    private var wantSelect: MKAnnotation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var mapView: PathMapView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 25, maxCenterCoordinateDistance: 5000), animated: false)
        $0.isPitchEnabled = false
        $0.pointOfInterestFilter = .excludingAll
        $0.showsCompass = false
        $0.delegate = self
        $0.onAnnotationAdd = onAnnotationAdd
        
        $0.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: OccupantAnnotation.identifier)
        $0.register(AmenityAnnotationView.self, forAnnotationViewWithReuseIdentifier: AmenityAnnotation.identifier)
        $0.register(AmenityAnnotationView.self, forAnnotationViewWithReuseIdentifier: EnviromentAmenityAnnotation.identifier)
        $0.register(AttractionAnnotationView.self, forAnnotationViewWithReuseIdentifier: AttractionAnnotation.identifier)
        
        return $0
    }(PathMapView())
    
    lazy var compassButton: MKCompassButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.compassVisibility = .adaptive
        return $0
    }(MKCompassButton(mapView: mapView))
    
    private lazy var levelSwitcher: LevelSwitcher = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onChange = onLevelChange
        $0.onRotate = onRotate
        return $0
    }(LevelSwitcher())
    
    
    let debug: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .callout)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    func layoutViews() {
        mapContainerView = mapView.subviewsByType("MKScrollContainerView")
        
        addSubview(mapView)
        addSubview(levelSwitcher)
        addSubview(compassButton)
        addSubview(debug)

        
        levelSwitcherConstraint = levelSwitcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.horizontalOffset)
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            levelSwitcher.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            levelSwitcher.widthAnchor.constraint(equalToConstant: 44),
            levelSwitcherConstraint!,
            
            compassButton.topAnchor.constraint(equalTo: levelSwitcher.topAnchor),
            compassButton.trailingAnchor.constraint(lessThanOrEqualTo: levelSwitcher.leadingAnchor, constant: -10),
            compassButton.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            debug.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            debug.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
        ])
    }
    
    func onLevelChange(ordinal: Int) {
        currentBuilding?.changeOrdinal(ordinal, mapView)
    }
    
    func onRotate() {
        if let rotation = currentBuilding?.rotation {
            if abs(mapView.camera.heading - rotation) > 0.1 {
                let cam = MKMapCamera(lookingAtCenter: mapView.camera.centerCoordinate,
                                      fromDistance: mapView.camera.centerCoordinateDistance,
                                      pitch: mapView.camera.pitch,
                                      heading: rotation)
                mapView.setCamera(cam, animated: true)
            }
            
        }
    }
    
    func nearestBuilding(position: CLLocationCoordinate2D) -> Building? {
        
        let centerPoint = MKMapPoint(position)
        let centerRect = MKMapRect(origin: centerPoint, size: MKMapSize(width: 0.001, height: 0.001))

        let buildings = venue!.buildings.filter({ $0.levels.count > 0 })
        
        for builing in buildings {
            guard let polygons = builing.polygons else { continue }
            
            for polygon in polygons {
                if polygon.intersects(centerRect) {
                    return builing;
                }
            }
        }
        
        var nearestBuilding: Building? = nil
        var nearestDistance: Double = Double.infinity
        
        for builing in buildings {
            guard let polygons = builing.polygons else { continue }

            for polygon in polygons {
                let points = polygon.points()
                
                for i in 0..<polygon.pointCount {
                    let distance = points[i].distance(to: centerPoint)
                    
                    if distance < nearestDistance {
                        nearestDistance = distance
                        nearestBuilding = builing
                    }
                    
                }
            }
        }
        
        
        let delta = mapView.region.deltaInMeters()
        let min = [delta.1, delta.1].min()! / 3.0
        
        if nearestDistance > min {
            return nil
        }
        
        return nearestBuilding
    }
    
    
    func updateMap(zoomLevel: Float) {
        debug.text = "Zoom: \(roundf(zoomLevel * 100) / 100)\ndist: \(mapView.camera.centerCoordinateDistance)"
        if abs(lastZoom - zoomLevel) < 0.001 { return }
        mapInfoDelegate?.zoomMap(zoom: zoomLevel, animated: zoomByAnimation)
        lastZoom = zoomLevel
    
        if let currentBuilding = currentBuilding {
            if zoomLevel > Constants.minShowZoom {
                currentBuilding.show(mapView)
                showLevelSwitcher(building: currentBuilding)
            } else {
                currentBuilding.hide(mapView)
                hideLevelSwitcher()
            }
        }
        
        for annotation in mapView.annotations {
            if let mapSize = mapView.view(for: annotation) as? AnnotationMapSize {
                mapSize.update(mapSize: zoomLevel, animate: true)
            }
        }
        
        mapView.currentOverlays
            .compactMap({ $0.value as? CustomOverlay & StylebleMapSize })
            .forEach({
                guard let renderer = mapView.renderer(for: $0.geometry) else { return }
                $0.configurate(renderer: renderer, mapSize: zoomLevel)
            })
    }
    
    func updateMap(nearestBuilding: Building?) {
        
        if currentBuilding != nearestBuilding {
            if let currentBuilding = currentBuilding {
                currentBuilding.hide(mapView)
            }
            
            if let nearestBuilding = nearestBuilding {
                
                if getZoom() > Constants.minShowZoom {
                    nearestBuilding.show(mapView)
                    showLevelSwitcher(building: nearestBuilding)
                }
            } else {
                hideLevelSwitcher()
            }
            
            currentBuilding = nearestBuilding
        }
    }
    
    func updateMap(centerPosition: CLLocationCoordinate2D) {
        let nearestBuilding = nearestBuilding(position: centerPosition)
        if nearestBuilding != currentBuilding {
            updateMap(nearestBuilding: nearestBuilding)
        }
    }
    
    func selectAnnotationAfterAdding(annotation: MKAnnotation?) {
        
        guard let annotation = annotation else { return }
        
        if mapView.annotations.contains(where: { annotation.isEqual($0) }) {
            selectAnnotation(annotation, animated: true, preventFocus: true)
        } else {
            wantSelect = annotation
        }
    }
    
    func onAnnotationAdd(_ annotation: MKAnnotation) {
        if annotation.isEqual(wantSelect) {
            selectAnnotation(annotation, animated: true, preventFocus: true)
        }
    }
    
    func mapFocusCenter(point: CLLocationCoordinate2D, distance: CGFloat, complition: (() -> Void)?) {
        
        let shoudUseCam = abs(mapView.camera.centerCoordinateDistance - distance) > 0.1
        let targetCam = MKMapCamera(lookingAtCenter: mapView.camera.centerCoordinate, fromDistance: distance, pitch: mapView.camera.pitch, heading: mapView.camera.heading)
        
        let tempMap = MKMapView(frame: mapView.frame)
        tempMap.setCamera(shoudUseCam ? targetCam : mapView.camera, animated: false)
        tempMap.setCenter(point, animated: false)
        
        
        let safeZone = mapInfoDelegate?.getSafeZone() ?? mapView
        let targetCenter = tempMap.convert(CGPoint(x: mapView.frame.width - safeZone.center.x,
                                                   y: mapView.frame.height - safeZone.center.y + (mapInfoDelegate?.getHorizontalSize() != .big ? mapView.frame.height / 20 : 0)), //Сдвиг вверх по правилам дизайна. Человеческий глаз склонен завышать точку центра
                                           toCoordinateFrom: mapView)
        
        MKMapView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            if shoudUseCam { self.mapView.camera = targetCam }
            self.mapView.centerCoordinate = targetCenter
        }, completion: { _ in
            complition?()
        })
    }
    
    func mapFocusSafeArea(point: CLLocationCoordinate2D, boundingBox: CGRect, complition: (() -> Void)? = nil) {
        let mapSafeZone = mapInfoDelegate!.getSafeZone()
        let safeZone = mapSafeZone.convert(mapSafeZone.bounds, to: self.mapView)
        
        let centerCG = mapView.convert(mapView.centerCoordinate, toPointTo: mapView)
        let annotationCG = mapView.convert(point, toPointTo: mapView)
        
        
        var dx = 0.0
        var dy = 0.0
        
        let offset = UIEdgeInsets(top: -boundingBox.origin.y,
                                  left: -boundingBox.origin.x,
                                  bottom: boundingBox.height + boundingBox.origin.y,
                                  right: boundingBox.width + boundingBox.origin.x)
        
        let target = safeZone
            .inset(by: offset)
            .inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 50, right: 10))
        
        
        
        if !target.contains(annotationCG) {
            if annotationCG.y < target.minY {
                dy = annotationCG.y - target.minY
            } else if annotationCG.y > target.maxY {
                dy = annotationCG.y - target.maxY
            }
            
            if annotationCG.x < target.minX {
                dx = annotationCG.x - target.minX
            } else if annotationCG.x > target.maxX {
                dx = annotationCG.x - target.maxX
            }
            
            let point = MKMapPoint(mapView.convert(CGPoint(x: centerCG.x + dx, y: centerCG.y + dy), toCoordinateFrom: mapView))
            MKMapView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.mapView.centerCoordinate = point.coordinate
            }, completion: { _ in
                complition?()
            })
        }
    }
    
    func selectAnnotation(_ annotation: MKAnnotation, animated: Bool, preventFocus: Bool ) {
        self.preventFocus = preventFocus
        mapView.selectAnnotation(annotation, animated: animated)
    }
}


extension MapView {
    func showLevelSwitcher(building: Building) {
        levelSwitcher.updateLevels(levels: Dictionary(uniqueKeysWithValues: building.levels.map{ ($0.ordinal, $0.shortName?.bestLocalizedValue ?? "-") }),
                                   selected: building.ordinal)
        
        self.layoutSubviews()
        
        updateLevelSwitcher(Constants.horizontalOffset)
    }
    
    func hideLevelSwitcher() {
        updateLevelSwitcher(50)
    }
    
    private func updateLevelSwitcher(_ pos: CGFloat) {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.15) {
            self.levelSwitcherConstraint?.constant = pos
            self.layoutIfNeeded()
        }
    }
}

extension MapView: MKMapViewDelegate {
    
    func renderer(for overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKMultiPolygon: return MKMultiPolygonRenderer(overlay: overlay)
        case is MKPolygon: return MKPolygonRenderer(overlay: overlay)
        case is MKMultiPolyline: return MKMultiPolylineRenderer(overlay: overlay)
        case is MKPolyline: return MKPolylineRenderer(overlay: overlay)
        default: return MKOverlayRenderer(overlay: overlay)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let customOverlay = self.mapView.customOverlay(for: overlay) {

            if let renderer = customOverlay.overlayRenderer {
                (customOverlay as! Styleble).configurate(renderer: renderer)
                return renderer
            }

            let renderer = renderer(for: overlay)
            (customOverlay as! Styleble).configurate(renderer: renderer)

            return renderer
        }
        
        if overlay is PathOverlay {
//            let pathRenderer = GradientPathRenderer(polyline: overlay as! MKPolyline, colors: [.systemBlue], showsBorder: true, borderColor: .white)
            let pathRenderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
            pathRenderer.lineWidth = 7
            pathRenderer.strokeColor = .systemBlue
            return pathRenderer
        }

    
        let renderer = renderer(for: overlay)
        if let styleble = overlay as? Styleble {
            styleble.configurate(renderer: renderer)
            return renderer
        }
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        guard let reusable = annotation as? ReusableCell else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reusable.identifier, for: annotation)
        (annotationView as? AnnotationMapSize)?.update(mapSize: lastZoom, animate: false)
        
        return annotationView
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updateMap(centerPosition: mapView.centerCoordinate)
        updateMap(zoomLevel: getZoom())
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        wantSelect = nil
        mapInfoDelegate?.mkDidSelect(view.annotation)
        
        if preventFocus {
            preventFocus = false
        } else {
            let boundingBox = (view as? BoundingBox)?.boundingBox() ?? .zero
            mapFocusSafeArea(point: view.annotation!.coordinate, boundingBox: boundingBox)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mapInfoDelegate?.mkDidDeselect(view.annotation)
    }

}


extension MapView: MapViewDelegate {
    func pinAnnotation(_ annotation: MKAnnotation, animated: Bool) {
        mapView.pinAnnotation(annotation, animated: animated)
    }
    
    func unpinAnnotation(_ annotation: MKAnnotation, animated: Bool) {
        mapView.unpinAnnotation(annotation, animated: animated)
    }
    
    
    func deselectAnnotation(_ annotation: MKAnnotation?, animated: Bool) {
        mapView.deselectAnnotation(annotation, animated: animated)
    }
    
    func focusAndSelect(annotation: MKAnnotation, focusVariant: MapView.FocusVariant = .auto) -> Bool {
        selectAnnotationAfterAdding(annotation: annotation)
        focus(on: annotation, focusVariant: focusVariant)
        
        return !mapView.selectedAnnotations.contains(where: { annotation.isEqual($0) })
    }
    
    func focus(on annotation: MKAnnotation, focusVariant: FocusVariant = .auto) {
        
        var targetZoom = mapView.camera.centerCoordinateDistance
        
        switch annotation {
        case is OccupantAnnotation: targetZoom = 150
        case is AmenityAnnotation: targetZoom = 200
        case is AttractionAnnotation:
            if targetZoom > 1000 || lastZoom > Constants.minShowZoom {
                targetZoom = 800
            }
        case is EnviromentAmenityAnnotation:
            if 500 < targetZoom || targetZoom < 200 {
                targetZoom = 400
            }
        default: break
        }
        
        if let indoor = annotation as? IndoorAnnotation {
            if currentBuilding == indoor.building {
                levelSwitcher.changeLevel(selected: indoor.level.ordinal, animated: true)
            } else {
                indoor.building.ordinal = indoor.level.ordinal
            }
        }
        
        self.zoomByAnimation = true
        
        let view = mapView.view(for: annotation)
        let boundingBox = (view as? BoundingBox)?.boundingBox() ?? .zero

        var centering = focusVariant == .center
        
        if focusVariant == .auto {
            if let view = view,
               mapView.frame.intersects(view.frame.inset(by: .init(top: boundingBox.maxY, left: boundingBox.minX, bottom: boundingBox.minY, right: boundingBox.maxX))) {
                centering = false
            } else {
                centering = true
            }
        }
        
        if centering {
            mapFocusCenter(point: annotation.coordinate, distance: targetZoom, complition: {
                self.zoomByAnimation = false
            })
        } else {
            mapFocusSafeArea(point: annotation.coordinate, boundingBox: boundingBox, complition: {
                self.zoomByAnimation = false
            })
        }
        
    }
    
    func addPath(path: [PathResultNode]) -> UUID {
//        mapView.addPath(path: path)
        return venue?.addPath(mapView, path: path) ?? UUID()
    }
    
    func removePath(id: UUID) {
        venue?.removePath(mapView, id: id)
    }
    
    
}
