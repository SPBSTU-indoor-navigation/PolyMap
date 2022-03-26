//
//  OccupantSearchCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 25.03.2022.
//

import UIKit

class OccupantSearchCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .body)
        return $0
    }(UILabel())
    
    private lazy var subTitleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    private lazy var icon: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    private lazy var iconContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 35 / 2
        return $0
    }(UIView())
    
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
        contentView.addSubview(subTitleLabel)
        iconContainer.addSubview(icon)
        contentView.addSubview(iconContainer)
        
        insertSubview(separator, belowSubview: contentView)
        
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            iconContainer.widthAnchor.constraint(equalToConstant: 35),
            iconContainer.heightAnchor.constraint(equalToConstant: 35),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 10)
        ].priority(.defaultHigh))
    }
    
    func configurate(searchable: Searchable) {
        titleLabel.text = searchable.mainTitle
        subTitleLabel.text = "\(searchable.place ?? "") • \(searchable.floor ?? "")"
        icon.image = searchable.annotationSprite
        iconContainer.backgroundColor = searchable.backgroundSpriteColor
    }
}
