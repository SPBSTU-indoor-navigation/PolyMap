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
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension MapView: MKMapViewDelegate {
    
}

