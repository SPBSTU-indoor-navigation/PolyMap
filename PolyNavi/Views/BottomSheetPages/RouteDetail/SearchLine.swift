//
//  SearchLine.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 15.04.2022.
//

import UIKit


class SearchLine: UIView {
    class TextField: UITextField {
        
        var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        override open func textRect(forBounds bounds: CGRect) -> CGRect {
            return super.textRect(forBounds: bounds).intersection(bounds.inset(by: padding))
        }
        
        override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return super.placeholderRect(forBounds: bounds).intersection(bounds.inset(by: padding))
        }
        
        override open func editingRect(forBounds bounds: CGRect) -> CGRect {
            return super.editingRect(forBounds: bounds).intersection(bounds.inset(by: padding))
        }
    }
    
    
    var beginEditing: ((String) -> Void)?
    var didChange: ((String) -> Void)?
    var endEditing: (() -> Void)?
    
    var maskCorners: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] {
        didSet {
            containerView.layer.maskedCorners = maskCorners
        }
    }
    
    var isSearch = false {
        didSet {
            UIView.animate(withDuration: 0.3, animations: { [self] in
                if isSearch {
                    textField.padding = .init(top: 0, left: 0, bottom: 0, right: 30)
                    NSLayoutConstraint.activate(selectedConstraints)
                    backgroundView.layer.cornerRadius = 10
                } else {
                    textField.padding = .init(top: 0, left: 0, bottom: 0, right: 50)
                    NSLayoutConstraint.deactivate(selectedConstraints)
                    cancelButton.alpha = 0
                    backgroundView.layer.cornerRadius = 0
                }
                
                layoutIfNeeded()
            }, completion: { _ in
                if self.isSearch {
                    self.textField.clearButtonMode = .always
                }
            })
            
            if isSearch {
                UIView.animate(withDuration: 0.1, animations: { [self] in
                    cancelButton.alpha = 1
                })
            }
            
            if !isSearch {
                self.textField.clearButtonMode = .never
            }
        }
    }
    
    var searchable: Searchable? = nil
    var isEditing = false
    
    lazy var containerView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.cornerCurve = .continuous
        return $0
    }(UIButton())
    
    lazy var backgroundView: UIView = {
        $0.layer.cornerCurve = .continuous
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.backgroundColor = Asset.Colors.searchBarBackground.color
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(labelTap))
        $0.addGestureRecognizer(tap)
        return $0
    }(UIButton())
    
    lazy var textField: TextField = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = L10n.MapInfo.Route.Info.search
        $0.delegate = self
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.tintColor = Asset.accentColor.color
        $0.spellCheckingType = .no
        $0.clearButtonMode = .never
        $0.returnKeyType = .search
        $0.enablesReturnKeyAutomatically = true
        $0.padding = .init(top: 0, left: 0, bottom: 0, right: 50)
        $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return $0
    }(TextField())
    
    lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "From:"
        $0.textColor = .secondaryLabel
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return $0
    }(UILabel())
    
    lazy var cancelButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Cancel", for: .normal)
        $0.setTitleColor(Asset.accentColor.color, for: .normal)
        $0.setTitleColor(Asset.accentColor.color.withAlphaComponent(0.8), for: .selected)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.alpha = 0
        
        $0.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        return $0
    }(UIButton())
    
    var selectedConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        addSubview(cancelButton)
        containerView.addSubview(backgroundView)
        addSubview(textField)
        backgroundView.addSubview(titleLabel)
        
        
        selectedConstraints = [
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ].priority(.required)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -10),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor).withPriority(.defaultHigh),
            
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor).withPriority(.defaultLow),
            cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ searchable: Searchable?) {
        self.searchable = searchable
        setText()
    }
    
    private func setText() {
        textField.text = searchable?.mainTitle ?? ""
    }
    
    @objc
    func labelTap(_ sender: UITapGestureRecognizer?) {
        textField.becomeFirstResponder()
    }
    
    @objc
    func cancel(_ sender: UIButton?) {
        endSearch()
    }
    
    func endSearch() {
        isSearch = false
        textField.endEditing(true)
        endEditing?()
        setText()
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        self.didChange?(textField.text ?? "")
    }
    

}

extension SearchLine: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !isSearch {
            isSearch = true
        }
        
        if !self.isEditing {
            beginEditing?(textField.text ?? "")
            DispatchQueue.main.async { self.isEditing = true }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isEditing = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
