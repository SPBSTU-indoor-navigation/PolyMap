//
//  Extensions.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.02.2022.
//

import UIKit

extension UIScrollView {
    
    var topOffset: CGFloat {
        return safeAreaInsets.top
    }
    
    var topContentOffset: CGPoint {
        get {
            return CGPoint(x: contentOffset.x, y: contentOffset.y + topOffset)
        }
        
        set {
            contentOffset = CGPoint(x: newValue.x, y: newValue.y - topOffset)
        }
    }
}


extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}

extension Array where Iterator.Element : NSLayoutConstraint {
    func priority(_ priority: UILayoutPriority) -> Self {
        self.forEach({ $0.priority = priority })
        return self
    }
}

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

extension UIGestureRecognizer {
    
    /// Calculates the value at which a property settles when intially changing
    /// with a specified velocity and some degree of friction is applied.
    ///
    /// The friction causing the property to change slower and slower and
    /// eventually come to rest is modeled after the familiar `UIScrollView`
    /// deceleration behavior.
    ///
    /// - parameter velocity: The velocity at which some property intitially
    /// changes, measured per second.
    /// - parameter position: The initial value of the property.
    /// - parameter decelerationRate: The rate at which the velocity decreases,
    /// measured as the fraction of the velocity that remains per millisecond.
    public static func project(_ velocity: CGFloat, onto position: CGFloat, decelerationRate: UIScrollView.DecelerationRate = .normal) -> CGFloat {
        let velocity = CGVector(dx: velocity, dy: 0)
        let position = CGPoint(x: position, y: 0)
        
        return self.project(velocity, onto: position, decelerationRate: decelerationRate).x
    }
    
    /// Calculates the position at which an object comes to rest when initially
    /// moving with a specified velocity and some degree of friction is applied.
    ///
    /// The friction causing the object to move slower and slower and eventually
    /// come to rest is modeled after the familiar `UIScrollView` deceleration
    /// behavior.
    ///
    /// - parameter velocity: The velocity at which the object intitially moves,
    /// measured per second.
    /// - parameter position: The initial position of the object.
    /// - parameter decelerationRate: The rate at which the velocity decreases,
    /// measured as the fraction of the velocity that remains per millisecond.
    public static func project(_ velocity: CGVector, onto position: CGPoint, decelerationRate: UIScrollView.DecelerationRate = .normal) -> CGPoint {
        
        // The distance traveled is the integral over the exponentially
        // decreasing velocity from `t = 0` to infinity, which comes down to a
        // constant factor in front of the initial velocity. Thus we can threat
        // the projection along each axis individually.
        let factor = -1 / (1000 * log(decelerationRate.rawValue))
        let x = position.x + factor * velocity.dx
        let y = position.y + factor * velocity.dy
        
        return CGPoint(x: x, y: y)
    }
}
