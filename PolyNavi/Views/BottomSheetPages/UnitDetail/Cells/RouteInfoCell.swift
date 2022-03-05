//
//  RouteInfoCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 02.03.2022.
//

import UIKit

class RouteInfoCell: UITableViewCell {
    
    public static var identifire: String {
        return String(describing: self)
    }
    
    var navbarHeightConstraint: NSLayoutConstraint?
    
    private lazy var routeButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        $0.setTitle("Route", for: .normal)
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        
        $0.setBackgroundColor(color: Asset.accentColor.color, forState: .normal)
        
        $0.tintColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.cornerCurve = .continuous
        
        $0.addTarget(self, action: #selector(routeClick(_:)), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(routeButton)
        backgroundColor = .clear
        selectionStyle = .none
        
        NSLayoutConstraint.activate([
            routeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            routeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            routeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            routeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 46),
        ].priority(.defaultHigh))
        
    }
    
    @objc func routeClick(_ sender: UIButton?) {
        print("CLICK")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(height: CGFloat) {
        backgroundColor = .clear
        contentView.autoresizingMask = .flexibleHeight
        if let navbarHeightConstraint = navbarHeightConstraint {
            navbarHeightConstraint.constant = height
        } else {
            navbarHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: height)
            navbarHeightConstraint!.priority = .defaultHigh
            navbarHeightConstraint!.isActive = true
        }
    }
}
