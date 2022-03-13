import UIKit

protocol BottomSheetDelegate {
    func onStateChange(from: BottomSheetViewController.VerticalSize, to: BottomSheetViewController.VerticalSize)
    func onSizeChange(from: BottomSheetViewController.HorizontalSize?, to: BottomSheetViewController.HorizontalSize)
    func onProgressChange(progress: CGFloat)
}

extension BottomSheetDelegate {
    func onStateChange(from: BottomSheetViewController.VerticalSize, to: BottomSheetViewController.VerticalSize) { }
    func onSizeChange(from: BottomSheetViewController.HorizontalSize?, to: BottomSheetViewController.HorizontalSize) { }
    func onProgressChange(progress: CGFloat) { }
}

protocol BottomSheetPageDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func change(verticalSize: BottomSheetViewController.VerticalSize, animated: Bool)
    
    func verticalSize() -> BottomSheetViewController.VerticalSize
    func horizontalSize() -> BottomSheetViewController.HorizontalSize
}

class BottomSheetViewController: UINavigationController {
    enum Constants {
        static let velocityLimit = 10.0
        static let velocitySuperLimit = 80.0
        
        static let minWidthForSmallSize = 1000.0
        static let minWidthForUltraSmallSize = 800.0
        
        static let smallWidth = 380.0
        static let ultraSmallWidth = 320.0
        
        static let smallHeight = 70.0
        static let mediumHeight = 305.0
        
        static let transitionDuration = 0.3
        
        static let shadowOpacity: Float = 0.2
    }
    
    enum HorizontalSize {
        case big
        case small
        case ultraSmall
    }
    
    enum PopControllerStrategy {
        case alwaysMinimaze
        case mediumIfNeed
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
    
    var bottomSheetDelegate: BottomSheetDelegate?
    var popControllerStrategy: PopControllerStrategy = .mediumIfNeed
    
    internal private(set) var state: VerticalSize = .small {
        willSet {
            if state != newValue {
                bottomSheetDelegate?.onStateChange(from: state, to: newValue)
                onStateChange(from: state, to: newValue)
            }
        }
        didSet {
            if let vc = visibleViewController as? BottomSheetPage {
                vc.onStateChange(verticalSize: state)
            }
        }
    }
    private var currentPosition: CGFloat = -1
    
    private var startPosotion = 0.0
    private var startContentOffset: CGFloat = 0
    
    internal private(set) var mooved = false
    internal private(set) var moovedByScroll = false
    
    private var stateByViewControllers: [UIViewController:VerticalSize] = [:]
    
    private var containerView: UIView {
        return view.window!
    }
    
    
    private var lastSize: HorizontalSize? {
        willSet {
            if lastSize != newValue {
                if let newValue = newValue {
                    onSizeChange(from: lastSize, to: newValue)
                    bottomSheetDelegate?.onSizeChange(from: lastSize, to: newValue)
                    background.horizontalSize = newValue
                    
                    if let vc = visibleViewController as? BottomSheetPage
                    {
                        vc.onStateChange(horizontalSize: newValue)
                    }
                }
            }
            
        }
    }
    
    var currentSize: HorizontalSize {
        let windowWidth = containerView.frame.width
        
        if windowWidth > Constants.minWidthForSmallSize { return .small }
        if windowWidth > Constants.minWidthForUltraSmallSize { return .ultraSmall }
        
        return .big
    }
    
    lazy var background: Background = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(Background())
    
    lazy var safeZone: UIView = {
        return $0
    }(SafeZone())

