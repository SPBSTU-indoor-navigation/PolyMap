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
    enum State {
        case big
        case small
        case ultraSmall
    }
    
    override var annotation: MKAnnotation? {
        didSet {
            if let title = annotation?.title {
                label.text = title
                label.isEnabled = true
            } else {
                label.text = nil
                label.isEnabled = false
            }
        }
    }
    
    var state: State = .small
    
    var pointSize: CGFloat {
        get {
            switch state {
            case .big: return 0.8
            case .small: return 0.8
            case .ultraSmall: return 0.6
            }
        }
    }
    
    var textOpacity: CGFloat {
        return state == .big ? 1.0 : 0.0
    }
    
    var selectAnim = Animator()
    var deselectAnim = Animator()
    
    lazy var shape: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let t = CAShapeLayer()
        
        let path: UIBezierPath = {
            $0.move(to: CGPoint(x: -10, y: -10))
            $0.addCurve(to: CGPoint(x: -1.5, y: -2), controlPoint1: CGPoint(x: -5, y: -8), controlPoint2: CGPoint(x: -3, y: -4))
            $0.addCurve(to: CGPoint(x: 1.5, y: -2), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 0, y: 0))
            $0.addCurve(to: CGPoint(x: 10, y: -10), controlPoint1: CGPoint(x: 3, y: -4), controlPoint2: CGPoint(x: 5, y: -8))
            
            $0.apply(CGAffineTransform(translationX: 10, y: 9))
            $0.apply(CGAffineTransform(scaleX: 2/20, y: 2/20))
            return $0
        }(UIBezierPath())

        t.path = path.cgPath
        t.fillColor = UIColor.systemOrange.cgColor
        
        $0.layer.addSublayer(t)
        
        $0.transform = CGAffineTransform(translationX: 0, y: -1).scaledBy(x: 1, y: 0)
        return $0
    }(UIView())
    
    lazy var point: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 5
        
        $0.addSubview(shape)
        return $0
    }(UIView())
    
    lazy var miniPoint: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemOrange
        $0.layer.cornerRadius = 3
        $0.transform = CGAffineTransform(scaleX: 0, y: 0)
        return $0
    }(UIView())
    
    lazy var label: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .label
        
        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        return $0
    }(UILabel())
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame.size = CGSize(width: 8, height: 8)
        addSubview(miniPoint)
        addSubview(point)
        addSubview(label)
        miniPoint.isHidden = true
        
        NSLayoutConstraint.activate([
            point.centerXAnchor.constraint(equalTo: centerXAnchor),
            point.centerYAnchor.constraint(equalTo: centerYAnchor),
            point.widthAnchor.constraint(equalToConstant: 10),
            point.heightAnchor.constraint(equalToConstant: 10),
            label.topAnchor.constraint(equalTo: centerYAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            miniPoint.heightAnchor.constraint(equalToConstant: 6),
            miniPoint.widthAnchor.constraint(equalToConstant: 6),
            miniPoint.centerXAnchor.constraint(equalTo: centerXAnchor),
            miniPoint.centerYAnchor.constraint(equalTo: centerYAnchor),
            shape.centerXAnchor.constraint(equalTo: point.centerXAnchor),
            shape.topAnchor.constraint(equalTo: point.bottomAnchor),
            shape.widthAnchor.constraint(equalToConstant: 2),
            shape.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        selectAnim
            .animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [self] in
                point.transform = CGAffineTransform(scaleX: 7, y: 7).translatedBy(x: 0, y: -6.8)
                label.transform = CGAffineTransform(translationX: 0, y: -3.5)
            })
            .animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: { [self] in
                miniPoint.isHidden = false
                miniPoint.transform = .identity
            })
            .animate(withDuration: 0.2, delay: 0.05, options: .curveEaseInOut, animations: { [self] in
                shape.transform = .identity.scaledBy(x: 1, y: 1)
                label.alpha = 1.0

            })
        
        deselectAnim
            .animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [self] in
                point.transform = .identity.scaledBy(x: pointSize, y: pointSize)
            })
            .animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [self] in
                shape.transform = CGAffineTransform(translationX: 0, y: -1).scaledBy(x: 1, y: 0)
                miniPoint.transform = CGAffineTransform(scaleX: 0, y: 0)
                label.alpha = textOpacity
                label.transform = .identity
            }, completion: { _ in self.miniPoint.isHidden = true })
    }
    
    
    func changeState(state: State, animate: Bool) {
        self.state = state
        
        if isSelected { return }
        
        let change = { [self] in
            label.alpha = textOpacity
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
        var targetState: State = .ultraSmall
        
        if mapSize > 20.2 {
            targetState = .big
        } else if mapSize > 19 {
            targetState = .small
        }
        
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
}

