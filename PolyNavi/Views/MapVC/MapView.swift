//
//  MapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 15.11.2021.
//

import UIKit
import MapKit

class MapView: UIView {
    
    let MIN_SHOW_ZOOM : Float = 18.0
    
    var mapContainerView : UIView?
    var lastZoom : Float = -1.0
    let centerPosition = CLLocationCoordinate2D(latitude: 60.00385, longitude: 30.37539)
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
        $0.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 0, maxCenterCoordinateDistance: 5000), animated: false)
        $0.setCenter(centerPosition, animated: true)
        $0.isPitchEnabled = false
        $0.pointOfInterestFilter = .excludingAll
        $0.showsCompass = false
        
        $0.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(UnitAnnotation.self))
        $0.register(AmenityAnnotationView.self, forAnnotationViewWithReuseIdentifier: AmenityAnnotation.reusableIdentifier)
        
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
    
    func layoutViews() {
        mapContainerView = findViewOfType("MKScrollContainerView", inView: mapView)
        let center : UIView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .systemRed
            $0.layer.cornerRadius = 5
            return $0
        } (UIView())
        
        
        addSubview(mapView)
        addSubview(levelSwitcher)
        addSubview(compassButton)
        
//        addSubview(center)
        
        levelSwitcherConstraint = levelSwitcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
//            center.widthAnchor.constraint(equalToConstant: 10),
//            center.heightAnchor.constraint(equalToConstant: 10),
//            center.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
//            center.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
            
            levelSwitcher.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            levelSwitcher.widthAnchor.constraint(equalToConstant: 44),
            levelSwitcherConstraint!,
            
            compassButton.topAnchor.constraint(equalTo: levelSwitcher.topAnchor),
            compassButton.trailingAnchor.constraint(lessThanOrEqualTo: levelSwitcher.leadingAnchor, constant: -10),
            compassButton.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        
    }
    
    
    func loadIMDF() {
        let path = Bundle.main.resourceURL!.appendingPathComponent("IMDFData")
        
        venue = IMDFDecoder.decode(path)
        venue?.show(mapView)
        
        
        mapView.setCameraBoundary(MKMapView.CameraBoundary(mapRect: venue!.boundingMapRect), animated: false)
    }
    
    func onLevelChange(ordinal: Int) {
        currentBuilding?.changeOrdinal(ordinal, mapView)
    }
    
    func nearestBuilding(position: CLLocationCoordinate2D) -> Building? {
        
        let centerPoint = MKMapPoint(position)
        let centerRect = MKMapRect(origin: centerPoint, size: MKMapSize(width: 0.001, height: 0.001))
        
        for builing in venue!.buildings.filter({ $0.levels.count > 0 }) {
            for polygon in builing.polygons {
                if polygon.intersects(centerRect) {
                    return builing;
                }
            }
        }
        
        var nearestBuilding: Building? = nil
        var nearestDistance: Double = Double.infinity
        
        for builing in venue!.buildings.filter({ $0.levels.count > 0 }) {
            for polygon in builing.polygons {
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
        
        guard let currentBuilding = currentBuilding else { return }
        if abs(lastZoom - zoomLevel) < Float.ulpOfOne { return }
        lastZoom = zoomLevel
    
        if zoomLevel > MIN_SHOW_ZOOM {
            currentBuilding.show(mapView)
            showLevelSwitcher()
        } else {
            currentBuilding.hide(mapView)
            hideLevelSwitcher()
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
        var renderer: MKOverlayRenderer = MKPolygonRenderer(overlay: overlay)
        
        if overlay is MKMultiPolygon {
            renderer = MKMultiPolygonRenderer(overlay: overlay)
        } else if overlay is MKPolygon {
            renderer = MKPolygonRenderer(overlay: overlay)
        } else if overlay is MKPolyline {
            renderer = MKPolylineRenderer(overlay: overlay)
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
            annotationView = setupBridgeAnnotationView(for: annotation, on: mapView)
        } else if let annotation = annotation as? AmenityAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AmenityAnnotation.reusableIdentifier, for: annotation)
        }
        
        return annotationView
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updateMap(centerPosition: mapView.centerCoordinate)
        updateMap(zoomLevel: getZoom())
    }
    

    func setupBridgeAnnotationView(for annotation: UnitAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let identifier = NSStringFromClass(UnitAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let point = view as? MKMarkerAnnotationView {
        }
        
        return view
    }
}

