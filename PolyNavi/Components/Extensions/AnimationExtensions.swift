//
//  AnimationExtensions.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 15.02.2022.
//

import UIKit

extension UISpringTimingParameters {
    
    /// A design-friendly way to create a spring timing curve.
    ///
    /// - Parameters:
    ///   - damping: The 'bounciness' of the animation. Value must be between 0 and 1.
    ///   - response: The 'speed' of the animation.
    ///   - initialVelocity: The vector describing the starting motion of the property. Optional, default is `.zero`.
    public convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
    
}


extension UIViewPropertyAnimator {
    func tryStopAnimation(_ withoutFinishing: Bool) {
        if self.isRunning {
            self.stopAnimation(withoutFinishing)
        }
    }

}

extension CGAffineTransform {
    public static var one: CGAffineTransform { return CGAffineTransform(scaleX: 1, y: 1) }
    public static var zero: CGAffineTransform { return CGAffineTransform(scaleX: 0, y: 0) }
    
    public func scaled(scale: CGFloat) -> Self {
        return scaledBy(x: scale, y: scale)
    }
}
