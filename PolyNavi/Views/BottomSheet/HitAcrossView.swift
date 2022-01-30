import UIKit

class HitAcrossView: UIView {
    
    var acrossAction: (() -> Void)?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        acrossAction?()
        return nil
    }
}
