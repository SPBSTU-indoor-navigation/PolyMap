//
//  PointAnnotationView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 10.01.2022.
//

import MapKit


protocol AnnotationMapSize {
    func update(mapSize: Float, animate: Bool)
}

class PointAnnotationView: MKAnnotationView, AnnotationMapSize {
    private var annotationDetailState: UnitAnnotation.DetailLevel = .pointSecondary
    override var annotation: MKAnnotation? {
        didSet {
            if let unit = annotation as? UnitAnnotation {
                annotationDetailState = unit.detailLevel
                
                
                var imageName: String? = nil
                switch unit.category {
                case .classroom: imageName = "classroom"
                case .laboratory: imageName = "laboratorium"
                case .auditorium: imageName = "lecture"
                default: break
                }
                imageView.image = UIImage(named: imageName ?? unit.category.rawValue)
                imageView.alpha = imageOpacity
                
                
                var colorName: String
                switch unit.category {
                case .restroom, .restroomMale, .restroomFemale: colorName = "restroom"
                default: colorName = unit.category.rawValue
                }
                changePointColor(UIColor(named: colorName + "-annotation") ?? .systemOrange)
                
            }
            
            if let title = annotation?.title {
                label.text = title
                label.isEnabled = true
            } else {
                label.text = nil
                label.isEnabled = false
            }
            
            label.alpha = labelOpacity
            point.transform = CGAffineTransform(scaleX: pointSize, y: pointSize)
            label.transform = labelTransform
        }
    }
    
    var state: DetailLevelState = .undefined
    
    var pointSize: CGFloat {
        get {
            
            if [.circleWithoutLabel].contains(annotationDetailState) {
                switch state {
                case .big: return 2.0
                default: return 1.6
                }
            } else {
                switch state {
                case .big, .normal, .min: return 0.8
                case .hide, .undefined: return 0.6
                }
            }
        }
    }
    
    var labelOpacity: CGFloat {
        if [.circleWithoutLabel].contains(annotationDetailState) {
            return 0.0
        }
        return [.normal, .big].contains(state) ? 1.0 : 0.0
    }
    
    var labelTransform: CGAffineTransform {
        if [.circleWithoutLabel].contains(annotationDetailState) {
            return CGAffineTransform(translationX: 0, y: -12).scaledBy(x: 0.5, y: 0.5)
        }
        return CGAffineTransform.identity
    }
    
    var imageOpacity: CGFloat {
        if [.circleWithoutLabel].contains(annotationDetailState) {
            return 1.0
        }
        return 0.0
    }
    
    var selectAnim = Animator()
    var deselectAnim = Animator()
    
    func changePointColor(_ color: UIColor) {
        point.backgroundColor = color
        miniPoint.backgroundColor = color
        caShapeLayer.fillColor = color.cgColor
    }
    
    
    lazy var caShapeLayer: CAShapeLayer = {
        let path: UIBezierPath = {
            $0.move(to: CGPoint(x: -10, y: -10))
            $0.addCurve(to: CGPoint(x: -1.5, y: -2), controlPoint1: CGPoint(x: -5, y: -8), controlPoint2: CGPoint(x: -3, y: -4))
            $0.addCurve(to: CGPoint(x: 1.5, y: -2), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 0, y: 0))
            $0.addCurve(to: CGPoint(x: 10, y: -10), controlPoint1: CGPoint(x: 3, y: -4), controlPoint2: CGPoint(x: 5, y: -8))
            
            $0.apply(CGAffineTransform(translationX: 10, y: 9))
            $0.apply(CGAffineTransform(scaleX: 2/20, y: 2/20))
            return $0
        }(UIBezierPath())
        
        $0.path = path.cgPath
        $0.fillColor = UIColor.systemOrange.cgColor
        
