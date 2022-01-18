//
//  AmenityAnnotationView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 10.01.2022.
//

import MapKit

class AmenityAnnotationView: MKAnnotationView, AnnotationMapSize {
    
    var state: DetailLevelState = .normal
    var detailLevel: Int = 0
    
    override var annotation: MKAnnotation? {
        didSet {
            if let amenity = annotation as? AmenityAnnotation {
                imageView.image = UIImage(named: amenity.category.rawValue) ?? Asset.Annotation.Amenity.default.image
            } else if let amenity = annotation as? EnviromentAmenityAnnotation {
                imageView.image = UIImage(named: amenity.category.rawValue) ?? Asset.Annotation.Amenity.default.image
            }
            
            if let title = annotation?.title {
                label.text = title
            } else {
                label.text = nil
            }
            
            if let detail = annotation as? DetailLevel {
                detailLevel = detail.detailLevel()
            } else {
                detailLevel = 0
            }
        }
    }
    
    var selectAnim = Animator(),
        deselectAnim = Animator(),
        min = Animator(),
        big = Animator(),
        hide = Animator(),
        normal = Animator()
    
    lazy var shape: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let t = CAShapeLayer()
        
        let path: UIBezierPath = {
            $0.move(to: CGPoint(x: -10, y: -10))
            $0.addCurve(to: CGPoint(x: -1.5, y: -2), controlPoint1: CGPoint(x: -5, y: -8), controlPoint2: CGPoint(x: -3, y: -4))
            $0.addCurve(to: CGPoint(x: 1.5, y: -2), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 0, y: 0))
            $0.addCurve(to: CGPoint(x: 10, y: -10), controlPoint1: CGPoint(x: 3, y: -4), controlPoint2: CGPoint(x: 5, y: -8))
            
            $0.apply(CGAffineTransform(translationX: 3, y: 9))
            $0.apply(CGAffineTransform(scaleX: 6/20, y: 6/20))
            return $0
        }(UIBezierPath())
        
        t.path = path.cgPath
        t.fillColor = UIColor.systemBlue.cgColor
        
        $0.layer.addSublayer(t)
        
        $0.transform = CGAffineTransform(translationX: 0, y: -1).scaledBy(x: 1, y: 0)
        return $0
    }(UIView())
    
    lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = .white
        $0.layer.minificationFilter = .trilinear
        $0.layer.minificationFilterBias = 0.1
        return $0
    }(UIImageView())
    
    lazy var background: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 5
        $0.addSubview(imageView)
        $0.addSubview(shape)
        return $0
    }(UIView())
    
    lazy var label: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .label

        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        
        $0.alpha = 0
        $0.isHidden = true
        $0.transform = CGAffineTransform(translationX: 0, y: -10).scaledBy(x: 0.5, y: 0.5)
        return $0
    }(UILabel())
    
    lazy var miniPoint: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 3
        $0.transform = CGAffineTransform(scaleX: 0, y: 0)
        return $0
    }(UIView())
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        addSubview(miniPoint)
        addSubview(label)
        addSubview(background)
        
        NSLayoutConstraint.activate([
            background.widthAnchor.constraint(equalToConstant: 20),
            background.heightAnchor.constraint(equalToConstant: 20),
            background.centerXAnchor.constraint(equalTo: centerXAnchor),
            background.centerYAnchor.constraint(equalTo: centerYAnchor),
            miniPoint.heightAnchor.constraint(equalToConstant: 6),
            miniPoint.widthAnchor.constraint(equalToConstant: 6),
            miniPoint.centerXAnchor.constraint(equalTo: centerXAnchor),
            miniPoint.centerYAnchor.constraint(equalTo: centerYAnchor),
            shape.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            shape.topAnchor.constraint(equalTo: background.bottomAnchor),
            shape.widthAnchor.constraint(equalToConstant: 2),
            shape.heightAnchor.constraint(equalToConstant: 1),
            imageView.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 3),
            imageView.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -3),
            imageView.topAnchor.constraint(equalTo: background.topAnchor, constant: 3),
            imageView.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -3),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: centerYAnchor, constant: 3)
        ])
        
        selectAnim
            .animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [self] in
                isHidden = false
                imageView.alpha = 1
                background.layer.cornerRadius = 5
                background.transform = CGAffineTransform(scaleX: 2.5, y: 2.5).translatedBy(x: 0, y: -15.5)
                
                label.isHidden = false
                label.alpha = 1
                label.transform = .identity
            })
            .animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: { [self] in
                miniPoint.isHidden = false
                miniPoint.transform = .identity
            })
            .animate(withDuration: 0.35, delay: 0.05, options: .curveEaseInOut, animations: { [self] in
                shape.transform = .identity.scaledBy(x: 1, y: 1)
            })
        
        deselectAnim
            .animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: { [self] in
                isHidden = false
                var size = 1.0
                switch state {
                case .big:
                    size = 1.2
                case .normal:
                    size = 1.0
                case .hide, .min:
                    size = 0.3
                }
                background.transform = CGAffineTransform(scaleX: size, y: size)
                if state == .hide { alpha = 0 }
            })
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [self] in
                shape.transform = CGAffineTransform(translationX: 0, y: -1).scaledBy(x: 1, y: 0)
                miniPoint.transform = CGAffineTransform(scaleX: 0, y: 0)
            }, completion: { _ in self.miniPoint.isHidden = true })
            .animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: { [self] in
                label.alpha = 0
                label.transform = CGAffineTransform(translationX: 0, y: -10).scaledBy(x: 0.5, y: 0.5)
                if [.hide, .min].contains(state) {
                    imageView.alpha = 0
                    background.layer.cornerRadius = 10
                }
            }, completion: { _ in
                self.label.isHidden = true
                self.isHidden = self.state == .hide
                
            })
    
        hide
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [self] in
                alpha = 0
                imageView.alpha = 0
                background.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                background.layer.cornerRadius = 10
            }, completion: { _ in self.isHidden = true})
        
        min
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [self] in
                isHidden = false
                alpha = 1
                imageView.alpha = 0
                background.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                background.layer.cornerRadius = 10
            })
        
        normal
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [self] in
                isHidden = false
                alpha = 1
                imageView.alpha = 1
                background.transform = .identity
                background.layer.cornerRadius = 5
            })
        
        big
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [self] in
                isHidden = false
                alpha = 1
                imageView.alpha = 1
                background.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                background.layer.cornerRadius = 5
            })
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if #available(iOS 14.0, *) {
            zPriority = MKAnnotationViewZPriority(rawValue: 900)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if selected {
            selectAnim.play(animated: animated)
        } else {
            deselectAnim.play(animated: animated)
        }
    }
    
    func changeState(state: DetailLevelState, animate: Bool) {
        self.state = state
        
        if isSelected { return }
        
        if state == .big {
            big.play(animated: animate)
        } else if state == .normal {
            normal.play(animated: animate)
        } else if state == .min {
            min.play(animated: animate)
        } else if state == .hide {
            hide.play(animated: animate)
        }
    }
    
    func update(mapSize: Float, animate: Bool) {
        
        let targetState = defaultDetailLevelProcessor.evaluate(forDetailLevel: detailLevel, mapSize: mapSize) ?? .normal
        
        if state != targetState {
            changeState(state: targetState, animate: animate)
        }
    }
}

