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
    var venue: Venue?
    var levels: [Level] = []
    var currentLevelFeatures = [StylableFeature]()
    var currentLevelOverlays = [MKOverlay]()
    var currentLevelAnnotations = [MKAnnotation]()
    let pointAnnotationViewIdentifier = "PointAnnotationView"
    let labelAnnotationViewIdentifier = "LabelAnnotationView"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        map.delegate = self
        loadIMDF()
        
        layoutViews()
        showFeaturesForOrdinal(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var map: MKMapView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
    
        
//        $0.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: MKCoordinateRegion(center: centerPosition, latitudinalMeters: 1000, longitudinalMeters: 1000)), animated: false)
//
//        $0.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 0, maxCenterCoordinateDistance: 5000), animated: false)
//        $0.setCenter(centerPosition, animated: true)
        $0.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: pointAnnotationViewIdentifier)
        $0.register(LabelAnnotationView.self, forAnnotationViewWithReuseIdentifier: labelAnnotationViewIdentifier)
        $0.pointOfInterestFilter = .excludingAll
        
        return $0
    }(MKMapView())
    
    func layoutViews() {
        
        addSubview(map)
        
        NSLayoutConstraint.activate([
            map.leadingAnchor.constraint(equalTo: leadingAnchor),
            map.trailingAnchor.constraint(equalTo: trailingAnchor),
            map.topAnchor.constraint(equalTo: topAnchor),
            map.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
