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
            animPop(transitionContext, from: fromVC, to: toVC, container: container)
        }
    }
    
    func animPush(_ context: UIViewControllerContextTransitioning, from: UIViewController, to: UIViewController, container: UIView) {
        let delta = container.frame.height - container.layer.presentation()!.frame.height
        to.view.transform = CGAffineTransform(translationX: -container.window!.convert(container.frame, from: container).maxX, y: -delta)
        
        let anim = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            
            let presentedContainrt = container.layer.presentation()!
            
            to.view.transform = .identity
            from.view.layer.shadowOpacity = 0
            
            let aspect = presentedContainrt.frame.width / presentedContainrt.frame.height
            let sizeX = 0.95
            let sizeY = 1 - ((1 - sizeX) * aspect)
            
            if self.fromState != .big {
                let frame = from.view.frame
                from.view.frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: presentedContainrt.frame.height))
                from.view.transform = CGAffineTransform(translationX: 0, y: delta).scaledBy(x: sizeX, y: sizeY)
            } else {
                from.view.transform = CGAffineTransform(scaleX: sizeX , y: sizeY)
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
        print("animPop")
        context.completeTransition(true)
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        complition()
    }
}
