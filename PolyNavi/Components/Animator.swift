//
//  Animator.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 16.01.2022.
//

import UIKit

protocol Executable {
    func execute(animated: Bool)
}

class Animator {

    class Basic: Executable {
        var withDuration: TimeInterval
        var delay: TimeInterval
        var options: UIView.AnimationOptions
        var animations: () -> Void
        var completion: ((Bool) -> Void)?
        
        init(withDuration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, animations: @escaping (() -> Void), completion: ((Bool) -> Void)?) {
            self.withDuration = withDuration
            self.delay = delay
            self.options = options
            self.animations = animations
            self.completion = completion
        }
        
        func execute(animated: Bool) {
            if animated {
                UIView.animate(withDuration: withDuration, delay: delay, options: options, animations: animations, completion: completion)
            } else {
                animations()
                completion?(true)
            }
        }
    }
    
    class Spring: Executable {
        var withDuration: TimeInterval
        var delay: TimeInterval
        var usingSpringWithDamping: CGFloat
        var initialSpringVelocity: CGFloat
        var options: UIView.AnimationOptions
        var animations: () -> Void
        var completion: ((Bool) -> Void)?
        
        init(withDuration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIView.AnimationOptions, animations: @escaping (() -> Void), completion: ((Bool) -> Void)?) {
            self.withDuration = withDuration
            self.delay = delay
            self.usingSpringWithDamping = usingSpringWithDamping
            self.initialSpringVelocity = initialSpringVelocity
            self.options = options
            self.animations = animations
            self.completion = completion
        }
        
        func execute(animated: Bool) {
            if animated {
                UIView.animate(withDuration: withDuration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            } else {
                animations()
                completion?(true)
            }
        }
    }
    
    
    var animations: [Executable] = []
    
    init() { }
    
    @discardableResult
    func animate(withDuration: TimeInterval, animations: @escaping (() -> Void), completion: ((Bool) -> Void)? = nil) -> Self {
        return animate(withDuration: withDuration, delay: 0, options: [], animations: animations, completion: completion)
    }
    
    @discardableResult
    func animate(withDuration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, animations: @escaping (() -> Void), completion: ((Bool) -> Void)? = nil) -> Self {
        self.animations.append(Basic(withDuration: withDuration, delay: delay, options: options, animations: animations, completion: completion))
        return self
    }
    
    @discardableResult
    func animate(withDuration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIView.AnimationOptions, animations: @escaping (() -> Void), completion: ((Bool) -> Void)? = nil) -> Self {
        self.animations.append(Spring(withDuration: withDuration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion))
        return self
    }
    
    func play(animated: Bool = true) {
        for anim in animations {
            anim.execute(animated: animated)
        }
    }
}
