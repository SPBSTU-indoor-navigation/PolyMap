import UIKit

class OpacityHitTest: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit != self {
            return hit
        }
        
        return nil
    }
}
