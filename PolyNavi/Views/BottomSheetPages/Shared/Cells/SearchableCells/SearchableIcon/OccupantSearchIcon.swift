//
//  OccupantSearchIcon.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 31.03.2022.
//

import UIKit

class OccupantSearchIcon: UIView, SearchableConfigurate {
    private lazy var icon: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    lazy var iconContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        return $0
    }(UIView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainer.layer.cornerRadius = frame.width / 2
    }
    
    func setupViews() {
        addSubview(iconContainer)
        iconContainer.addSubview(icon)
        
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconContainer.topAnchor.constraint(equalTo: topAnchor),
            iconContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            icon.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6)
        ])
    }
    
    func configurate(searchable: Searchable) {
        icon.image = searchable.annotationSprite
        iconContainer.backgroundColor = searchable.backgroundSpriteColor
    }
}

