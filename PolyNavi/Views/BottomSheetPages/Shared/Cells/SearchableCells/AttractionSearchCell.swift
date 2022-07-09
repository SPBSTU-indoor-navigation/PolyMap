//
//  AttractionSearchCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 25.03.2022.
//

import UIKit

class AttractionSearchCell: BaseSearchCell {
    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .body)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    
    private lazy var iconAttraction: AttractionSearchIcon = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(AttractionSearchIcon())
    
    
    var icon: UIView & SearchableConfigurate {
        return iconAttraction
    }
    
    override func setViews() {
        super.setViews()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(icon)
        
        insertSubview(separator, belowSubview: contentView)
        
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 35),
            icon.heightAnchor.constraint(equalToConstant: 35),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
        ].priority(.required))
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
    
            contentView.bottomAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10)
        ].priority(.required))
    }
    
    override func configurate(searchable: Searchable) {
        titleLabel.text = searchable.mainTitle
        icon.configurate(searchable: searchable)
    }
}
