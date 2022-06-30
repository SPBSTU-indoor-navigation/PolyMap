//
//  BaseCellTitled.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 01.06.2022.
//

import UIKit

class BaseCellTitled: UITableViewCell {
    lazy var title: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .body)
        $0.numberOfLines = 3
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    
    lazy var container: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(container)
        container.addSubview(title)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            title.topAnchor.constraint(equalTo: container.topAnchor),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.bottomAnchor.constraint(equalTo: title.bottomAnchor),
            
            contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 10)
        ].priority(.required))
        
        NSLayoutConstraint.activate([
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor).with(priority: .defaultHigh)
        ])
        

        backgroundColor = Asset.Colors.bottomSheetGroupped.color

    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
