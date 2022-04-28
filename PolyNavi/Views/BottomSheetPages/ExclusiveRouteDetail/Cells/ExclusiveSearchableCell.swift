//
//  ExclusiveSearchableCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 28.04.2022.
//

import UIKit

class ExclusiveSearchableCell: UITableViewCell {
    static var identifire = String(describing: ExclusiveSearchableCell.self)
    
    var lastIcon: UIView?
    
    lazy var title: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    lazy var name: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return $0
    }(UILabel())
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.addSubview(title)
        contentView.addSubview(name)
        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            
            name.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            name.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            name.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 5).withPriority(.defaultHigh)
        ])
        
        backgroundColor = Asset.Colors.bottomSheetGroupped.color
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    func configurate(searchable: Searchable, title: String) {
        self.title.text = title
        name.text = searchable.mainTitle
    
        lastIcon?.removeFromSuperview()
        
        if let icon = SearchShared.createIcon(for: searchable) {
            icon.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(icon)
            
            NSLayoutConstraint.activate([
                icon.widthAnchor.constraint(equalToConstant: 20),
                icon.heightAnchor.constraint(equalToConstant: 20),
                
                icon.leadingAnchor.constraint(equalTo: self.title.trailingAnchor, constant: 2.5),
                icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                
                name.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 2.5)
            ])
            
            lastIcon = icon
        }
    }
}