        return $0
    }(CAShapeLayer())

    
    lazy var shape: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.addSublayer(caShapeLayer)
        $0.transform = CGAffineTransform(translationX: 0, y: -1).scaledBy(x: 1, y: 0)
        return $0
    }(UIView())
    
    lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.minificationFilter = .trilinear
        $0.layer.minificationFilterBias = 0.1
        $0.alpha = 0
        return $0
    }(UIImageView())
    
    lazy var point: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 5
        $0.layer.borderColor = UIColor.systemBackground.cgColor
        $0.layer.borderWidth = 0.5
        
        $0.addSubview(shape)
        $0.addSubview(imageView)
        return $0
    }(UIView())
    
    lazy var miniPoint: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 3
        $0.transform = CGAffineTransform(scaleX: 0, y: 0)
        return $0
    }(UIView())
    
    lazy var label: THLabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .label
        
        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        
        
        $0.strokeSize = 0.5
        $0.strokeColor = Asset.Annotation.Colors.stroke.color
        return $0
    }(THLabel())
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame.size = CGSize(width: 10, height: 10)
        addSubview(miniPoint)
        addSubview(point)
        addSubview(label)
        miniPoint.isHidden = true
        
        
        NSLayoutConstraint.activate([
            point.centerXAnchor.constraint(equalTo: centerXAnchor),
            point.centerYAnchor.constraint(equalTo: centerYAnchor),
            point.widthAnchor.constraint(equalToConstant: 10),
            point.heightAnchor.constraint(equalToConstant: 10),
            label.topAnchor.constraint(equalTo: centerYAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            miniPoint.heightAnchor.constraint(equalToConstant: 6),
            miniPoint.widthAnchor.constraint(equalToConstant: 6),
            miniPoint.centerXAnchor.constraint(equalTo: centerXAnchor),
            miniPoint.centerYAnchor.constraint(equalTo: centerYAnchor),
            shape.centerXAnchor.constraint(equalTo: point.centerXAnchor),
            shape.topAnchor.constraint(equalTo: point.bottomAnchor),
            shape.widthAnchor.constraint(equalToConstant: 2),
            shape.heightAnchor.constraint(equalToConstant: 1),
            imageView.topAnchor.constraint(equalTo: point.topAnchor, constant: 2),
            imageView.bottomAnchor.constraint(equalTo: point.bottomAnchor, constant: -2),
            imageView.trailingAnchor.constraint(equalTo: point.trailingAnchor, constant: -2),
            imageView.leadingAnchor.constraint(equalTo: point.leadingAnchor, constant: 2),
        ])
        
        selectAnim
            .animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [self] in
                point.transform = CGAffineTransform(scaleX: 7, y: 7).translatedBy(x: 0, y: -6.8)
                label.transform = CGAffineTransform(translationX: 0, y: -0.5)
                imageView.alpha = 1.0
            })
            .animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: { [self] in
                miniPoint.isHidden = false
                miniPoint.transform = .identity
            })
            .animate(withDuration: 0.2, delay: 0.05, options: .curveEaseInOut, animations: { [self] in
                shape.transform = .identity.scaledBy(x: 1, y: 1)
                label.alpha = 1.0
            })
            .animate(withDuration: 0.05, delay: 0, options: .curveEaseIn, animations: { [self] in
                point.layer.borderColor = UIColor.systemBackground.withAlphaComponent(0).cgColor
            })
        
        deselectAnim
            .animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [self] in
                point.transform = .identity.scaledBy(x: pointSize, y: pointSize)
            })
            .animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [self] in
                label.alpha = labelOpacity
                label.transform = labelTransform
            })
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [self] in
                shape.transform = CGAffineTransform(translationX: 0, y: -1).scaledBy(x: 1, y: 0)
                miniPoint.transform = CGAffineTransform(scaleX: 0, y: 0)
                

                imageView.alpha = imageOpacity
                
                point.layer.borderColor = UIColor.systemBackground.cgColor
            }, completion: { _ in self.miniPoint.isHidden = true })
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if #available(iOS 14.0, *) {
            zPriority = MKAnnotationViewZPriority(rawValue: 500)
        }
    }
    
    func changeState(state: DetailLevelState, animate: Bool) {
        self.state = state
        
        if isSelected { return }
        
        let change = { [self] in
            label.transform = labelTransform
            label.alpha = labelOpacity
            point.transform = CGAffineTransform(scaleX: pointSize, y: pointSize)
        }
        
        if animate {
            UIView.animate(withDuration: 0.1, animations: {
                change()
            })
        } else {
            change()
        }
    }
    
    func update(mapSize: Float, animate: Bool) {
        let targetState = UnitAnnotation.levelProcessor.evaluate(forDetailLevel: annotationDetailState.rawValue, mapSize: mapSize) ?? .normal
        
        if state != targetState {
            changeState(state: targetState, animate: animate)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        if selected {
            selectAnim.play(animated: animated)
        } else {
            deselectAnim.play(animated: animated)
        }
    }
                

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                
                point.layer.borderColor = UIColor.systemBackground.withAlphaComponent(point.layer.borderColor?.alpha ?? 0).cgColor
                caShapeLayer.fillColor = point.backgroundColor?.cgColor
            }
        }
    }
}
