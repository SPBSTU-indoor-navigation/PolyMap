import UIKit

class CreatedByCell: UITableViewCell, UnitDetailVC.PageWillBeginScrollDelegate {
    
    static var identifier = String(describing: CreatedByCell.self)
    
    var clickableRange: NSRange? = nil
    var onClick: (() -> Void)? = nil
    private var attributedString: NSMutableAttributedString? = nil
    
    private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        $0.minimumPressDuration = 0
        $0.delegate = self
        $0.cancelsTouchesInView = false
        return $0
    }(UILongPressGestureRecognizer(target: self, action: #selector(tapLabel(recognizer:))))
    
    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
        $0.textColor = .secondaryLabel
        $0.addGestureRecognizer(longPressGestureRecognizer)
        return $0
    }(UILabel())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(title: LocalizedName, onClick: @escaping () -> Void) {
        self.onClick = onClick
        let infoText = title.bestLocalizedValue ?? ""
        let moreInfoText = "Подробнее."
        attributedString = NSMutableAttributedString(string: infoText + " " + moreInfoText, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .footnote)
        ])
        
        clickableRange = .init(location: infoText.count + 1, length: moreInfoText.count)
        updateMoreInfoTextColor()
    }
    
    func updateMoreInfoTextColor() {
        guard let clickableRange,
              let attributedString else { return }
        
        attributedString.setAttributes([
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: tintColor!
        ], range: clickableRange)
        titleLabel.attributedText = attributedString
        
    }
    
    func pageWillBeginScroll(_ page: BottomSheetPage) {
        longPressGestureRecognizer.cancel()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateMoreInfoTextColor()
    }
    
    private func changeTint(_ color: UIColor?) {
        UIView.animate(withDuration: 0.2) { [self] in
            tintColor = color
        }
    }
    
    @objc func tapLabel(recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == .cancelled || recognizer.state == .failed {
            changeTint(nil)
            return
        }
        
        guard recognizer.state == .began || recognizer.state == .ended,
              let clickableRange,
              let rect = boundingRectForCharacterRange(range: clickableRange, inLabel: titleLabel) else { return }
        
        let tapLocation = recognizer.location(in: titleLabel)
        let offset = 5.0
        let clickIndide = rect.inset(by: .init(top: -offset, left: -offset, bottom: -offset, right: -offset)).contains(tapLocation)
        
        if recognizer.state == .began {
            if clickIndide {
                changeTint(.accent.darkerColor(brightness: 0.2))
            } else {
                longPressGestureRecognizer.cancel()
            }
        }
        
        if recognizer.state == .ended && clickIndide {
            changeTint(nil)
            onClick?()
        }
    }
}

extension CreatedByCell {
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == longPressGestureRecognizer || otherGestureRecognizer == longPressGestureRecognizer
    }
}

fileprivate func boundingRectForCharacterRange(range: NSRange, inLabel label: UILabel) -> CGRect? {
    // Ensure the label has attributed text
    guard let attributedText = label.attributedText else { return nil }
    
    // Create an NSTextStorage with the label's attributed text
    let textStorage = NSTextStorage(attributedString: attributedText)
    
    // Create an NSLayoutManager
    let layoutManager = NSLayoutManager()
    textStorage.addLayoutManager(layoutManager)
    
    // Create an NSTextContainer with the label's dimensions
    let textContainer = NSTextContainer(size: label.bounds.size)
    textContainer.lineFragmentPadding = 0.0  // Remove padding for accuracy
    textContainer.maximumNumberOfLines = label.numberOfLines
    textContainer.lineBreakMode = label.lineBreakMode
    layoutManager.addTextContainer(textContainer)
    
    // Calculate the glyph range for the character range
    let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
    
    // Get the bounding rectangle for the glyph range
    let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    
    return boundingRect
}
