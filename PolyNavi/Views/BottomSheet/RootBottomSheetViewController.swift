import UIKit
import UIScreenExtension

fileprivate func expLimit(_ x: CGFloat, _ maxVal: CGFloat) -> CGFloat {
    return (1 - exp(-x / maxVal)) * maxVal
}

class RootBottomSheetViewController: UINavigationController {
    private enum Constants {
        static let velocityLimit = 8.0
        static let velocitySuperLimit = 80.0
    }
    
    enum HorizontalSize {
        case big
        case small
        case ultraSmall
    }
    
    enum VerticalSize {
        case small
        case middle
        case big
        
        var stateBigger: [VerticalSize] {
            switch self {
            case .small: return [.middle, .big]
            case .middle, .big: return [.big]
            }
        }
        
        var stateSmaller: [VerticalSize] {
            switch self {
            case .small, .middle: return [.small]
            case .big: return [.small, .middle]
            }
        }
    }
    
    
    private var state: VerticalSize = .small
    private var currentPosition: CGFloat = -1
    
    private var parentVC: UIViewController!
    private let searchOverlay = HitAcrossView()
    var scrollView: UIScrollView?
    
    private var currentSize: HorizontalSize {
        let windowWidth = view.window!.frame.width
        
        if windowWidth > 1000 { return .small }
        if windowWidth > 800 { return .ultraSmall }
        
        return .big
    }
    

    public init(parentVC: UIViewController, rootViewController: UIViewController) {
        self.parentVC = parentVC
        
        super.init(rootViewController: rootViewController)
    
        let gr = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        
        rootViewController.view.subviews.forEach({
            if let scroll = $0 as? UIScrollView {
                scroll.panGestureRecognizer.require(toFail: gr)
                scrollView = scroll
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
        
        if currentPosition < 0 { currentPosition = position(for: state) }
        
        let safeArea = view.window!.safeAreaInsets
        
        view.frame = CGRect(
            x: currentSize == .big ? 0 : max(safeArea.left, 8),
            y: currentPosition,
            width: width(for: currentSize),
            height: height(for: currentSize)

        )
    }
    
    
    func width(for size: HorizontalSize) -> CGFloat {
        switch size {
        case .big:
            return view.window!.frame.width
        case .small:
            return 380
        case .ultraSmall:
            return 320
        }
    }
    
    func height(for size: HorizontalSize) -> CGFloat {
        
        let safeArea = view.window!.safeAreaInsets
        let window = view.window!.frame
        
        switch size {
        case .big:
            return window.height - position(for: .big) + safeArea.top
        case .small, .ultraSmall:
            return window.height - currentPosition - safeArea.bottom
        }
    }
    
    func position(for state: VerticalSize) -> CGFloat {
        let safeArea = view.window!.safeAreaInsets
        let height = view.window!.frame.height
        
        let safeAreaOffset = currentSize == .big ? safeArea.bottom : 0
        
        switch state {
        case .small:
            return height - safeAreaOffset - 100
        case .middle:
            return height - safeAreaOffset - 305
        case .big:
            return safeArea.top + 20
        }
    }
    
    func nextState(velocity: CGFloat) -> VerticalSize {
        
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
            possibleStates = [.small, .big, .middle]
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
    
    
    var startDelta = 0.0
    
    @objc
    private func panAction(_ sender: UIPanGestureRecognizer) {
        defer { viewDidLayoutSubviews() }
        
        let location = sender.location(in: view.window!)
        let velocity = sender.velocity(in: view.window!)

        switch sender.state {
        case .began:
            view.layer.removeAllAnimations()
            currentPosition = view.layer.presentation()!.frame.origin.y
            startDelta = currentPosition - location.y
        case.changed:
            let smallerPos = position(for: .small)
            let biggerPos = position(for: .big)
            let targetPosition = location.y + startDelta
            
            if biggerPos < targetPosition && targetPosition < smallerPos {
                currentPosition = targetPosition
            } else if targetPosition > smallerPos {
                let delta = targetPosition - smallerPos
                currentPosition = smallerPos + expLimit(delta, 50)
            } else if targetPosition < biggerPos {
                let delta = biggerPos - targetPosition
                currentPosition = biggerPos - expLimit(delta, 20)
            }
            
        case.ended:
            state = nextState(velocity: velocity.y)
            let delta = abs(currentPosition - position(for: state))
            currentPosition = position(for: state)
            
            let initialSpeed = min(abs(velocity.y / delta / 2), 5)
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: initialSpeed, options: [.curveEaseIn, .allowUserInteraction], animations: { [self] in
                viewDidLayoutSubviews()
            })
        default:
            return
        }
    }
}
