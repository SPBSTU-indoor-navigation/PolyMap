import UIKit
import UIScreenExtension

fileprivate func expLimit(_ x: CGFloat, _ maxVal: CGFloat) -> CGFloat {
    return (1 - exp(-x / maxVal)) * maxVal
}

class RootBottomSheetViewController: UINavigationController {
    private enum Constants {
        static let velocityLimit = 8.0
        static let velocitySuperLimit = 80.0
        
        static let minWidthForSmallSize = 1000.0
        static let minWidthForUltraSmallSize = 800.0
        
        static let smallWidth = 380.0
        static let ultraSmallWidth = 320.0
        
        static let smallHeight = 100.0
        static let mediumHeight = 305.0
    }
    
    private enum HorizontalSize {
        case big
        case small
        case ultraSmall
    }
    
    enum VerticalSize {
        case small
        case medium
        case big
        
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
    
    private var containerView: UIView {
        return view.window!
    }
    
    private var currentSize: HorizontalSize {
        let windowWidth = containerView.frame.width
        
        if windowWidth > Constants.minWidthForSmallSize { return .small }
        if windowWidth > Constants.minWidthForUltraSmallSize { return .ultraSmall }
        
        return .big
    }
    
    
    
    public init(parentVC: UIViewController, rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        let gr = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        rootViewController.view.subviews.forEach({
            if let scroll = $0 as? UIScrollView {
                scroll.delegate = self
                return
            }
        })
        view.addGestureRecognizer(gr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
        blurView.frame = view.frame
        view.insertSubview(blurView, at: 0)
        
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
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
            return window.height - position(for: .big) + safeArea.top
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
}

extension RootBottomSheetViewController: UIScrollViewDelegate {
    
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


extension UIScrollView {
    
    var topOffset: CGFloat {
        return safeAreaInsets.top
    }
    
    var topContentOffset: CGPoint {
        get {
            return CGPoint(x: contentOffset.x, y: contentOffset.y + topOffset)
        }
        
        set(val) {
            contentOffset = CGPoint(x: val.x, y: val.y - topOffset)
        }
    }
}
