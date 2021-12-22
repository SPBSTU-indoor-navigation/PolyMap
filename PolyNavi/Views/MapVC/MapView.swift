//
//  MapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 15.11.2021.
//

import UIKit
import MapKit

class MapView: UIView {
    
    let centerPosition = CLLocationCoordinate2D(latitude: 60.00385, longitude: 30.37539)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mapView.delegate = self
        loadIMDF()
        
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadIMDF() {
        _ = Bundle.main.resourceURL!.appendingPathComponent("IMDFData")
    }
    
    lazy var mapView: MKMapView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: MKCoordinateRegion(center: centerPosition, latitudinalMeters: 1000, longitudinalMeters: 1000)), animated: false)
        $0.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 0, maxCenterCoordinateDistance: 5000), animated: false)
        $0.setCenter(centerPosition, animated: true)
        $0.pointOfInterestFilter = .excludingAll
        
        return $0
    }(MKMapView())
    
    func layoutViews() {
        
        addSubview(mapView)
        
//        [
//            30.370466176872295,
//            60.001805826814433
//        ],
//        [
//            30.370466120139067,
//            60.002525284079482
//        ],
//        [
//            30.372444797471083,
//            60.002525284079482
//        ],
//        [
//            30.372444832684813,
//            60.001805826814433
//        ],
//        [
//            30.370466176872295,
//            60.001805826814433
//        ]
        
        var points = [CLLocationCoordinate2DMake(60.001805826814433, 30.370466176872295),
                      CLLocationCoordinate2DMake(60.002525284079482, 30.370466120139067),
                      CLLocationCoordinate2DMake(60.002525284079482, 30.372444797471083),
                      CLLocationCoordinate2DMake(60.001805826814433, 30.372444832684813)]
        
//        mapView.addOverlay(Venue(coordinates: &points, count: points.count))
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

class Venue: MKPolygon {
    class Renderer: MKPolygonRenderer {
        override init(overlay: MKOverlay) {
            super.init(overlay: overlay)

            strokeColor = .magenta
            lineWidth = 5
            fillColor = .systemBlue
        }

//        override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
//            super.draw(mapRect, zoomScale: zoomScale, in: context)
//        }


        override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
            return zoomScale > 0.1 ? true : false
        }

    }

    func getOverlay() -> MKOverlayRenderer {
        return Renderer(overlay: self)
    }
}



extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is Venue {
            return (overlay as! Venue).getOverlay()
        }
        return MKPolygonRenderer(overlay: overlay)

    }

}

