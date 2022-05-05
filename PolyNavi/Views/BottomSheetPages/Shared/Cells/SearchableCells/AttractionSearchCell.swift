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
        return $0
    }(UILabel())
    
    private lazy var iconAttraction: AttractionSearchIcon = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(AttractionSearchIcon())
    
    
    override func setViews() {
        super.setViews()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconAttraction)
        
        insertSubview(separator, belowSubview: contentView)
        
        NSLayoutConstraint.activate([
            iconAttraction.widthAnchor.constraint(equalToConstant: 35),
            iconAttraction.heightAnchor.constraint(equalToConstant: 35),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
        ].priority(.required))
        
        NSLayoutConstraint.activate([
            iconAttraction.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            iconAttraction.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconAttraction.trailingAnchor, constant: 10),
    
            contentView.bottomAnchor.constraint(equalTo: iconAttraction.bottomAnchor, constant: 10)
        ].priority(.defaultHigh))
    }
    
    override func configurate(searchable: Searchable) {
        titleLabel.text = searchable.mainTitle
        iconAttraction.configurate(searchable: searchable)
    }
}
