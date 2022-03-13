//
//  AmenityAnnotationView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 10.01.2022.
//

import MapKit

class AmenityAnnotationView: MKAnnotationView, AnnotationMapSize, BoundingBox {
    var state: DetailLevelState = .undefined
    var detailLevel: Int = 0
    
    override var annotation: MKAnnotation? {
        didSet {
            if let amenity = annotation as? AmenityAnnotation {
                imageView.sourceImage = UIImage(named: amenity.properties.category.rawValue) ?? Asset.Annotation.Amenity.default.image
            } else if let amenity = annotation as? EnviromentAmenityAnnotation {
                imageView.sourceImage = UIImage(named: amenity.properties.category.rawValue) ?? Asset.Annotation.Amenity.default.image
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
    
    var backgroundSize: CGFloat {
        get {
            switch state {
            case .big:
                return 1.2
            case .normal:
                return 0.8
            case .hide, .min, .undefined:
                return 0.3
            }
        }
    }
    
    var imageAlpha: CGFloat {
        get {
            return [.big, .normal].contains(state) ? 1.0 : 0
        }
    }
    
    var backgroundCornerRadius: CGFloat {
        get {
            return [.big, .normal].contains(state) ? 5 : 10
        }
    }
    
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
    
    lazy var imageView: ScaledImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
        return $0
    }(ScaledImageView())
    
    lazy var background: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 5
        $0.addSubview(imageView)
        $0.addSubview(shape)
        return $0
    }(UIView())
    
    lazy var label: THLabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .label

        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        
        $0.alpha = 0
        $0.isHidden = true
        $0.transform = CGAffineTransform(translationX: 0, y: -10).scaledBy(x: 0.5, y: 0.5)
        
        $0.strokeSize = 0.5
        $0.strokeColor = Asset.Annotation.Colors.stroke.color
        return $0
    }(THLabel())
    
    lazy var miniPoint: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 3
        $0.transform = CGAffineTransform(scaleX: 0, y: 0)
        return $0
    }(UIView())
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
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
                
                imageView.startAnim()
            }, completion: { _ in self.imageView.endAnim()})
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
                background.transform = CGAffineTransform(scaleX: backgroundSize, y: backgroundSize)
                if state == .hide { alpha = 0 }
                imageView.startAnim()
            }, completion: { _ in self.imageView.endAnim()})
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
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func boundingBox() -> CGRect {
        return background.frame.union(label.frame).offsetBy(dx: -frame.width / 2, dy: -frame.height / 2)
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        imageView.renderIfNeed()
        
        if #available(iOS 14.0, *) {
            zPriority = MKAnnotationViewZPriority(rawValue: 700)
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
        
        let change = { [self] in
            background.transform = CGAffineTransform(scaleX: backgroundSize, y: backgroundSize)
            imageView.alpha = imageAlpha
            background.layer.cornerRadius = backgroundCornerRadius
            alpha = state == .hide ? 0 : 1
            if state != .hide {
                isHidden = false
                alpha = 1
            } else {
                alpha = 0
            }
        }
        
        let completion = {
            if self.state == .hide {
                self.isHidden = true
            }
            self.imageView.renderIfNeed()
        }
        
        if animate {
            UIView.animate(withDuration: 0.3, animations: {
                change()
            }, completion: { _ in completion() })
        } else {
            change()
            completion()
        }
    }
    
    func update(mapSize: Float, animate: Bool) {
        
        let targetState = AmenityAnnotation.levelProcessor.evaluate(forDetailLevel: detailLevel, mapSize: mapSize) ?? .normal
        
        if state != targetState {
            changeState(state: targetState, animate: animate)
        }
    }
}

