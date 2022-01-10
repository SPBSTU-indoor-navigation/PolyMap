//
//  PointAnnotationView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 10.01.2022.
//

import MapKit


class PointAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            if let title = annotation?.title {
                label.text = title
            } else {
                label.text = nil
            }
        }
    }
    
    lazy var point: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 5
        return $0
    }(UIView())
    
    lazy var label: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.layer.shadowOpacity = 0.4
        $0.layer.shadowOffset = .zero
        $0.layer.shadowRadius = 5
        $0.layer.shouldRasterize = true
        
        $0.textColor = .label
        
        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        return $0
    }(UILabel())
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        if #available(iOS 14.0, *) {
            zPriority = MKAnnotationViewZPriority(rawValue: 4)
        }
        
        addSubview(point)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            point.widthAnchor.constraint(equalToConstant: 8),
            point.heightAnchor.constraint(equalToConstant: 8),
            point.centerXAnchor.constraint(equalTo: centerXAnchor),
            point.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: point.bottomAnchor, constant: 2)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

