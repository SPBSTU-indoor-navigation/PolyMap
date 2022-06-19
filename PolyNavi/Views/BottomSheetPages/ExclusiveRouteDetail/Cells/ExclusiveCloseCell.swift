//
//  ExclusiveCloseCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 27.04.2022.
//

import UIKit

class ExclusiveCloseCell: UITableViewCell {
    static var identifire = String(describing: ExclusiveCloseCell.self)
    
    lazy var label: TintedUILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.tintColor = .systemRed
        return $0
    }(TintedUILabel())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Asset.Colors.bottomSheetGroupped.color
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 56),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            label.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 5),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 5).with(priority: .defaultLow),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.5)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configurate(title: String) { 
        imageView?.image = UIImage(systemName: "xmark")
        imageView?.tintColor = .systemRed
        label.text = title
    }
}
