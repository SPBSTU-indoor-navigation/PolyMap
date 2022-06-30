//
//  PinnableMapView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 19.03.2022.
//

import MapKit


protocol Pinnable {
    var isPinned: Bool { get }
    func setPinned(_ pinned: Bool, animated: Bool)
}

class PinnableAnnotationView: MKAnnotationView, Pinnable {
    var isPinned: Bool = false
    
    private var _unpinnedZPriority: Any? = nil
    @available(iOS 14.0, *)
    var unpinnedZPriority: MKAnnotationViewZPriority {
        get {
            return _unpinnedZPriority as? MKAnnotationViewZPriority ?? .defaultUnselected
        }
        
        set {
            _unpinnedZPriority = newValue
            zPriority = isPinned ? .defaultSelected : newValue
        }
    }
    
    func setPinned(_ pinned: Bool, animated: Bool) {
        
        if #available(iOS 14.0, *) {
            if pinned {
                zPriority = .init(rawValue: 900)
            } else {
                zPriority = unpinnedZPriority
            }
        }
        isPinned = pinned
    }
}

class PinnableMapView: QuickSelectMapView {
    var pinnedAnnotations: [MKAnnotation] = []
    
    func pinAnnotation(_ annotation: MKAnnotation, animated: Bool) {
        if !pinnedAnnotations.contains(where: { annotation.isEqual($0) }) {
            pinnedAnnotations.append(annotation)
            if annotations.contains(where: { annotation.isEqual($0) }) {
                if let view = view(for: annotation),
                   let pinnable = view as? Pinnable {
                    pinnable.setPinned(true, animated: animated)
                }
            }
        }
    }
    
    func unpinAnnotation(_ annotation: MKAnnotation, animated: Bool) {
        if pinnedAnnotations.contains(where: { annotation.isEqual($0) }) {
            pinnedAnnotations = pinnedAnnotations.filter({ !annotation.isEqual($0) })
            if annotations.contains(where: { annotation.isEqual($0) }) {
                if let view = view(for: annotation),
                   let pinndable = view as? Pinnable {
                    pinndable.setPinned(false, animated: animated)
                }
            }
        }
    }
    
    override func dequeueReusableAnnotationView(withIdentifier identifier: String, for annotation: MKAnnotation) -> MKAnnotationView {
        let view = super.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        
        if let pinnable = view as? Pinnable {
            pinnable.setPinned(pinnedAnnotations.contains(where: { annotation.isEqual($0) }), animated: false)
        }
        
        return view
    }
    
    
}
