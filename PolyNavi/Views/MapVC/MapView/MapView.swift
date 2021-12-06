//
//  MapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 01.11.2021.
//

import MapKit

class MainMapView: UIView, MKMapViewDelegate {
    
    private lazy var mapView: MKMapView = {
        $0.mapType = MKMapType.standard
        $0.isZoomEnabled = true
        $0.isScrollEnabled = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(MKMapView())


    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainMapView {
    private func setViews() {
        
        
//        view.addSubview(mapView)
//
//        NSLayoutConstraint.activate([
//            mapView.topAnchor.constraint(equalTo: view.topAnchor),
//            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
    }
    
}
