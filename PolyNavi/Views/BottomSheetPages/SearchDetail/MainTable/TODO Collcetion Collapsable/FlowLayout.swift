import UIKit

enum LayoutType {
    case list
    case strip
}

struct SharedLayout {
    static var previousTopIndexPath: IndexPath?
}

protocol FlowLayoutCell {
    func layoutBeginChange(layoutType: LayoutType)
}

class FlowLayout: UICollectionViewFlowLayout {
    
    var layoutType: LayoutType
    var sizeForListItemAt: ((IndexPath) -> CGSize)?
    var sizeForStripItemAt: ((IndexPath) -> CGSize)?
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    var contentSize = CGSize.zero
    override var collectionViewContentSize: CGSize { return contentSize }
    
    override func prepare() {
        super.prepare()
        print("preparing \(layoutType)")
        
        guard let collectionView = collectionView else { return }
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        if layoutType == .list {
            var y: CGFloat = 0
            for itemIndex in 0..<itemCount {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(
                    x: 0,
                    y: y,
                    width: sizeForListItemAt?(indexPath).width ?? 0,
                    height: sizeForListItemAt?(indexPath).height ?? 0
                )
                layoutAttributes.append(attributes)
                y += attributes.frame.height
            }
            contentSize = CGSize(width: sizeForStripItemAt?(IndexPath(item: 0, section: 0)).width ?? 0, height: y)
        } else {
            var x: CGFloat = 0
            for itemIndex in 0..<itemCount {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(
                    x: x,
                    y: 0,
                    width: sizeForStripItemAt?(indexPath).width ?? 0,
                    height: sizeForStripItemAt?(indexPath).height ?? 0
                )
                layoutAttributes.append(attributes)
                x += attributes.frame.width
            }
            contentSize = CGSize(width: x, height: sizeForStripItemAt?(IndexPath(item: 0, section: 0)).height ?? 0)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter { rect.intersects($0.frame) }
    }
    
    override func prepareForTransition(to newLayout: UICollectionViewLayout) {
        print("\(layoutType) layout is being removed")
        guard let collectionView = collectionView else { return }
        
        if let currentIndexPath = collectionView.indexPathForItem(at: collectionView.contentOffset) {
            SharedLayout.previousTopIndexPath = currentIndexPath
        
//            if let cell = collectionView.cellForItem(at: currentIndexPath) as? Cell {
//                cell.colorView.backgroundColor = UIColor.systemBlue
//            }
        }
        
        if let newLayout = newLayout as? FlowLayout {
            for cell in collectionView.visibleCells.compactMap({ $0 as? FlowLayoutCell }) {
                cell.layoutBeginChange(layoutType: newLayout.layoutType)
            }
        }
        
    }
    
    override func finalizeLayoutTransition() {
        print("finalizeLayoutTransition")
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let previousTopIndexPath = SharedLayout.previousTopIndexPath else { return proposedContentOffset }

        if layoutAttributes.count > previousTopIndexPath.item {
            let attributes = layoutAttributes[previousTopIndexPath.item]
            let newOriginForOldIndex = attributes.frame.origin
            return newOriginForOldIndex
        } else {
            return proposedContentOffset
        }
    }

    init(layoutType: LayoutType) {
        self.layoutType = layoutType
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}

