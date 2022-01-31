import UIKit
import UIScreenExtension

func expLimit(_ x: CGFloat, _ maxVal: CGFloat) -> CGFloat {
    return (1 - exp(-x / maxVal)) * maxVal
}

class RootBottomSheetViewController: UINavigationController {
    let VELOCITY_LIMIT = 8.0
    let VELOCITY_SUPER_LIMIT = 40.0
    
    
    enum Size {
        case big
        case small
        case ultraSmall
    }
    
    enum State {
        case min
        case middle
        case max
        
        var stateBigger: [State] {
            switch self {
            case .min: return [.middle, .max]
            case .middle, .max: return [.max]
            }
        }
        
        var stateSmaller: [State] {
            switch self {
            case .min, .middle: return [.min]
            case .max: return [.min, .middle]
            }
        }
    }
    
    
    private var state: State = .min
    private var currentPosition: CGFloat = -1
    
    private var parentVC: UIViewController!
    private let searchOverlay = HitAcrossView()
    var scrollView: UIScrollView?
    
    private var currentSize: Size {
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
        
        view.frame = CGRect(
            x: currentSize == .big ? 0 : max(view.window!.safeAreaInsets.left, 8),
            y: currentPosition,
            width: width(for: currentSize),
            height: 1000
        )
    }
    
    
    func width(for size: Size) -> CGFloat {
        switch size {
        case .big:
            return view.window!.frame.width
        case .small:
            return 380
        case .ultraSmall:
            return 320
        }
    }
    
    func position(for state: State) -> CGFloat {
        let safeArea = view.window!.safeAreaInsets
        let height = view.window!.frame.height
        
        switch state {
        case .min:
            return height - safeArea.bottom - 100
        case .middle:
            return height - safeArea.bottom - 305
        case .max:
            return safeArea.top + 20
        }
    }
    
    func nextState(velocity: CGFloat) -> State {
        
        var realVelocity = velocity / 60
        
        if let pointsPerCentimeter = UIScreen.pointsPerCentimeter {
            realVelocity = velocity / pointsPerCentimeter
        }
        
        if realVelocity > VELOCITY_SUPER_LIMIT { return .min}
        if realVelocity < -VELOCITY_SUPER_LIMIT { return .max}
        
        var possibleStates: [State] = []
        
        if realVelocity < -VELOCITY_LIMIT {
            possibleStates = state.stateBigger
        } else if realVelocity > VELOCITY_LIMIT {
            possibleStates = state.stateSmaller
        } else {
            possibleStates = [.min, .max, .middle]
        }
        
        var nearestDistance = CGFloat.greatestFiniteMagnitude
        var nearestState = State.min
        
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
        
        let location = sender.location(in: parentVC.view)
        let velocity = sender.velocity(in: view.window!)

        switch sender.state {
        case .began:
            view.layer.removeAllAnimations()
            currentPosition = view.layer.presentation()!.frame.origin.y
            startDelta = currentPosition - location.y
        case.changed:
            let minPos = position(for: .min)
            let maxPos = position(for: .max)
            let targetPosition = location.y + startDelta
            
            if maxPos < targetPosition && targetPosition < minPos {
                currentPosition = targetPosition
            } else if targetPosition > minPos {
                let delta = targetPosition - minPos
                currentPosition = minPos + expLimit(delta, 50)
            } else if targetPosition < maxPos {
                let delta = maxPos - targetPosition
                currentPosition = maxPos - expLimit(delta, 20)
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
