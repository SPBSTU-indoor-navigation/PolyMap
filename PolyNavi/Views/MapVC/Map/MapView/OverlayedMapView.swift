//
//  OverlayedMapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 22.01.2022.
//

import MapKit

class OverlayedMapView: PinnableMapView {
    
    var onPan: ((UIPanGestureRecognizer) -> Void)?
    var onAnnotationAdd: ((_ annotation: MKAnnotation) -> Void)?
    var currentOverlays: [MKShape:CustomOverlay] = [:]
    
    var waitToAddAnnotations: [MKAnnotation] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        panGR.delegate = self
        panGR.maximumNumberOfTouches = 1
        addGestureRecognizer(panGR)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func addAnnotation(_ annotation: MKAnnotation) {
        waitToAddAnnotations.append(annotation)
        
        super.addAnnotation(annotation)
        onAnnotationAdd?(annotation)
    }
    
    override func addAnnotations(_ annotations: [MKAnnotation]) {
        waitToAddAnnotations.append(contentsOf: annotations)
        
        for (i, annotations) in annotations.chunked(into: 10).enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) / 50.0)) {
                
                let annotations = annotations.filter({ annotation in self.waitToAddAnnotations.contains(where: { $0 === annotation }) })
                
                super.addAnnotations(annotations)
                for annotation in annotations {
                    self.onAnnotationAdd?(annotation)
                }
            }
        }
    }
    
    override func removeAnnotations(_ annotations: [MKAnnotation]) {
        super.removeAnnotations(annotations)
        waitToAddAnnotations = waitToAddAnnotations.filter({ annotation in
            !annotations.contains(where: { $0 === annotation })
        })
    }
    
    override func removeAnnotation(_ annotation: MKAnnotation) {
        super.removeAnnotation(annotation)
        waitToAddAnnotations = waitToAddAnnotations.filter({ annotation !== $0 })
    }
    
    @objc
    private func panAction(_ sender: UIPanGestureRecognizer) {
        onPan?(sender)
    }
    
    func addOverlays(_ overlays: [CustomOverlay]) {
        for overlay in overlays {
            currentOverlays[overlay.geometry as MKShape] = overlay
        }
        
        addOverlays(overlays.map({ $0.geometry }))
    }
    
    func addOverlay(_ overlay: CustomOverlay) {
        currentOverlays[overlay.geometry as MKShape] = overlay
        
        addOverlay(overlay.geometry)
    }
    
    func removeOverlays(_ overlays: [CustomOverlay]) {
        removeOverlays(overlays.map({ $0.geometry }))
    }
    
    func removeOverlay(_ overlays: CustomOverlay) {
        removeOverlay(overlays.geometry)
    }
    
    func customOverlay(for overlay: MKOverlay) -> CustomOverlay? {
        if let shape = overlay as? MKShape {
            return currentOverlays[shape]
        }
        
        return nil
    }
}

extension OverlayedMapView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
