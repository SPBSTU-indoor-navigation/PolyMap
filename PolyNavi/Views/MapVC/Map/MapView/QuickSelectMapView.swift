//
//  FastSelectMapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 24.06.2022.
//

import MapKit

class QuickSelectMapView: MKMapView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTouchDown)))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc func didTouchDown(gesture: UITapGestureRecognizer) {        
        if let annotationView = hitTest(gesture.location(in: self), with: nil) as? MKAnnotationView,
           let annotation = annotationView.annotation {
            selectAnnotation(annotation, animated: true)
        } else {
            if let selectedAnnotation = selectedAnnotations.first {
                deselectAnnotation(selectedAnnotation, animated: true)
            }
        }
        
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}
