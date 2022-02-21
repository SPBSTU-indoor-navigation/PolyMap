//
//  OverlayedMapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 22.01.2022.
//

import MapKit

class OverlayedMapView: MKMapView {
    
    var onPan: ((UIPanGestureRecognizer) -> Void)?
    var currentOverlays: [MKShape:CustomOverlay] = [:]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        panGR.delegate = self
        addGestureRecognizer(panGR)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
