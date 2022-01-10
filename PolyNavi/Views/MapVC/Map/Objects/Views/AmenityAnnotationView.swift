//
//  AmenityAnnotationView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 10.01.2022.
//

import MapKit

class AmenityAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            if let amenity = annotation as? AmenityAnnotation {
                imageView.image = UIImage(named: amenity.category.rawValue) ?? Asset.Annotation.Amenity.default.image
            }
        }
    }
    
    lazy var background: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 5
        $0.addShadow()
        return $0
    }(UIView())
    
    lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        if #available(iOS 14.0, *) {
            zPriority = MKAnnotationViewZPriority(rawValue: 5)
        }
        
        addSubview(background)
        background.addSubview(imageView)
        
        
        NSLayoutConstraint.activate([
            background.widthAnchor.constraint(equalToConstant: 20),
            background.heightAnchor.constraint(equalToConstant: 20),
            background.centerXAnchor.constraint(equalTo: centerXAnchor),
            background.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 15),
            imageView.widthAnchor.constraint(equalToConstant: 15),
            imageView.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: background.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
