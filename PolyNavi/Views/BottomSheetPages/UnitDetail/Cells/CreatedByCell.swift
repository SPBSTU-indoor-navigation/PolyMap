import UIKit

class CreatedByCell: UITableViewCell, UnitDetailVC.PageWillBeginScrollDelegate {
    
    static var identifier = String(describing: CreatedByCell.self)
    
    var clickableRange: UITextRange? = nil
    var onClick: (() -> Void)? = nil
    private var attributedString: NSMutableAttributedString? = nil
    
    private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        $0.minimumPressDuration = 0
        $0.delegate = self
        $0.cancelsTouchesInView = false
        return $0
    }(UILongPressGestureRecognizer(target: self, action: #selector(tapLabel(recognizer:))))
    
    private lazy var view: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(longPressGestureRecognizer)
        return $0
    }(UIView())
    
    private lazy var titleTextView: UITextView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.isEditable = false
        $0.isSelectable = false
        $0.isScrollEnabled = false
        
        $0.textContainerInset = .init(top: 0, left: 0, bottom: 15, right: 0)
        $0.textContainer.lineFragmentPadding = 0
        
        $0.layer.opacity = 0
        return $0
    }(UITextView())
    
    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        view.addSubview(titleTextView)
        view.addSubview(titleLabel)
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleTextView.widthAnchor.constraint(equalTo: view.widthAnchor),
            titleTextView.topAnchor.constraint(equalTo: view.topAnchor),
            titleTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(title: LocalizedName, onClick: @escaping () -> Void) {
        self.onClick = onClick
        let infoText = title.bestLocalizedValue ?? ""
        let moreInfoText = L10n.MapInfo.Detail.moreInfo
        attributedString = NSMutableAttributedString(string: infoText + " " + moreInfoText, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: UIColor.secondaryLabel
        ])
        titleTextView.attributedText = attributedString
        titleLabel.attributedText = attributedString
        
        let beginning = titleTextView.position(from: titleTextView.beginningOfDocument, offset: infoText.count + 1)!
        clickableRange = titleTextView.textRange(from: beginning, to: titleTextView.position(from: beginning, offset: moreInfoText.count)!)
        updateMoreInfoTextColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.clipsToBounds = false
        layer.masksToBounds = false
    }
    
    func updateMoreInfoTextColor() {
        guard let range = clickableRange,
              let attributedString else { return }
        
        let location = titleTextView.offset(from: titleTextView.beginningOfDocument, to: range.start)
        let length = titleTextView.offset(from: range.start, to: range.end)
        
        attributedString.setAttributes([
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .foregroundColor: tintColor!
        ], range: NSRange(location: location, length: length))
        titleTextView.attributedText = attributedString
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
              let clickableRange else { return }
        
        let rect = titleTextView.firstRect(for: clickableRange)
        let tapLocation = recognizer.location(in: titleTextView)
        let offset = 15.0
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
