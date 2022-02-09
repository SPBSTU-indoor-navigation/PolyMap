import UIKit
import UIScreenExtension


protocol BottomSheetPageDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
}

class BottomSheetViewController: UINavigationController {
    enum Constants {
        static let velocityLimit = 8.0
        static let velocitySuperLimit = 80.0
        
        static let minWidthForSmallSize = 1000.0
        static let minWidthForUltraSmallSize = 800.0
        
        static let smallWidth = 380.0
        static let ultraSmallWidth = 320.0
        
        static let smallHeight = 100.0
        static let mediumHeight = 305.0
        
        static let transitionDuration = 0.3
        
        static let shadowOpacity: Float = 0.2
    }
    
    enum HorizontalSize {
        case big
        case small
        case ultraSmall
    }
    
    enum VerticalSize: Int {
        case small = 0
        case medium = 1
        case big = 2
        
        var stateBigger: [VerticalSize] {
            switch self {
            case .small: return [.medium, .big]
            case .medium, .big: return [.big]
            }
        }
        
        var stateSmaller: [VerticalSize] {
            switch self {
            case .small, .medium: return [.small]
            case .big: return [.small, .medium]
            }
        }
    }
    
    private var state: VerticalSize = .small
    private var currentPosition: CGFloat = -1
    
    private var startPosotion = 0.0
    private var startContentOffset: CGFloat = 0
    
    private var mooved = false
    private var moovedByScroll = false
    
    private var stateByViewControllers: [UIViewController:VerticalSize] = [:]
    
    private var containerView: UIView {
        return view.window!
    }
    
    
    private var lastSize: HorizontalSize?
    private var currentSize: HorizontalSize {
        let windowWidth = containerView.frame.width
        
        if windowWidth > Constants.minWidthForSmallSize { return .small }
        if windowWidth > Constants.minWidthForUltraSmallSize { return .ultraSmall }
        
        return .big
    }
    
    public init(parentVC: UIViewController, rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        let gr = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        view.addGestureRecognizer(gr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        isNavigationBarHidden = true
        
        self.view.subviews.forEach {
            $0.clipsToBounds = false
        }
        
        delegate = self
    }
    
    func applyBottomSheetPage(vc: UIViewController) {
        guard let lastSize = lastSize else { return }

        if let t = vc as? BottomSheetPage {
            t.onStateChange(horizontalSize: lastSize)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (mooved || moovedByScroll) == false { currentPosition = position(for: state) }
        
        let safeArea = containerView.safeAreaInsets
        
        view.frame = CGRect(
            x: currentSize == .big ? 0 : max(safeArea.left, 8),
            y: currentPosition,
            width: width(for: currentSize),
            height: height(for: currentSize)
        )
        
        view.layoutIfNeeded()
        
        if lastSize != currentSize {
            lastSize = currentSize
            applyBottomSheetPage(vc: viewControllers.last!)
        }
    }
    
    
    private func width(for size: HorizontalSize) -> CGFloat {
        switch size {
        case .big:
            return containerView.frame.width
        case .small:
            return Constants.smallWidth
        case .ultraSmall:
            return Constants.ultraSmallWidth
        }
    }
    
    private func height(for size: HorizontalSize) -> CGFloat {
        let safeArea = containerView.safeAreaInsets
        let window = containerView.frame
        
        switch size {
        case .big:
            return window.height - currentPosition + safeArea.top - safeArea.bottom
        case .small, .ultraSmall:
            return window.height - currentPosition - safeArea.bottom
        }
    }
    
    private func position(for state: VerticalSize) -> CGFloat {
        let safeArea = containerView.safeAreaInsets
        let height = containerView.frame.height
        
        let safeAreaOffset = currentSize == .big ? safeArea.bottom : 0
        
        switch state {
        case .small:
            return height - safeAreaOffset - Constants.smallHeight
        case .medium:
            return height - safeAreaOffset - Constants.mediumHeight
        case .big:
            return safeArea.top + 20
        }
    }
    
    private func nextState(velocity: CGFloat) -> VerticalSize {
        var realVelocity = velocity / 60
        
        if let pointsPerCentimeter = UIScreen.pointsPerCentimeter {
            realVelocity = velocity / pointsPerCentimeter
        }
        
        if realVelocity > Constants.velocitySuperLimit { return .small}
        if realVelocity < -Constants.velocitySuperLimit { return .big}
        
        var possibleStates: [VerticalSize] = []
        
        if realVelocity < -Constants.velocityLimit {
            possibleStates = state.stateBigger
        } else if realVelocity > Constants.velocityLimit {
            possibleStates = state.stateSmaller
        } else {
            possibleStates = [.small, .big, .medium]
        }
        
        var nearestDistance = CGFloat.greatestFiniteMagnitude
        var nearestState = VerticalSize.small
        
        for state in possibleStates {
            let distance = abs(position(for: state) - currentPosition)
            if distance < nearestDistance {
                nearestState = state
                nearestDistance = distance
            }
        }
        
        return nearestState
    }
    
    @objc
    private func panAction(_ sender: UIPanGestureRecognizer) {
        defer { viewDidLayoutSubviews() }
        
        let velocity = sender.velocity(in: containerView)
        let translation = sender.translation(in: containerView)
        
        switch sender.state {
        case .began:
            mooved = true
            view.layer.removeAllAnimations()
            currentPosition = view.layer.presentation()!.frame.origin.y
            startPosotion = currentPosition
        case.changed:
            let smallerPos = position(for: .small)
            let biggerPos = position(for: .big)
            let targetPosition = translation.y + startPosotion
            
            if biggerPos < targetPosition && targetPosition < smallerPos {
                currentPosition = targetPosition
            } else if targetPosition > smallerPos {
                let delta = targetPosition - smallerPos
                currentPosition = smallerPos + expLimit(delta, 20)
            } else if targetPosition < biggerPos {
                let delta = biggerPos - targetPosition
                currentPosition = biggerPos - expLimit(delta, 20)
            }
            
        case.ended:
            mooved = false
            endAnimation(-velocity.y)
        default: break
        }
        
    }
    
    private func endAnimation(_ velocity: CGFloat) {
        state = nextState(velocity: -velocity)
        
        let delta = abs(currentPosition - position(for: state))
        currentPosition = position(for: state)
        let initialVelocity = abs(velocity / delta) / 1000
        
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: initialVelocity > 0.001 ? 0.8 : 1, initialSpringVelocity: initialVelocity, options: [.curveEaseIn, .allowUserInteraction], animations: { [self] in
            viewDidLayoutSubviews()
        })
    }
    
    func changeState(state: VerticalSize, duration: CGFloat = Constants.transitionDuration, animated: Bool = true) {
        self.state = state
        
        currentPosition = position(for: state)
        if animated {
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
                self.viewDidLayoutSubviews()
            }
        } else {
            viewDidLayoutSubviews()
        }
    }
    
