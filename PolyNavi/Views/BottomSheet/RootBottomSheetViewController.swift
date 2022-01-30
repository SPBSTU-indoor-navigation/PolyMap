import UIKit

class RootBottomSheetViewController: UINavigationController {
    
    enum SizeOfSheet {
        case fullScreen
        case partOfScreen
    }
    
    private var sizeState: SizeOfSheet {
        get {
            let parentFrame = parentVC.view.frame
            return parentFrame.size.width > 800 ? .partOfScreen : .fullScreen
        }
    }
    
    private var parentVC: UIViewController!
    
    private var yPostion: CGFloat = 0.0
    
    private var minYPosition: CGFloat {
        let parentFrame = parentVC.view.frame
        let navigationFrame = navigationBar.frame
        return parentFrame.size.height - navigationFrame.size.height - 20
    }
    
    private var middleYPosition: CGFloat {
        return parentVC.view.frame.size.height * 0.4
    }
    
    private var maxYPosition: CGFloat {
        parentVC.view.frame.size.height * 0.2
    }
    
    private let searchOverlay = HitAcrossView()
    
    public init(parentVC: UIViewController, rootViewController: UIViewController) {
        self.parentVC = parentVC
        
        super.init(rootViewController: rootViewController)
        
        let gr = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        navigationBar.addGestureRecognizer(gr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 15
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if yPostion == 0 {
            yPostion = minYPosition
        }
        
        let parentFrame = parentVC.view.frame
        view.frame = CGRect(
            x: sizeState == .fullScreen ? 0 : 10,
            y: yPostion,
            width: sizeState == .fullScreen ? parentFrame.size.width : parentFrame.size.width * 0.45,
            height: parentFrame.height * 0.8
        )
    }
    
    @objc
    private func panAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: parentVC.view)
        let viewHeight = parentVC.view.frame.height * 0.8
        let velocity = sender.velocity(in: navigationBar)
        let slideFactor = 0.1
        let minYPos = parentVC.view.frame.height - viewHeight
        switch sender.state {
        case .began:
            if location.y > minYPos {
                changeLocation(yPos: location.y)
            }
            return
        case.changed:
            if location.y > minYPos {
                changeLocation(yPos: location.y)
            }
            return
        case.ended:
            if location.y > minYPos {
                endLocation(yPos: location.y + velocity.y * slideFactor)
            }
            return
        default:
            return
        }
    }
    
    func changeLocation(yPos: CGFloat) {
        yPostion = yPos
        viewDidLayoutSubviews()
    }
    
    func endLocation(yPos: CGFloat) {
        let animationDuration = CGFloat(0.08)
        defer {
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                self?.viewDidLayoutSubviews()
            })
        }
        
        let padding = CGFloat(15)
        
        if yPos >= minYPosition - padding {
            yPostion = minYPosition
            return
        }
        let t = middleYPosition - padding
        let b = middleYPosition + padding
        if yPos <= t || yPos >= b {
            yPostion = middleYPosition
            return
        }
        
        yPostion = maxYPosition
    }
}
