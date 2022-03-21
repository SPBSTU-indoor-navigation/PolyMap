//
//  PointAnnotationView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 10.01.2022.
//

import MapKit

class PointAnnotationView: BaseAnnotationView<OccupantAnnotation.DetailLevel> {
    override var annotation: MKAnnotation? {
        didSet {
            if let unit = annotation as? OccupantAnnotation {
                detailLevel = unit.detailLevel
                
                var imageName: String? = nil
                switch unit.properties.category {
                case .classroom: imageName = "classroom"
                case .laboratory: imageName = "laboratorium"
                case .auditorium: imageName = "lecture"
                default: break
                }
                imageView.sourceImage = UIImage(named: imageName ?? unit.properties.category.rawValue)
                imageView.alpha = imageOpacity
                
                
                var colorName: String
                switch unit.properties.category {
                case .restroom, .restroomMale, .restroomFemale: colorName = "restroom"
                default: colorName = unit.properties.category.rawValue
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
            point.transform = pointTransform
            label.transform = labelTransform
        }
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
    
    lazy var imageView: ScaledImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
        $0.alpha = 0
        return $0
    }(ScaledImageView())
    
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
            
            imageView.centerXAnchor.constraint(equalTo: point.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: point.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: point.widthAnchor, constant: -4),
            imageView.heightAnchor.constraint(equalTo: point.heightAnchor, constant: -4),
        ])
        
        selectAnim
            .animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [self] in
                point.transform = pointTransform
                label.transform = labelTransform
                imageView.alpha = 1.0
                imageView.startAnim()
            }, completion: { _ in self.imageView.endAnim()})
            .animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: { [self] in
                miniPoint.isHidden = false
                miniPoint.transform = miniPointTransform
            })
            .animate(withDuration: 0.2, delay: 0.05, options: .curveEaseInOut, animations: { [self] in
                shape.transform = pointShapeTransform
                label.alpha = labelOpacity
            })
            .animate(withDuration: 0.05, delay: 0, options: .curveEaseIn, animations: { [self] in
                point.layer.borderColor = borderColor
            })
        
        deselectAnim
            .animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [self] in
                point.transform = pointTransform
                imageView.startAnim()
            }, completion: { _ in self.imageView.endAnim()})
            .animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [self] in
                label.alpha = labelOpacity
                label.transform = labelTransform
            })
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [self] in
                shape.transform = pointShapeTransform
                miniPoint.transform = miniPointTransform
                
                imageView.alpha = imageOpacity
                
                point.layer.borderColor = borderColor
            }, completion: { _ in self.miniPoint.isHidden = self.miniPoint.transform == .zero })
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func changePointColor(_ color: UIColor) {
        point.backgroundColor = color
        miniPoint.backgroundColor = color
        caShapeLayer.fillColor = color.cgColor
    }
    
    override var detailLevelProcessor: DetailLevelProcessor<DetailLevelState> { OccupantAnnotation.levelProcessor }
    
    @available(iOS 14.0, *)
    override var defaultPriority: MKAnnotationViewZPriority { .init(rawValue: 500) }
    
    override func changeState(state: DetailLevelState, animate: Bool) {
        super.changeState(state: state, animate: animate)
        
        if isSelected { return }
        
        Animator().animate(withDuration: 0.1, animations: { [self] in
            label.transform = labelTransform
            label.alpha = labelOpacity
            point.transform = pointTransform
        }, completion: { _ in
            self.imageView.renderIfNeed()
        }).play(animated: animate)
    }
    
    override func boundingBox() -> CGRect {
        return point.frame.union(label.frame).offsetBy(dx: -frame.width / 2, dy: -frame.height / 2)
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        imageView.renderIfNeed()
    }
    
    override func appearanceDidChange() {
        super.appearanceDidChange()
        point.layer.borderColor = UIColor.systemBackground.withAlphaComponent(point.layer.borderColor?.alpha ?? 0).cgColor
        caShapeLayer.fillColor = point.backgroundColor?.cgColor
    }
}

extension PointAnnotationView {
    var pointTransform: CGAffineTransform {
        var normalScale: CGFloat {
            if [.circleWithoutLabel].contains(detailLevel) {
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
        
        if isSelected { return .one.scaled(scale: 7.0).translatedBy(x: 0, y: -6.8) }
        if isPinned { return .one.scaled(scale: 3.0).translatedBy(x: 0, y: -6.8) }
        
        return .one.scaled(scale: normalScale)
    }
    
    var miniPointTransform: CGAffineTransform {
        var size: CGFloat {
            if isSelected { return 1 }
            if isPinned { return 0.5 }
            return 0
        }
        return .one.scaled(scale: size)
    }
    
    var pointShapeTransform: CGAffineTransform {
        if isSelected || isPinned {
            return .identity.scaledBy(x: 1, y: 1)
        }
        return CGAffineTransform(translationX: 0, y: -1).scaledBy(x: 1, y: 0)
    }
    
    var borderColor: CGColor {
        return UIColor.systemBackground.withAlphaComponent(isSelected || isPinned ? 0 : 1).cgColor
    }
    
    var labelOpacity: CGFloat {
        if isSelected || isPinned { return 1 }
        
        if [.circleWithoutLabel].contains(detailLevel) {
            return 0.0
        }
        return [.normal, .big].contains(state) ? 1.0 : 0.0
    }
    
    var labelTransform: CGAffineTransform {
        if isSelected { return CGAffineTransform(translationX: 0, y: -0.5) }
        if isPinned { return CGAffineTransform(translationX: 0, y: -4) }
        
        if [.circleWithoutLabel].contains(detailLevel) {
            return CGAffineTransform(translationX: 0, y: -12).scaledBy(x: 0.5, y: 0.5)
        }
        return CGAffineTransform.identity
    }
    
    var imageOpacity: CGFloat {
        if isSelected || isPinned { return 1 }
        if [.circleWithoutLabel].contains(detailLevel) {
            return 1.0
        }
        return 0.0
    }
    
}

