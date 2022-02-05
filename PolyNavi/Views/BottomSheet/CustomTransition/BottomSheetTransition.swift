import UIKit

class BottomSheetTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }
        
        let containerView = transitionContext.containerView
        containerView.clipsToBounds = false
        containerView.addSubview(toVC.view)
        
        toVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: 0, y: 200)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: nil), curve: .easeInOut) {
            toVC.view.transform = .identity
            fromVC.view.transform = CGAffineTransform(translationX: 0, y: -100)
        }
        
        animator.addCompletion { _ in
            transitionContext.completeTransition(true)
        }
        
        animator.startAnimation()
    }
    
}


extension BottomSheetTransition: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
