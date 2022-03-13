//
//  ScaledImageView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 23.02.2022.
//

import UIKit

class ScaledImageView: UIImageView {
    var sourceImage: UIImage? {
        didSet {
            image = sourceImage
        }
    }
    
    private var displayLink: CADisplayLink?
    
    @objc private func animationStep(displayLink: CADisplayLink) {
        renderWithFrame()
    }
    
    func renderIfNeed() {
        if alpha > 0 && !isHidden {
            renderWithFrame()
        }
    }
    
    func renderWithFrame() {
        guard let sourceImage = sourceImage else { return }
        var size = frame.size
        if let presented = layer.presentation() {
            size = presented.convert(frame, to: nil).size
        }
        
        image = render(image: sourceImage, size: size, tintColor: tintColor)
    }
    
    func render(image: UIImage, size: CGSize, tintColor: UIColor) -> UIImage? {
        let aspect = image.size.width / image.size.height
        let size = CGSize(width: Int(size.width * UIScreen.main.scale * (aspect < 1 ? aspect : 1)), height: Int(size.width * UIScreen.main.scale / (aspect > 1 ? aspect : 1)))
        UIGraphicsBeginImageContext(size)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: .zero, size: size)
        image.draw(in: rect)
        guard let mask = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        ctx.translateBy(x: 0, y: mask.size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.clip(to: rect, mask: mask.cgImage!)
        tintColor.setFill()
        ctx.fill(rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    private var activeAnimationCount = 0
    
    func startAnim() {
        activeAnimationCount += 1
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(self.animationStep))
            displayLink!.add(to: .main, forMode: .default)
        }
    }
    
    func endAnim() {
        activeAnimationCount -= 1
        if activeAnimationCount == 0 {
            displayLink?.invalidate()
            displayLink = nil
            renderWithFrame()
        }
    }
}
