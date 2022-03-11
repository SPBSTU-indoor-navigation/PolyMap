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
    
    private lazy var routeButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        $0.setTitle(L10n.MapInfo.Route.route, for: .normal)
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        
        $0.setBackgroundColor(color: Asset.accentColor.color, forState: .normal)
        
        $0.tintColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.cornerCurve = .continuous
        
        $0.addTarget(self, action: #selector(routeClick(_:)), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private lazy var buildingButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(systemName: "square.split.bottomrightquarter.fill"), for: .normal)
        $0.setTitle(L10n.MapInfo.Route.plan, for: .normal)
    
        $0.layer.cornerRadius = 10
        $0.layer.cornerCurve = .continuous
        $0.clipsToBounds = true
        
        if #available(iOS 15.0, *) {
            $0.configuration = .gray()
            $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        } else {
            $0.setBackgroundColor(color: Asset.Colors.bottomSheetPlan.color, forState: .normal)
            $0.tintColor = Asset.accentColor.color
        }
        
        

        
        $0.addTarget(self, action: #selector(routeClick(_:)), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    var singleRouteConstraint, indoorRouteConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(routeButton)
        contentView.addSubview(buildingButton)
        backgroundColor = .clear
        selectionStyle = .none
        
        indoorRouteConstraint = routeButton.trailingAnchor.constraint(equalTo: buildingButton.leadingAnchor, constant: -8)
        singleRouteConstraint = routeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        NSLayoutConstraint.activate([
            routeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            routeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            routeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            buildingButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            buildingButton.widthAnchor.constraint(equalToConstant: 100),
            buildingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buildingButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            
            contentView.heightAnchor.constraint(equalToConstant: 46),
        ].priority(.defaultHigh))
        
    }
    
    func configutate(showRoute: Bool = true, showIndoor: Bool = true, buildingID: UUID? = nil) {
        routeButton.isHidden = !showRoute
        buildingButton.isHidden = !showIndoor
        
        singleRouteConstraint?.isActive = !showIndoor
        indoorRouteConstraint?.isActive = showIndoor
    }
    
    @objc func routeClick(_ sender: UIButton?) {
        print("CLICK")
        MapInfo.routeDetail?.setTo()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                buildingButton.setBackgroundColor(color: Asset.Colors.bottomSheetPlan.color, forState: .normal)
                routeButton.setBackgroundColor(color: Asset.accentColor.color, forState: .normal)
            }
        }
    }
}
