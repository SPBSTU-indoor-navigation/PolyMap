//
//  SimpleShareCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.04.2022.
//

import UIKit

class SimpleShareCell: UITableViewCell {
    static var identifire = String(describing: SimpleShareCell.self)
    
    func configurate() {
        let image = UIImage(systemName: "square.and.arrow.up")
        let text = L10n.MapInfo.share
        
        if #available(iOS 14.0, *) {
            var content = defaultContentConfiguration()
            content.text = text
            contentConfiguration = content
        } else {
            textLabel?.text = text
        }
        
        let img = UIImageView(image: image)
        img.contentMode = .scaleAspectFit
        
        accessoryView = img
        accessoryView?.frame = .init(x: 0, y: 0, width: 24, height: 28)
        backgroundColor = Asset.Colors.bottomSheetGroupped.color
    }
}
