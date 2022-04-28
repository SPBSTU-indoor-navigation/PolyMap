//
//  ShareAppClip.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.04.2022.
//

import UIKit

class ShareAppClip: UITableViewCell {
    static var identifire = String(describing: ShareAppClip.self)
 
    lazy var icon: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(systemName: "qrcode")
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    lazy var title: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = L10n.MapInfo.Route.Share.title
        $0.font = .preferredFont(forTextStyle: .body)
        return $0
    }(UILabel())
    
    lazy var subtitle: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = L10n.MapInfo.Route.Share.appClipQR
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 2
        return $0
    }(UILabel())
    
    lazy var container: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
        
        contentView.addSubview(icon)
        contentView.addSubview(container)
        container.addSubview(title)
        container.addSubview(subtitle)
        
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 50),
            icon.heightAnchor.constraint(equalToConstant: 50),
        ].priority(.required))
        
        NSLayoutConstraint.activate([
            
            icon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -11),
            icon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: icon.leadingAnchor, constant: -10),
            container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            title.topAnchor.constraint(equalTo: container.topAnchor),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 3),
            subtitle.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subtitle.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            

            contentView.bottomAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10)
        ].priority(.defaultHigh))
        
        backgroundColor = Asset.Colors.bottomSheetGroupped.color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate() {
        
    }
}
