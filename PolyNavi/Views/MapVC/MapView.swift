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
    
    private var mapContainerView : UIView?
    var lastZoom : Float = -1.0
    
    let centerPosition = CLLocationCoordinate2D(latitude: 60.00385, longitude: 30.37539)
    
    
    var currentBuilding: Building?
    
    
    let points = [CLLocationCoordinate2DMake(60.001805826814433, 30.370466176872295),
                  CLLocationCoordinate2DMake(60.002525284079482, 30.370466120139067),
                  CLLocationCoordinate2DMake(60.002525284079482, 30.372444797471083),
                  CLLocationCoordinate2DMake(60.001805826814433, 30.372444832684813)]
    
    let points1 = [CLLocationCoordinate2DMake(60.003805826814433, 30.370466176872295),
                  CLLocationCoordinate2DMake(60.002625284079482, 30.370466120139067),
                  CLLocationCoordinate2DMake(60.002625284079482, 30.372444797471083),
                  CLLocationCoordinate2DMake(60.003805826814433, 30.372444832684813)]
    
    let points2 = [CLLocationCoordinate2DMake(60.000805826814433, 30.365466176872295),
                   CLLocationCoordinate2DMake(60.004625284079482, 30.365466120139067),
                   CLLocationCoordinate2DMake(60.004625284079482, 30.374444797471083),
                   CLLocationCoordinate2DMake(60.000805826814433, 30.374444832684813)]
        
    
    var ordinal = 0
    var venue: Venue?

    
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
        $0.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: MKCoordinateRegion(center: centerPosition, latitudinalMeters: 1000, longitudinalMeters: 1000)), animated: false)
        $0.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 0, maxCenterCoordinateDistance: 5000), animated: false)
        $0.setCenter(centerPosition, animated: true)
        $0.isPitchEnabled = false
        $0.pointOfInterestFilter = .excludingAll
        
        return $0
    }(MKMapView())
    
    func layoutViews() {
        mapContainerView = findViewOfType("MKScrollContainerView", inView: mapView)
        let center : UIView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .systemRed
            $0.layer.cornerRadius = 5
            return $0
        } (UIView())
        
        
        addSubview(mapView)
        addSubview(center)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            center.widthAnchor.constraint(equalToConstant: 10),
            center.heightAnchor.constraint(equalToConstant: 10),
            center.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            center.centerYAnchor.constraint(equalTo: mapView.centerYAnchor)
        ])
    }
    
    
    func loadIMDF() {
        let path = Bundle.main.resourceURL!.appendingPathComponent("IMDFData")
        
        venue =  IMDFDecoder.decode(path)
        mapView.addOverlay(venue!)
        mapView.addOverlays(venue!.buildings)
    }
    
    func onLevelChange(ordinal: Int) {
        self.ordinal = ordinal
        currentBuilding?.changeOrdinal(ordinal, mapView)
    }
    
    func nearestBuilding(position: CLLocationCoordinate2D) -> Building? {
        
        let centerPoint = MKMapPoint(position)
        let centerRect = MKMapRect(origin: centerPoint, size: MKMapSize(width: 0.001, height: 0.001))
        
        for builing in venue!.buildings {
            for polygon in builing.polygons {
                if polygon.intersects(centerRect) {
                    return builing;
                }
            }
        }
        
        var nearestBuilding: Building? = nil
        var nearestDistance: Double = Double.infinity
        
        for builing in venue!.buildings {
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
        
        return nearestBuilding
    }
    
    
    func updateMap(zoomLevel: Float) {
        
        guard let currentBuilding = currentBuilding else { return }
        if abs(lastZoom - zoomLevel) < Float.ulpOfOne { return }
        lastZoom = zoomLevel
    
        if zoomLevel > MIN_SHOW_ZOOM {
            currentBuilding.show(mapView)
        } else {
            currentBuilding.hide(mapView)
        }
    }
    
    
    func updateMap(nearestBuilding: Building?) {
        if let currentBuilding = currentBuilding {
            currentBuilding.hide(mapView)
        }
        
        if getZoom() > MIN_SHOW_ZOOM {
            nearestBuilding?.show(mapView)
        }
        
        currentBuilding = nearestBuilding
    }
    
    func updateMap(centerPosition: CLLocationCoordinate2D) {
        let nearestBuilding = nearestBuilding(position: centerPosition)
        if nearestBuilding != currentBuilding {
            updateMap(nearestBuilding: nearestBuilding)
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
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updateMap(centerPosition: mapView.centerCoordinate)
        updateMap(zoomLevel: getZoom())
    }
    

}

extension MapView {
    func getZoom() -> Float {
        // function returns current zoom of the map
        var angleCamera = getRotation()
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        let angleRad = Double.pi * angleCamera / 180 // map rotation in radians
        let width = Double(mapView.frame.size.width)
        let height = Double(mapView.frame.size.height)
        let heightOffset : Double = 20 // the offset (status bar height) which is taken by MapKit into consideration to calculate visible area height
        // calculating Longitude span corresponding to normal (non-rotated) width
        let spanStraight = width * mapView.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return Float(log2(360 * ((width / 128) / spanStraight)))
    }
    
    func getRotation() -> Double {
        // function gets current map rotation based on the transform values of MKScrollContainerView
        var rotation = fabs(180 * asin(Double(self.mapContainerView!.transform.b)) / Double.pi)
        if self.mapContainerView!.transform.b <= 0 {
            if self.mapContainerView!.transform.a < 0 {
                rotation = 180 - rotation
            }
        } else {
            if self.mapContainerView!.transform.a <= 0 {
                rotation = rotation + 180
            } else {
                rotation = 360 - rotation
            }
        }
        return rotation
    }

}
