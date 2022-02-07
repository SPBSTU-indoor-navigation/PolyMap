import UIKit

class BottomSheetTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let operation: UINavigationController.Operation
    let fromState: RootBottomSheetViewController.VerticalSize
    let size: RootBottomSheetViewController.HorizontalSize
    let duration: CGFloat
    let complition: () -> Void
    
    init(operation: UINavigationController.Operation, fromState: RootBottomSheetViewController.VerticalSize, size: RootBottomSheetViewController.HorizontalSize, duration: CGFloat, complition: @escaping () -> Void) {
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
        let presentedContainer = container.layer.presentation()!
        let scale = 0.98
        let delta = container.frame.height - presentedContainer.frame.height
        to.view.transform = CGAffineTransform(translationX: -container.window!.convert(container.frame, from: container).maxX, y: -delta)

        let anim = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
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
        
        anim.addCompletion({ _ in context.completeTransition(true) })
        anim.startAnimation()
    }
    
    func bigSizeAnimPush(_ context: UIViewControllerContextTransitioning, from: UIViewController, to: UIViewController, container: UIView) {
        to.view.transform = CGAffineTransform(translationX: 0, y: container.layer.presentation()!.frame.height)
        
        let anim = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            to.view.transform = .identity
            from.view.layer.shadowOpacity = 0
            
            if self.fromState == .small {
                let delta = container.frame.height - container.layer.presentation()!.frame.height
                from.view.transform = CGAffineTransform(translationX: 0, y: delta)
            } else {
                from.view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }
        }
        
        anim.addCompletion({ _ in context.completeTransition(true) })
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
        
        let anim = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
            from.view.layer.shadowOpacity = 0
            to.view.layer.shadowOpacity = RootBottomSheetViewController.Constants.shadowOpacity
            
            to.view.transform = .identity
            from.view.transform = from.view.transform.translatedBy(x: -container.window!.convert(container.frame, from: container).maxX, y: 0)
        }
        
        anim.addCompletion({ _ in context.completeTransition(true) })
        anim.startAnimation()
    }
    
    func bigSizeAnimPop(_ context: UIViewControllerContextTransitioning, from: UIViewController, to: UIViewController, container: UIView) {
        container.sendSubviewToBack(to.view)
        to.view.transform = .identity
        to.view.frame = container.frame
        to.view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        
        let delta = container.frame.height - container.layer.presentation()!.frame.height
        from.view.frame = CGRect(x: 0, y: 0, width: from.view.frame.width, height: from.view.layer.presentation()!.frame.height)
        from.view.transform = CGAffineTransform(translationX: 0, y: delta)
        
        let anim = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
            
            from.view.layer.shadowOpacity = 0
            to.view.layer.shadowOpacity = RootBottomSheetViewController.Constants.shadowOpacity
            to.view.transform = .identity
            
            
            from.view.transform = CGAffineTransform(translationX: 0, y: container.frame.height)

        }
        
        anim.addCompletion({ _ in context.completeTransition(true) })
        anim.startAnimation()
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        complition()
    }
}
