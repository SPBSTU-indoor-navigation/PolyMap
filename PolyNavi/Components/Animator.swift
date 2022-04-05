//
//  Animator.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 16.01.2022.
//

import UIKit

class Animator {
    
    class Animation {
        var playing = false
        func execute(animated: Bool) {
            playing = true
        }
    }

    class Basic: Animation {
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
        
        override func execute(animated: Bool) {
            super.execute(animated: animated)
            
            if animated {
                UIView.animate(withDuration: withDuration, delay: delay, options: options, animations: animations, completion: { [weak self] comp in
                    self?.completion?(comp)
                    self?.playing = false
                })
            } else {
                animations()
                playing = false
                completion?(true)
            }
        }
    }
    
    class Spring: Animation {
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
        
        override func execute(animated: Bool) {
            super.execute(animated: animated)
            
            if animated {
                UIView.animate(withDuration: withDuration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: { [weak self] comp in
                    self?.completion?(comp)
                    self?.playing = false
                })
            } else {
                animations()
                completion?(true)
                playing = false
            }
        }
    }
    
    
    var animations: [Animation] = []
    
    var isPlaying: Bool { animations.first(where: { $0.playing }) != nil }
    
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
