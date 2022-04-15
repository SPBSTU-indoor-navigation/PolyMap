//
//  SearchLine.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 15.04.2022.
//

import UIKit

class SearchLine: UIView, UITextFieldDelegate {
    
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
                    NSLayoutConstraint.activate(selectedConstraints)
                    backgroundView.layer.cornerRadius = 10
                } else {
                    NSLayoutConstraint.deactivate(selectedConstraints)
                    cancelButton.alpha = 0
                    backgroundView.layer.cornerRadius = 0
                }
                
                layoutIfNeeded()
            }, completion: { _ in
                if self.isSearch {
                    self.textField.clearButtonMode = .whileEditing
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
        $0.clipsToBounds = true
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.backgroundColor = Asset.Colors.searchBarBackground.color
        return $0
    }(UIButton())
    
    lazy var textField: UITextField = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = "Search"
        $0.delegate = self
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.tintColor = Asset.accentColor.color
        $0.clearButtonMode = .never
        $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return $0
    }(UITextField())
    
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
        backgroundView.addSubview(textField)
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
    
    func setup(text: String) {
        textField.text = text
    }
    
    @objc
    func cancel(_ sender: UIButton?) {
        endSearch()
    }
    
    func endSearch() {
        isSearch = false
        textField.endEditing(true)
        endEditing?()
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        self.didChange?(textField.text ?? "")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isSearch = true
        beginEditing?(textField.text ?? "")
        
        DispatchQueue.main.async { self.isEditing = true }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isEditing = false
    }
}
