//
//  AttractionSearchCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 25.03.2022.
//

import UIKit

class AttractionSearchCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .body)
        return $0
    }(UILabel())
    
    private lazy var shortTitle: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Asset.Annotation.Colors.attractionBorder.color
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        return $0
    }(UILabel())
    
    lazy var icon: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 35/2
        $0.layer.masksToBounds = true
        $0.layer.minificationFilter = .trilinear
        $0.layer.minificationFilterBias = 0.1
        $0.layer.borderColor = Asset.Annotation.Colors.attractionBorder.color.cgColor
        $0.layer.borderWidth = 1
        return $0
    }(UIImageView())
    
    private lazy var separator: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .separator
        return $0
    }(UIView())
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        icon.addSubview(shortTitle)
        contentView.addSubview(icon)
        
        insertSubview(separator, belowSubview: contentView)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            icon.widthAnchor.constraint(equalToConstant: 35),
            icon.heightAnchor.constraint(equalToConstant: 35),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            shortTitle.centerXAnchor.constraint(equalTo: icon.centerXAnchor),
            shortTitle.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
        
            contentView.bottomAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10)
        ])
    }
    
    func configurate(searchable: Searchable) {
        titleLabel.text = searchable.mainTitle
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
