import UIKit

class BottomSheetTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let operation: UINavigationController.Operation
    let fromState: BottomSheetViewController.VerticalSize
    let size: BottomSheetViewController.HorizontalSize
    let duration: CGFloat
    let complition: () -> Void
    
    init(operation: UINavigationController.Operation, fromState: BottomSheetViewController.VerticalSize, size: BottomSheetViewController.HorizontalSize, duration: CGFloat, complition: @escaping () -> Void) {
        self.operation = operation
        self.fromState = fromState
        self.duration = duration
        self.size = size
        self.complition = complition
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }
        
        let container = transitionContext.containerView
        container.addSubview(toVC.view)
        
        if operation == .push {
            if size == .big {
                bigSizeAnimPush(transitionContext, from: fromVC, to: toVC, container: container)
            } else {
                animPush(transitionContext, from: fromVC, to: toVC, container: container)
            }
        } else if operation == .pop {
            if size == .big {
                bigSizeAnimPop(transitionContext, from: fromVC, to: toVC, container: container)
            } else {
                animPop(transitionContext, from: fromVC, to: toVC, container: container)
            }
        }
    }
    
    func animPush(_ context: UIViewControllerContextTransitioning, from: UIViewController, to: UIViewController, container: UIView) {
        let scale = 0.98
        let presentedContainer = container.layer.presentation()!
        let delta = container.frame.height - presentedContainer.frame.height
        let xOffset = container.window!.convert(container.frame, from: container).maxX
        
        let mask = horizontalMask(for: from.view, container: container, radius: 12.0, isOpen: true)
        from.view.layer.addSublayer(mask)
        from.view.layer.mask = mask

        to.view.transform = CGAffineTransform(translationX: -xOffset, y: -delta)
        
        let anim = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            to.view.transform = .identity
            from.view.layer.shadowOpacity = 0
            if self.fromState != .big {
                let frame = from.view.frame
                from.view.frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: presentedContainer.frame.height))
                from.view.transform = CGAffineTransform(translationX: 0, y: delta).scaledBy(x: scale, y: scale)
            } else {
                from.view.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        
        anim.addCompletion({ _ in
            context.completeTransition(true)
            mask.removeFromSuperlayer()
        })
        anim.startAnimation()
    }
    
    func bigSizeAnimPush(_ context: UIViewControllerContextTransitioning, from: UIViewController, to: UIViewController, container: UIView) {
        to.view.transform = CGAffineTransform(translationX: 0, y: container.layer.presentation()!.frame.height)
        let delta = container.frame.height - container.layer.presentation()!.frame.height
        
        let mask = verticalMask(for: from.view, container: container, radius: 12.0, isOpen: true)
        from.view.layer.addSublayer(mask)
        from.view.layer.mask = mask
        
        let anim = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            to.view.transform = .identity
            from.view.layer.shadowOpacity = 0
            
            if self.fromState == .small {
                from.view.transform = CGAffineTransform(translationX: 0, y: delta)
            }
        }
        
        anim.addCompletion({ _ in
            context.completeTransition(true)
            mask.removeFromSuperlayer()
            
        })
        anim.startAnimation()
    }
    
    func animPop(_ context: UIViewControllerContextTransitioning, from: UIViewController, to: UIViewController, container: UIView) {
        let scale = 0.98
        let delta = container.frame.height - container.layer.presentation()!.frame.height

        container.sendSubviewToBack(to.view)
        to.view.transform = .identity
        to.view.frame = container.frame
        to.view.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        from.view.frame = CGRect(x: 0, y: 0, width: from.view.frame.width, height: from.view.layer.presentation()!.frame.height)
        from.view.transform = CGAffineTransform(translationX: 0, y: delta)
        
        let mask = horizontalMask(for: from.view, container: container, radius: 12.0, isOpen: false)
        to.view.layer.addSublayer(mask)
        to.view.layer.mask = mask
        
        let anim = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            to.view.layer.shadowOpacity = BottomSheetViewController.Constants.shadowOpacity
            
            to.view.transform = .identity
            from.view.transform = from.view.transform.translatedBy(x: -container.window!.convert(container.frame, from: container).maxX, y: 0)
        }
        
        anim.addCompletion({ _ in
            context.completeTransition(true)
            mask.removeFromSuperlayer()
        })
        anim.startAnimation()
    }
    
    func bigSizeAnimPop(_ context: UIViewControllerContextTransitioning, from: UIViewController, to: UIViewController, container: UIView) {
        container.sendSubviewToBack(to.view)
        to.view.transform = .identity
        to.view.frame = container.frame
        
        let delta = container.frame.height - container.layer.presentation()!.frame.height
        from.view.frame = CGRect(x: 0, y: 0, width: from.view.frame.width, height: from.view.layer.presentation()!.frame.height)
        from.view.transform = CGAffineTransform(translationX: 0, y: delta)
        
        let mask = verticalMask(for: from.view, container: container, radius: 12.0, isOpen: false)
        to.view.layer.addSublayer(mask)
        to.view.layer.mask = mask
        
        let anim = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
            from.view.layer.shadowOpacity = 0
            to.view.layer.shadowOpacity = BottomSheetViewController.Constants.shadowOpacity
            
            from.view.transform = CGAffineTransform(translationX: 0, y: container.frame.height)
        }
        
        anim.addCompletion({ _ in
            context.completeTransition(true)
            mask.removeFromSuperlayer()
        })
        anim.startAnimation()
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        complition()
    }
    
    func verticalMask(for view: UIView, container: UIView, radius R: CGFloat, isOpen: Bool) -> CALayer {
        let delta = container.frame.height - container.layer.presentation()!.frame.height
        let fromFrame = view.layer.presentation()!.frame
        let maskH = fromFrame.height + 301
        
        let mask = CALayer()
        let path = UIBezierPath()
        let shapeLayer = CAShapeLayer()
        
        path.move(to: CGPoint(x: 0, y: maskH - 1))
        path.addLine(to: CGPoint(x: 0, y: maskH + R))
        path.addArc(withCenter: CGPoint(x: R, y: maskH + R), radius: R, startAngle: .pi, endAngle: -.pi/2, clockwise: true)
        
        path.move(to: CGPoint(x: fromFrame.width, y: maskH - 1))
        path.addLine(to: CGPoint(x: fromFrame.width, y: maskH + R))
        path.addArc(withCenter: CGPoint(x: fromFrame.width - R, y: maskH + R), radius: R, startAngle: 0 , endAngle: -.pi/2, clockwise: false)
        
        
        shapeLayer.path = path.cgPath
        mask.addSublayer(shapeLayer)
        
        mask.backgroundColor = UIColor.black.cgColor
        mask.frame = CGRect(x: fromFrame.origin.x, y: fromFrame.origin.y, width: fromFrame.width, height: maskH)
        
        let close = fromFrame.height / 2 - 150
        let open = -fromFrame.height / 2 - 150 + (fromState == .small && isOpen ? -delta : 0)
        
        mask.position = CGPoint(x: mask.position.x, y: isOpen ? open : (close + delta))
        
        let maskAnim: CABasicAnimation = {
            $0.fromValue = isOpen ? close : (open + delta)
            $0.toValue = isOpen ? open : (close + delta)
            $0.fillMode = .forwards
            $0.duration = duration
            $0.timingFunction = CAMediaTimingFunction(name: isOpen ? .easeInEaseOut : .easeIn)
            return $0
        } (CABasicAnimation(keyPath: "position.y"))
        mask.add(maskAnim, forKey: "position.y")
        return mask
    }
    
    func horizontalMask(for view: UIView, container: UIView, radius R: CGFloat, isOpen: Bool) -> CALayer {
        let scale = 0.98
        let verticalMargin = 50.0
        let fromFrame = isOpen ? view.layer.presentation()!.frame : view.layer.frame
        let xOffset = container.window!.convert(container.frame, from: container).maxX
        
        let mask = CALayer()
        let path = UIBezierPath()
        let vOffset = verticalMargin / 2
        
        func createGradient() -> CAGradientLayer {
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.black.cgColor, UIColor.black.withAlphaComponent(0).cgColor]
            gradient.startPoint = CGPoint(x: 1, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 0)
            return gradient
        }
        
        let shapeLayer = CAShapeLayer()
        path.move(to: CGPoint(x: 1, y: vOffset))
        path.addLine(to: CGPoint(x: -R, y: vOffset))
        path.addLine(to: CGPoint(x: 1, y: R + vOffset))
        path.close()
        
        path.move(to: CGPoint(x: 1, y: fromFrame.height + vOffset))
        path.addLine(to: CGPoint(x: -R, y: fromFrame.height + vOffset))
        path.addLine(to: CGPoint(x: 1, y: fromFrame.height - R + vOffset))
        path.close()
        
        shapeLayer.path = path.cgPath
        mask.addSublayer(shapeLayer)
        
        let gradient = createGradient()
        gradient.frame = CGRect(x: -50, y: 0, width: 50, height: vOffset)
        
        let gradientBottom = createGradient()
        gradientBottom.frame = CGRect(x: -50, y: fromFrame.height + vOffset, width: 50, height: vOffset)
        
        mask.addSublayer(gradient)
        mask.addSublayer(gradientBottom)
        
        mask.backgroundColor = UIColor.systemRed.withAlphaComponent(1).cgColor
        mask.frame = CGRect(x: fromFrame.origin.x - 300, y: fromFrame.origin.y - vOffset, width: fromFrame.width + 300, height: fromFrame.height + verticalMargin)
        
        
        let d = mask.frame.width - (mask.frame.width * scale)
        let close = mask.position.x - xOffset + mask.frame.width - 5
        let open = mask.position.x + mask.frame.width + (d * 1 / scale) / 2 - 5
        
        mask.position = CGPoint(x: isOpen ? open : close, y: mask.position.y)
        
        
        let maskAnimP: CABasicAnimation = {
            $0.fromValue = isOpen ? close : open
            $0.toValue = isOpen ? open : close
            $0.fillMode = .forwards
            $0.duration = duration
            $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            return $0
        } (CABasicAnimation(keyPath: "position.x"))
        mask.add(maskAnimP, forKey: "position.x")
        
        
        return mask
    }
}
