//
//  FavoriteCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 07.05.2022.
//

import UIKit

class FavoriteCell: UITableViewCell {
    static var identifire = String(describing: FavoriteCell.self)
    
    func configurate(isFavorite: Bool = false, animated: Bool = false) {
        let image = UIImage(systemName: isFavorite ? "star.slash.fill" : "star.fill")
        let text = isFavorite ? L10n.MapInfo.Report.Favorites.remove : L10n.MapInfo.Report.Favorites.add
        
        if #available(iOS 14.0, *) {
            var content = defaultContentConfiguration()
            content.text = text
            content.image = image
            contentConfiguration = content
        } else {
            textLabel?.text = text
            imageView?.image = image
        }
        
        backgroundColor = Asset.Colors.bottomSheetGroupped.color
    }
}
