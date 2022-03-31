//
//  AttractionAnnotationView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 18.01.2022.
//

import MapKit

class AttractionAnnotationView: BaseAnnotationView<AttractionAnnotationView.DetailLevel> {
    enum DetailLevel: Int {
        case normal = 0
    }
    
    static let stateProcessor: DetailLevelProcessor<DetailLevelState> = {
        $0.builder(for: 0)
            .add(mapSize: 0, state: .hide)
            .add(mapSize: 17.2, state: .min)
            .add(mapSize: 18, state: .normal)
        return $0
    }(DetailLevelProcessor<DetailLevelState>())
    
    
    override var annotation: MKAnnotation? {
        didSet {
            label.text = annotation?.title!
            if let attraction = annotation as? AttractionAnnotation {
                if let image = attraction.annotationSprite {
                    imageView.image = image
                    imageView.isHidden = false
                    labelShort.isHidden = true
                } else {
                    labelShort.text = attraction.properties.short_name?.bestLocalizedValue ?? "-"
                    labelShort.isHidden = false
                    imageView.isHidden = true
                }
            }
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
            
            $0.apply(CGAffineTransform(translationX: 10, y: 9))
            $0.apply(CGAffineTransform(scaleX: 10/20, y: 10/20))
            return $0
        }(UIBezierPath())
        
        t.path = path.cgPath
        t.fillColor = Asset.Annotation.Colors.attractionBorder.color.cgColor
        
        $0.layer.addSublayer(t)
        
        $0.transform = CGAffineTransform(translationX: 0, y: -4).scaledBy(x: 1, y: 0)
        return $0
    }(UIView())
    
    lazy var background: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Asset.Annotation.Colors.attractionBackground.color
        $0.layer.cornerRadius = 20
        $0.layer.borderColor = Asset.Annotation.Colors.attractionBorder.color.cgColor
        $0.layer.borderWidth = 2
        
        $0.addSubview(shape)
        $0.addSubview(imageView)
        $0.addSubview(labelShort)
        return $0
    }(UIView())
    
    lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.layer.minificationFilter = .trilinear
        $0.layer.minificationFilterBias = 0.1
        return $0
    }(UIImageView())
    
    lazy var labelShort: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Asset.Annotation.Colors.attractionBorder.color
        
        $0.font = .systemFont(ofSize: 40, weight: .bold)
        return $0
    }(UILabel())
    
    lazy var label: THLabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Asset.Annotation.Colors.attractionTextColor.color
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.preferredMaxLayoutWidth = 120
        $0.strokeSize = 0.5
        $0.strokeColor = Asset.Annotation.Colors.attractionTextStroke.color
        
        $0.textAlignment = .center
        
        $0.font = .systemFont(ofSize: 11, weight: .bold)
        return $0
    }(THLabel())
    
    lazy var miniPoint: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Asset.Annotation.Colors.attractionBorder.color
        $0.layer.cornerRadius = 3
        $0.transform = CGAffineTransform(scaleX: 0, y: 0)
        return $0
    }(UIView())
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        detailLevel = .normal
        
        self.frame.size = CGSize(width: 40, height: 40)
        
        addSubview(miniPoint)
        addSubview(background)
        addSubview(label)
        miniPoint.isHidden = true
        
        labelShort.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        NSLayoutConstraint.activate([
            background.centerXAnchor.constraint(equalTo: centerXAnchor),
            background.centerYAnchor.constraint(equalTo: centerYAnchor),
            background.widthAnchor.constraint(equalToConstant: 40),
            background.heightAnchor.constraint(equalToConstant: 40),
            shape.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            shape.topAnchor.constraint(equalTo: background.bottomAnchor),
            shape.widthAnchor.constraint(equalToConstant: 10),
            shape.heightAnchor.constraint(equalToConstant: 5),
            miniPoint.heightAnchor.constraint(equalToConstant: 6),
            miniPoint.widthAnchor.constraint(equalToConstant: 6),
            miniPoint.centerXAnchor.constraint(equalTo: centerXAnchor),
            miniPoint.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelShort.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            labelShort.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: centerYAnchor, constant: 22),
            imageView.topAnchor.constraint(equalTo: background.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
        ])
        
        selectAnim
            .animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [self] in
                background.transform = pointTransform
                label.transform = labelTransform
                label.textColor = .label
            })
            .animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: { [self] in
                miniPoint.isHidden = false
                miniPoint.transform = miniPointTransform
            })
            .animate(withDuration: 0.2, delay: 0.05, options: .curveEaseInOut, animations: { [self] in
                shape.transform = shapeTransform
                label.alpha = labelOpacity
            })
        
        deselectAnim
            .animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [self] in
                background.transform = pointTransform
                label.transform = labelTransform
                label.textColor = Asset.Annotation.Colors.attractionTextColor.color
            })
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [self] in
                shape.transform = shapeTransform
                miniPoint.transform = miniPointTransform
                label.alpha = labelOpacity
            }, completion: { _ in self.miniPoint.hideIfZeroTransform() })
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    
    
    override var detailLevelProcessor: DetailLevelProcessor<DetailLevelState> { AttractionAnnotationView.stateProcessor }
    
    @available(iOS 14.0, *)
    override var defaultPriority: MKAnnotationViewZPriority { .init(rawValue: 700) }
    
    override func boundingBox() -> CGRect {
        return label.frame.union(background.frame).offsetBy(dx: -frame.width / 2, dy: -frame.height / 2)
    }
    
    override func changeState(state: DetailLevelState, animate: Bool) {
        super.changeState(state: state, animate: animate)
        if isSelected { return }
        
        Animator().animate(withDuration: 0.2, animations: { [self] in
            label.alpha = labelOpacity
            background.transform = pointTransform
            label.transform = labelTransform
        }).play(animated: animate)
    }
    
    override func appearanceDidChange() {
        (shape.layer.sublayers?[0] as! CAShapeLayer).fillColor = Asset.Annotation.Colors.attractionBorder.color.cgColor
        background.layer.borderColor = Asset.Annotation.Colors.attractionBorder.color.cgColor
    }
}

extension AttractionAnnotationView {
    
    private var pointSize : CGFloat {
        switch state {
        case .big, .normal: return 1
        case .hide, .min, .undefined: return 0.8
        }
    }

    var pointTransform: CGAffineTransform {
        if isSelected { return .one.scaled(scale: 1.5).translatedBy(x: 0, y: -29)}
        if isPinned { return.one.scaled(scale: 1).translatedBy(x: 0, y: -29) }
        
        return .one.scaled(scale: pointSize)
    }
    
    var miniPointTransform: CGAffineTransform {
        if isSelected { return .one}
        if isPinned { return .one.scaled(scale: 0.8) }
        
        return .zero
    }
    
    var labelTransform: CGAffineTransform {
        if isSelected { return .one.translatedBy(x: 0, y: -18) }
        if isPinned { return .one.translatedBy(x: 0, y: -19) }
        
        return .one.translatedBy(x: 0, y: (1 - pointSize) * -20)
    }
    
    var shapeTransform: CGAffineTransform {
        isSelected || isPinned ? .one : .one.translatedBy(x: 0, y: -4).scaledBy(x: 1, y: 0)
    }
    
    var labelOpacity: CGFloat {
        if isSelected || isPinned { return 1 }
        return [.min, .normal, .big].contains(state) ? 1.0 : 0.0
    }
}
