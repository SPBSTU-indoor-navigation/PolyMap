//
//  AttractionSearchIcon.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 31.03.2022.
//

import UIKit

class AttractionSearchIcon: UIView, SearchableConfigurate {
    
    var border = 1.0 {
        didSet {
            icon.layer.borderWidth = border
        }
    }
    
    private lazy var shortTitle: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Asset.Annotation.Colors.attractionBorder.color
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        return $0
    }(UILabel())
    
    lazy var icon: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.masksToBounds = true
        $0.layer.minificationFilter = .trilinear
        $0.layer.minificationFilterBias = 0.1
        $0.layer.borderColor = Asset.Annotation.Colors.attractionBorder.color.cgColor
        $0.layer.borderWidth = border
        return $0
    }(UIImageView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.layer.cornerRadius = frame.width / 2
        shortTitle.font = .systemFont(ofSize: frame.height / 2, weight: .bold)
    }
    
    func setupViews() {
        icon.addSubview(shortTitle)
        addSubview(icon)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor),
            icon.trailingAnchor.constraint(equalTo: trailingAnchor),
            icon.topAnchor.constraint(equalTo: topAnchor),
            icon.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            shortTitle.centerXAnchor.constraint(equalTo: icon.centerXAnchor),
            shortTitle.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
        ])
    }
    
    func configurate(searchable: Searchable) {
        icon.image = searchable.annotationSprite
        icon.backgroundColor = Asset.Annotation.Colors.attractionBackground.color
        shortTitle.text = searchable.additionalTitle
        shortTitle.isHidden = searchable.annotationSprite != nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                icon.layer.borderColor = Asset.Annotation.Colors.attractionBorder.color.cgColor
            }
        }
    }
}