    public init(parentVC: UIViewController, rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        let gr = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        view.addGestureRecognizer(gr)
        if let vc = rootViewController as? BottomSheetPage {
            vc.onButtomSheetScroll(progress: 1)
            vc.onStateChange(verticalSize: state)
        }
        
        parentVC.view.addSubview(background)
        parentVC.view.addSubview(safeZone)
        
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: parentVC.view.trailingAnchor),
            background.topAnchor.constraint(equalTo: parentVC.view.topAnchor),
            background.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor)
        ])
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
        if let vc = vc as? BottomSheetPage {
            if let lastSize = lastSize {
                vc.onStateChange(horizontalSize: lastSize)
            }
            vc.onStateChange(verticalSize: state)
            applyProgress(vc: vc, current: view.frame.origin.y)
        }
    }
    
    func applyProgress(vc: UIViewController?, current: CGFloat, from: CGFloat? = nil, to: CGFloat? = nil) {
        
        let from = from ?? position(for: .small)
        let to = to ?? position(for: .big)
        let fullProgress = progress(for: current, from: from, to: to)
        
        bottomSheetDelegate?.onProgressChange(progress: fullProgress)
        background.progress(progress(for: current, from: position(for: .big), to: position(for: .medium)))
        
        if let vc = vc as? BottomSheetPage {
            vc.onButtomSheetScroll(progress: fullProgress)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (mooved || moovedByScroll) == false { currentPosition = position(for: state) }
        
        let currentSize = currentSize
        let safeArea = containerView.safeAreaInsets
        
        let height = height(for: currentSize)

        view.frame = CGRect(
            x: currentSize == .big ? 0 : max(safeArea.left, 8),
            y: currentPosition,
            width: width(for: currentSize),
            height: height
        )
        
        if currentSize == .big {
            safeZone.frame = CGRect(origin: .zero, size: CGSize(width: containerView.frame.width, height: currentPosition))
        } else {
            let offset = progress(for: currentPosition,
                                     from: position(for: .medium),
                                     to: position(for: .small)).clamped(0, 1) * view.frame.maxX
            
            safeZone.frame = CGRect(origin: CGPoint(x: offset, y: 0),
                                    size: CGSize(width: containerView.frame.width - offset, height: containerView.frame.height))
        }
        
        
        safeZone.layoutIfNeeded()
        view.layoutIfNeeded()
        
        lastSize = currentSize
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
        
        let safeAreaOffset = currentSize == .big ? safeArea.bottom : max(20, safeArea.bottom)
        
        switch size {
        case .big:
            return window.height - currentPosition + safeArea.top - safeAreaOffset
        case .small, .ultraSmall:
            return max(60, window.height - currentPosition - safeAreaOffset)
        }
    }
    
    func position(for state: VerticalSize) -> CGFloat {
        let safeArea = containerView.safeAreaInsets
        let height = containerView.frame.height
        
        let safeAreaOffset = currentSize == .big ? safeArea.bottom : max(20, safeArea.bottom)
        
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
        func nearestState(pos: CGFloat, possibleStates: [VerticalSize]) -> VerticalSize {
            var nearestDistance = CGFloat.greatestFiniteMagnitude
            var nearestState = VerticalSize.small
            
            for state in possibleStates {
                let distance = abs(position(for: state) - pos)
                if distance < nearestDistance {
                    nearestState = state
                    nearestDistance = distance
                }
            }
            
            return nearestState
        }
        
        var singlePosible: [VerticalSize] = []
        switch state {
        case .small:
            singlePosible = [.small, .medium]
        case .medium:
            singlePosible = [.small, .big, .medium]
        case .big:
            singlePosible = [.big, .medium]
        }
        
        let nearestSingle = nearestState(pos: UIGestureRecognizer.project(velocity, onto: currentPosition, decelerationRate: .init(rawValue: 0.995)),
                                         possibleStates: singlePosible)
        
        let nearestMulty = nearestState(pos: UIGestureRecognizer.project(velocity, onto: currentPosition, decelerationRate: .fast),
                                        possibleStates: [.small, .big, .medium])
        
        if abs(state.rawValue - nearestMulty.rawValue) > 1 {
            return nearestMulty
        } else {
            return nearestSingle
        }
    }
    
    var anim: UIViewPropertyAnimator?
    
    @objc
    private func panAction(_ sender: UIPanGestureRecognizer) {
        defer { viewDidLayoutSubviews() }
        
        let translation = sender.translation(in: containerView)
        
        switch sender.state {
        case .began:
            mooved = true
            anim?.tryStopAnimation(true)
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
            
            applyProgress(vc: visibleViewController, current: currentPosition, from: smallerPos, to: biggerPos)
            
        case.ended:
            mooved = false
            endAnimation(sender.velocity(in: view).y)
        default: break
        }
        
    }
    
    private func endAnimation(_ velocity: CGFloat) {
        state = nextState(velocity: velocity)
        
        let delta = position(for: state) - currentPosition
        
        let initialVelocity = velocity / delta
        
        let timing = UISpringTimingParameters(damping: initialVelocity > 0.01 ? 0.8 : 1, response: 0.35, initialVelocity: CGVector(dx: initialVelocity, dy: initialVelocity))
        anim?.tryStopAnimation(true)
        anim = UIViewPropertyAnimator(duration: 0, timingParameters: timing)
        
        anim?.addAnimations { [self] in
            currentPosition = position(for: state)
            applyProgress(vc: visibleViewController, current: currentPosition)
            viewDidLayoutSubviews()
        }
        
        anim?.startAnimation()
    }
    
    func changeState(state: VerticalSize, duration: CGFloat = Constants.transitionDuration, animated: Bool = true, options: UIView.AnimationOptions = .curveEaseOut) {
        self.state = state
        
        currentPosition = position(for: state)
        if animated {
            UIView.animate(withDuration: duration, delay: 0, options: [options, .allowUserInteraction], animations: { [self] in
                viewDidLayoutSubviews()
                applyProgress(vc: visibleViewController, current: currentPosition)
            })
        } else {
            viewDidLayoutSubviews()
            applyProgress(vc: visibleViewController, current: currentPosition)
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
                var changeTo = VerticalSize.medium
                
                switch popControllerStrategy {
                case .alwaysMinimaze:
                    if targetState == .small || state == .small { changeTo = .small }
                case .mediumIfNeed:
                    if (targetState == .small && state == .big) || state == .small { changeTo = .small }
                }
                
                changeState(state: changeTo, animated: false)
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
    func horizontalSize() -> HorizontalSize {
        return currentSize
    }
    
    func verticalSize() -> VerticalSize {
        return state
    }
    
    func change(verticalSize: VerticalSize, animated: Bool) {
        changeState(state: verticalSize, duration: 0.3, animated: animated, options: .curveEaseInOut)
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let offset = scrollView.topContentOffset.y
        if -30 < offset && offset <= 3 {
            moovedByScroll = true
            startContentOffset = offset
            startPosotion = view.layer.presentation()!.frame.origin.y
            anim?.tryStopAnimation(true)
            currentPosition = startPosotion
            viewDidLayoutSubviews()
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
            
            applyProgress(vc: visibleViewController, current: currentPosition, from: smallerPos, to: biggerPos)
            viewDidLayoutSubviews()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if moovedByScroll {
            moovedByScroll = false
            endAnimation(-velocity.y * 1000)
            
            if startPosotion != position(for: .big) && scrollView.topContentOffset.y <= 0  {
                targetContentOffset.pointee = CGPoint(x: 0, y: -scrollView.topOffset)
            }
        }
    }
}

extension BottomSheetViewController {
    func onStateChange(from: VerticalSize, to: VerticalSize) { }
    
    func onSizeChange(from: HorizontalSize?, to: HorizontalSize) { }
    
}

class SafeZone: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit != self {
            return hit
        }
        
        return nil
    }
}

class Background: UIView {
    private var blockIsEnable = false {
        didSet {
            isUserInteractionEnabled = horizontalSize == .big ? blockIsEnable : false
        }
    }
    
    var horizontalSize: BottomSheetViewController.HorizontalSize? {
        didSet {
            progress(self.progress)
        }
    }
    
    private var progress = 0.0 {
        didSet {
            blockIsEnable = progress > 0.1
            
            if horizontalSize == .big {
                backgroundColor = .black.withAlphaComponent(max(0, min(1, progress)) * 0.5)
            } else {
                backgroundColor = .clear
            }
        }
    }
    
    func progress(_ progress: CGFloat) {
        self.progress = progress
    }
}

fileprivate func expLimit(_ x: CGFloat, _ maxVal: CGFloat) -> CGFloat {
    return (1 - exp(-x / maxVal)) * maxVal
}

fileprivate func progress(for val: CGFloat, from: CGFloat, to: CGFloat) -> CGFloat {
    return (val - to) / (from - to)
}
