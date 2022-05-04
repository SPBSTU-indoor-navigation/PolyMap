//
//  OccupantSearchCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 25.03.2022.
//

import UIKit

class OccupantSearchCell: BaseSearchCell {
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
    
    private lazy var iconOccuptant: OccupantSearchIcon = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(OccupantSearchIcon())
    
    override func setViews() {
        super.setViews()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(iconOccuptant)
        
        insertSubview(separator, belowSubview: contentView)
        
        NSLayoutConstraint.activate([
            iconOccuptant.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            iconOccuptant.widthAnchor.constraint(equalToConstant: 35),
            iconOccuptant.heightAnchor.constraint(equalToConstant: 35),
            iconOccuptant.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: iconOccuptant.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 10)
        ].priority(.required))
        
    }
    
    override func configurate(searchable: Searchable) {
        titleLabel.text = searchable.mainTitle
        subTitleLabel.text = "\(searchable.place ?? "") • \(searchable.floor ?? "")"
        iconOccuptant.configurate(searchable: searchable)
    }
}
