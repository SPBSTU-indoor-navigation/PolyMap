//
//  SimpleShareCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.04.2022.
//

import UIKit

class SimpleShareCell: BaseCellTitled {
    static var identifire = String(describing: SimpleShareCell.self)
    
    lazy var image: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        return $0
    }(UIImageView())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        title.text = L10n.MapInfo.share
        
        container.addSubview(image)
        
        NSLayoutConstraint.activate([
            image.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            image.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            title.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -10)
        ].priority(.required))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
