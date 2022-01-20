//
//  MapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 15.11.2021.
//

import UIKit
import MapKit

class MapView: UIView {
    
    let MIN_SHOW_ZOOM : Float = 18.5
    
    var mapContainerView : UIView?
    var lastZoom : Float = 16
    var currentBuilding: Building?
    
    var venue: Venue?
    
    
    var levelSwitcherConstraint: NSLayoutConstraint?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mapView.delegate = self
    
        layoutViews()
        loadIMDF()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var mapView: MKMapView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 25, maxCenterCoordinateDistance: 5000), animated: false)
        $0.isPitchEnabled = false
        $0.pointOfInterestFilter = .excludingAll
        $0.showsCompass = false
        
        $0.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: UnitAnnotation.reusableIdentifier)
        $0.register(AmenityAnnotationView.self, forAnnotationViewWithReuseIdentifier: AmenityAnnotation.reusableIdentifier)
        $0.register(AmenityAnnotationView.self, forAnnotationViewWithReuseIdentifier: EnviromentAmenityAnnotation.reusableIdentifier)
        $0.register(AttractionAnnotationView.self, forAnnotationViewWithReuseIdentifier: AttractionAnnotation.reusableIdentifier)
        
        return $0
    }(MKMapView())
    
    lazy var compassButton: MKCompassButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.compassVisibility = .adaptive
        return $0
    }(MKCompassButton(mapView: mapView))
    
    private lazy var levelSwitcher: LevelSwitcher = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onChange = onLevelChange
        return $0
    }(LevelSwitcher())
    
    
    let debug: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .callout)
        return $0
    }(UILabel())
    
    func layoutViews() {
        mapContainerView = findViewOfType("MKScrollContainerView", inView: mapView)
        
        addSubview(mapView)
        addSubview(levelSwitcher)
        addSubview(compassButton)
        addSubview(debug)

        
        levelSwitcherConstraint = levelSwitcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        
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
        if abs(lastZoom - zoomLevel) < Float.ulpOfOne { return }
        lastZoom = zoomLevel
    
        if let currentBuilding = currentBuilding {
            if zoomLevel > MIN_SHOW_ZOOM {
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
            
            if getZoom() > MIN_SHOW_ZOOM {
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
        updateLevelSwitcher(-5)
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
        
        guard let overlay = overlay as? CustomOverlay else { return MKOverlayRenderer(overlay: overlay) }
        
        if let renderer = overlay.overlayRenderer {
            (overlay as! Styleble).configurate(renderer: renderer)
            return renderer
        }
        
        let geometry = overlay.geometry
        
        let renderer: MKOverlayPathRenderer
        
        switch geometry {
        case is MKMultiPolygon:
            renderer = MKMultiPolygonRenderer(overlay: geometry)
        case is MKPolygon:
            renderer = MKPolygonRenderer(overlay: geometry)
        case is MKMultiPolyline:
            renderer = MKMultiPolylineRenderer(overlay: geometry)
        case is MKPolyline:
            renderer = MKPolylineRenderer(overlay: geometry)
        default:
            return MKOverlayRenderer(overlay: geometry)
        }
        
        (overlay as! Styleble).configurate(renderer: renderer)
        
        return renderer

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }

        var annotationView: MKAnnotationView?

        if let annotation = annotation as? UnitAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: UnitAnnotation.reusableIdentifier, for: annotation)
        } else if let annotation = annotation as? AmenityAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AmenityAnnotation.reusableIdentifier, for: annotation)
        } else if let annotation = annotation as? EnviromentAmenityAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EnviromentAmenityAnnotation.reusableIdentifier, for: annotation)
        } else if let annotation = annotation as? AttractionAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AttractionAnnotation.reusableIdentifier, for: annotation)
        }
        
        (annotationView as? AnnotationMapSize)?.update(mapSize: lastZoom, animate: false)
        
        return annotationView
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updateMap(centerPosition: mapView.centerCoordinate)
        updateMap(zoomLevel: getZoom())
    }

}