    var lastState: VerticalSize = .small
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        stateByViewControllers[viewController] = state
        
        if view.window != nil {
            lastState = state
            if currentSize == .big {
                changeState(state: .medium)
            } else {
                changeState(state: .big)
            }
        }
        
        if animated {
            view.isUserInteractionEnabled = false
        }
        
        super.pushViewController(viewController, animated: animated)
        if let bottomSheetPage = viewController as? BottomSheetPage {
            bottomSheetPage.delegate = self
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        lastState = state
        
        if animated {
            view.isUserInteractionEnabled = false
        }
        
        guard let targetVC = super.popViewController(animated: animated) else {
            view.isUserInteractionEnabled = true
            return nil
        }
        
        if let targetState = stateByViewControllers.removeValue(forKey: targetVC) {
            if currentSize == .big {
                if targetState == .small || state == .small {
                    changeState(state: .small, animated: false)
                } else {
                    changeState(state: .medium, animated: false)
                }
            } else {
                if targetState.rawValue < state.rawValue {
                    changeState(state: targetState, animated: false)
                }
            }
        }
        return targetVC
    }
}

extension BottomSheetViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        applyBottomSheetPage(vc: toVC)
        
        return BottomSheetTransition(operation: operation, fromState: lastState, size: currentSize, duration: Constants.transitionDuration, complition: { self.view.isUserInteractionEnabled = true })
    }
}


extension BottomSheetViewController: BottomSheetPageDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let offset = scrollView.topContentOffset.y
        if -30 < offset && offset <= 0 {
            startContentOffset = offset
            startPosotion = currentPosition
            moovedByScroll = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if moovedByScroll {
            var translation = scrollView.panGestureRecognizer.translation(in: scrollView)
            translation.y += min(2 * startContentOffset, 0)
            
            let smallerPos = position(for: .small)
            let biggerPos = position(for: .big)
            let targetPosition = translation.y + startPosotion
            
            if biggerPos < targetPosition && targetPosition < smallerPos {
                currentPosition = targetPosition
                scrollView.topContentOffset = CGPoint(x: 0, y: min(0, startContentOffset + 2 * abs(translation.y)))
            } else if biggerPos > targetPosition {
                currentPosition = biggerPos
            } else if targetPosition > smallerPos {
                currentPosition = smallerPos
            }
            
            viewDidLayoutSubviews()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if moovedByScroll {
            moovedByScroll = false
            endAnimation(velocity.y * 1000)
            
            if startPosotion != position(for: .big) && scrollView.topContentOffset.y <= 0  {
                targetContentOffset.pointee = CGPoint(x: 0, y: -scrollView.topOffset)
            }
        }
    }
}



fileprivate func expLimit(_ x: CGFloat, _ maxVal: CGFloat) -> CGFloat {
    return (1 - exp(-x / maxVal)) * maxVal
}
