//
//  CircularProgressBar.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 30.03.2022.
//

import UIKit

class CircularProgressBar: UIView {
    var ringWidth: CGFloat = 5 {
        didSet { setNeedsDisplay() }
    }
    
    var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    var color: UIColor? = .gray {
        didSet { setNeedsDisplay() }
    }
    
    
    private var progressLayer = CAShapeLayer()
    private var backgroundMask = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupViews() {
        backgroundMask.lineWidth = ringWidth
        backgroundMask.fillColor = nil
        backgroundMask.strokeColor = UIColor.black.cgColor
        layer.mask = backgroundMask
        
        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = nil
        layer.addSublayer(progressLayer)
        layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)
    }
    
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))
        backgroundMask.path = circlePath.cgPath
        
        progressLayer.path = circlePath.cgPath
        progressLayer.lineCap = .round
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.strokeColor = color?.cgColor
    }
    
}
