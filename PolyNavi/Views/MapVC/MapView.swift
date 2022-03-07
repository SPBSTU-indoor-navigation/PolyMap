//
//  MapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 15.11.2021.
//

import UIKit
import MapKit

class MapView: UIView {
    
    enum Constants {
        static let minShowZoom: Float = 18.5
        static let horizontalOffset = -7.0
    }
    
    var mapInfoDelegate: MapInfoDelegate? {
        didSet {
            mapView.onPan = mapInfoDelegate?.panAction
        }
    }
    
    var mapContainerView : UIView?
    var lastZoom : Float = 16
    var currentBuilding: Building?
    
    var venue: Venue?
    
    
    var levelSwitcherConstraint: NSLayoutConstraint?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        layoutViews()
        loadIMDF()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var mapView: OverlayedMapView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 25, maxCenterCoordinateDistance: 5000), animated: false)
        $0.isPitchEnabled = false
        $0.pointOfInterestFilter = .excludingAll
        $0.showsCompass = false
        $0.delegate = self
        
        $0.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: OccupantAnnotation.identifier)
        $0.register(AmenityAnnotationView.self, forAnnotationViewWithReuseIdentifier: AmenityAnnotation.identifier)
        $0.register(AmenityAnnotationView.self, forAnnotationViewWithReuseIdentifier: EnviromentAmenityAnnotation.identifier)
        $0.register(AttractionAnnotationView.self, forAnnotationViewWithReuseIdentifier: AttractionAnnotation.identifier)
        
        return $0
    }(OverlayedMapView())
    
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
    
    
    func loadIMDF() {
        let path = Bundle.main.resourceURL!.appendingPathComponent("IMDFData")
        
        venue = IMDFDecoder.decode(path)
        venue?.show(mapView)
        
        mapView.setVisibleMapRect(venue!.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(mapRect: venue!.boundingMapRect), animated: false)
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
        debug.text = "Zoom: \(roundf(zoomLevel * 100) / 100)"
        if abs(lastZoom - zoomLevel) < 0.001 { return }
        mapInfoDelegate?.zoomMap(zoom: zoomLevel)
        lastZoom = zoomLevel
    
        if let currentBuilding = currentBuilding {
            if zoomLevel > Constants.minShowZoom {
                currentBuilding.show(mapView)
                showLevelSwitcher()
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
    }
    
    func updateMap(nearestBuilding: Building?) {
        
        if currentBuilding != nearestBuilding {
            if let currentBuilding = currentBuilding {
                currentBuilding.hide(mapView)
            }
            
            if getZoom() > Constants.minShowZoom {
                nearestBuilding?.show(mapView)
                
                if let t = nearestBuilding, t.levels.count > 0 {
                    showLevelSwitcher()
                }
            }
            
            if nearestBuilding != nil {
                levelSwitcher.updateLevels(levels: Dictionary(uniqueKeysWithValues: nearestBuilding!.levels.map{ ($0.ordinal, $0.shortName?.bestLocalizedValue ?? "-") }),
                                           selected: nearestBuilding!.ordinal)
                
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
    
}


extension MapView {
    func showLevelSwitcher() {
        updateLevelSwitcher(Constants.horizontalOffset)
    }
    
    func hideLevelSwitcher() {
        updateLevelSwitcher(50)
    }
    
    private func updateLevelSwitcher(_ pos: CGFloat) {
        levelSwitcherConstraint?.constant = pos
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
    }
}


extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let customOverlay = self.mapView.customOverlay(for: overlay) else { return MKOverlayRenderer(overlay: overlay) }

        if let renderer = customOverlay.overlayRenderer {
            (customOverlay as! Styleble).configurate(renderer: renderer)
            return renderer
        }

        let renderer: MKOverlayPathRenderer

        switch overlay {
        case is MKMultiPolygon:
            renderer = MKMultiPolygonRenderer(overlay: overlay)
        case is MKPolygon:
            renderer = MKPolygonRenderer(overlay: overlay)
        case is MKMultiPolyline:
            renderer = MKMultiPolylineRenderer(overlay: overlay)
        case is MKPolyline:
            renderer = MKPolylineRenderer(overlay: overlay)
        default:
            return MKOverlayRenderer(overlay: overlay)
        }

        (customOverlay as! Styleble).configurate(renderer: renderer)

        return renderer

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        guard let reusable = annotation as? Identifiable else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reusable.identifier, for: annotation)
        (annotationView as? AnnotationMapSize)?.update(mapSize: lastZoom, animate: false)
        
        return annotationView
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updateMap(centerPosition: mapView.centerCoordinate)
        updateMap(zoomLevel: getZoom())
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapInfoDelegate?.didSelect(view.annotation)
        
        let mapSafeZone = mapInfoDelegate!.getSafeZone()
        let safeZone = mapSafeZone.convert(mapSafeZone.bounds, to: self.mapView)
        
        let centerCG = mapView.convert(mapView.centerCoordinate, toPointTo: mapView)
        let annotationCG = mapView.convert(view.annotation!.coordinate, toPointTo: mapView)
        
        
        let boundingBox = (view as? BoundingBox)?.boundingBox() ?? .zero
        
        var dx = 0.0
        var dy = 0.0
        
        let offset = UIEdgeInsets(top: -boundingBox.origin.y,
                                  left: -boundingBox.origin.x,
                                  bottom: boundingBox.height + boundingBox.origin.y,
                                  right: boundingBox.width + boundingBox.origin.x)
        
        let target = safeZone
            .inset(by: offset)
            .inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 50, right: 10))
        
        
            
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
        mapView.setCenter(point.coordinate, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mapInfoDelegate?.didDeselect(view.annotation)
    }

}

