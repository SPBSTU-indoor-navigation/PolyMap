//
//  BaseAnnotationView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 21.03.2022.
//

import MapKit

protocol AnnotationMapSize {
    func update(mapSize: Float, animate: Bool)
}

protocol BoundingBox {
    func boundingBox() -> CGRect
}

protocol IndoorAnnotation {
    var building: Building { get }
    var level: Level { get }
}

class BaseAnnotationView<D: RawRepresentable>: PinnableAnnotationView, BoundingBox, AnnotationMapSize where D.RawValue == Int {
    
    var selectAnim = Animator()
    var deselectAnim = Animator()
    
    var detailLevel: D!
    var detailLevelProcessor: DetailLevelProcessor<DetailLevelState> { defaultDetailLevelProcessor }
    var state: DetailLevelState = .undefined

    @available(iOS 14.0, *)
    var defaultPriority: MKAnnotationViewZPriority { .init(rawValue: 500) }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func changeState(state: DetailLevelState, animate: Bool) { self.state = state }
    
    func boundingBox() -> CGRect { return frame }
    
    func appearanceDidChange() { }
    
    func update(mapSize: Float, animate: Bool) {
        let targetState = detailLevelProcessor.evaluate(forDetailLevel: detailLevel.rawValue, mapSize: mapSize) ?? .normal
        
        if state != targetState {
            changeState(state: targetState, animate: animate)
        }
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if #available(iOS 14.0, *) {
            unpinnedZPriority = defaultPriority
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            selectAnim.play(animated: animated)
        } else {
            deselectAnim.play(animated: animated)
        }
    }
    
    override func setPinned(_ pinned: Bool, animated: Bool) {
        super.setPinned(pinned, animated: animated)
        setSelected(isSelected, animated: animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                appearanceDidChange()
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if clipsToBounds || isHidden || alpha == 0 {
            return nil
        }
        
        if bounds.contains(point) {
            return self
        }
        return nil
    }
}
