//
//  AmenityAnnotationView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 10.01.2022.
//

import MapKit

class AmenityAnnotationView: BaseAnnotationView<AmenityAnnotation.DetailLevel> {
    override var annotation: MKAnnotation? {
        didSet {
            if let amenity = annotation as? AmenityAnnotation {
                imageView.sourceImage = amenity.sprite
            } else if let amenity = annotation as? EnviromentAmenityAnnotation {
                imageView.sourceImage = amenity.sprite
            }
            
            if let title = annotation?.title {
                label.text = title
            } else {
                label.text = nil
            }
            
            if let detail = annotation as? AmenityDetailLevel {
                detailLevel = detail.detailLevel
            } else {
                detailLevel = .min
            }
        }
    }
    
    lazy var caShapeLayer: CAShapeLayer = {
        let path: UIBezierPath = {
            $0.move(to: CGPoint(x: -10, y: -10))
            $0.addCurve(to: CGPoint(x: -1.5, y: -2), controlPoint1: CGPoint(x: -5, y: -8), controlPoint2: CGPoint(x: -3, y: -4))
            $0.addCurve(to: CGPoint(x: 1.5, y: -2), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 0, y: 0))
            $0.addCurve(to: CGPoint(x: 10, y: -10), controlPoint1: CGPoint(x: 3, y: -4), controlPoint2: CGPoint(x: 5, y: -8))
            
            $0.apply(CGAffineTransform(translationX: 3, y: 9))
            $0.apply(CGAffineTransform(scaleX: 6/20, y: 6/20))
            return $0
        }(UIBezierPath())
        
        $0.path = path.cgPath
        $0.fillColor = UIColor.systemBlue.cgColor
        
        return $0
    }(CAShapeLayer())
    
    lazy var shape: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.addSublayer(caShapeLayer)
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
    
    lazy var label: MapLabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .label
        
        $0.alpha = 0
        $0.isHidden = true
        $0.transform = CGAffineTransform(translationX: 0, y: -10).scaledBy(x: 0.5, y: 0.5)
        
        $0.strokeColor = Asset.Annotation.Colors.stroke.color
        return $0
    }(MapLabel())
    
    func setupLabel() {
        let darkmode = traitCollection.userInterfaceStyle == .dark
        
        label.strokeSize = darkmode ? 1.5 : 2.5
        label.font = .systemFont(ofSize: 12, weight: darkmode ? .bold : .semibold)
        label.setNeedsDisplay()
    }
    
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
        
        setupLabel()
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
                label.isHidden = false
                alpha = viewOpacity
                
                imageView.alpha = imageOpacity
                background.layer.cornerRadius = backgroundCornerRadius
                background.transform = backgroundTransform
                
                label.alpha = labelOpacity
                label.transform = labelTransform
                
                imageView.startAnim()
            }, completion: { _ in self.imageView.endAnim()})
        
            .animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: { [self] in
                miniPoint.isHidden = false
                miniPoint.transform = miniPointTransform
            })
        
            .animate(withDuration: 0.35, delay: 0.05, options: .curveEaseInOut, animations: { [self] in
                shape.transform = shapeTransform
            })
        
        deselectAnim
            .animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: { [self] in
                alpha = viewOpacity
                background.transform = backgroundTransform
                
                imageView.startAnim()
            }, completion: { _ in self.imageView.endAnim()})
        
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [self] in
                shape.transform = shapeTransform
                miniPoint.transform = miniPointTransform
            }, completion: { _ in self.miniPoint.hideIfZeroTransform() })
        
            .animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: { [self] in
                label.alpha = labelOpacity
                label.transform = labelTransform
                imageView.alpha = imageOpacity
                background.layer.cornerRadius = backgroundCornerRadius
                
            }, completion: { _ in
                self.label.hideIfZeroAlpha()
                self.hideIfZeroAlpha()
            })
    
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    
    override var detailLevelProcessor: DetailLevelProcessor<DetailLevelState> { AmenityAnnotation.levelProcessor }
    
    @available(iOS 14.0, *)
    override var defaultPriority: MKAnnotationViewZPriority { .init(rawValue: 600) }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        imageView.renderIfNeed()
    }
    
    override func boundingBox() -> CGRect {
        return background.frame.union(label.frame).offsetBy(dx: -frame.width / 2, dy: -frame.height / 2)
    }
    
    override func changeState(state: DetailLevelState, animate: Bool) {
        super.changeState(state: state, animate: animate)
        if isSelected { return }
        
        Animator().animate(withDuration: 0.3, animations: { [self] in
            background.transform = backgroundTransform
            imageView.alpha = imageOpacity
            background.layer.cornerRadius = backgroundCornerRadius
            alpha = viewOpacity
            if isHidden && alpha > 0 { isHidden = false }
        }, completion: { _ in
            self.hideIfZeroAlpha()
            self.imageView.renderIfNeed()
        }).play(animated: animate)
    }
    
    override func appearanceDidChange() {
        super.appearanceDidChange()
        
        caShapeLayer.fillColor = UIColor.systemBlue.cgColor
        setupLabel()
    }
}

extension AmenityAnnotationView {
    var labelOpacity: CGFloat {
        isSelected || isPinned ? 1 : 0
    }
    
    var viewOpacity: CGFloat {
        isSelected || isPinned || state != .hide ? 1 : 0
    }
    
    var miniPointTransform: CGAffineTransform {
        if isSelected { return .identity }
        if isPinned { return .one.scaled(scale: 0.5) }
        return .one.scaled(scale: 0)
    }
    
    var labelTransform: CGAffineTransform {
        if isSelected { return .identity }
        if isPinned { return CGAffineTransform(translationX: 0, y: -2) }
        
        return .one.scaled(scale: 0.5).translatedBy(x: 0, y: -10)
    }
    
    var imageOpacity: CGFloat {
        if isSelected || isPinned {
            return 1
        }
        
        return [.big, .normal].contains(state) ? 1.0 : 0
    }
    
    var shapeTransform: CGAffineTransform {
        isSelected || isPinned ? .one : .one.translatedBy(x: 0, y: -1).scaledBy(x: 1, y: 0)
    }
    
    var backgroundTransform: CGAffineTransform {
        var size: CGFloat {
            switch state {
            case .big:
                return 1.2
            case .normal:
                return 0.8
            case .hide, .min, .undefined:
                return 0.3
            }
        }
        
        if isSelected { return .one.scaled(scale: 2.5).translatedBy(x: 0, y: -15.5) }
        if isPinned { return .one.scaled(scale: 1.2).translatedBy(x: 0, y: -15.5) }
        
        return .one.scaled(scale: size)
    }
    
    var backgroundCornerRadius: CGFloat {
        if isSelected || isPinned { return 5 }
        return [.big, .normal].contains(state) ? 5 : 10
    }
}

