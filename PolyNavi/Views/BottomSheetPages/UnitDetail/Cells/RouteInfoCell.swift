//
//  RouteInfoCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 02.03.2022.
//

import UIKit

class RouteInfoCell: UITableViewCell {
    
    enum RouteVariant {
        case from;
        case to;
        case fromTo;
    }
    
    enum ClickVariant {
        case from;
        case to;
    }
    
    static var identifire = String(describing: RouteInfoCell.self)
    
    var onRouteClick: ((ClickVariant) -> Void)?
    var onBuildingClick: (() -> Void)?
    var currentVariant: RouteVariant = .to
    
    private lazy var routeButton: UIButton = {
        $0.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        $0.setTitle(L10n.MapInfo.Route.route, for: .normal)
        $0.addTarget(self, action: #selector(routeSingleClick(_:)), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private lazy var fromRouteButton: UIButton = {
        $0.setImage(Asset.Images.from.image, for: .normal)
        $0.setTitle(L10n.MapInfo.Route.from, for: .normal)
        
        $0.addTarget(self, action: #selector(routeFromClick(_:)), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private lazy var toRouteButton: UIButton = {
        $0.setImage(Asset.Images.to.image, for: .normal)
        $0.setTitle(L10n.MapInfo.Route.to, for: .normal)
        
        $0.addTarget(self, action: #selector(routeToClick(_:)), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private lazy var routeContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
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
        $0.addTarget(self, action: #selector(buildingClick(_:)), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    var singleRouteConstraint, indoorRouteConstraint: NSLayoutConstraint?
    
    var routeConstraint: [NSLayoutConstraint] = []
    var routeFromToConstraint: [NSLayoutConstraint] = []

    var singleLine: [NSLayoutConstraint] = []
    var multyLine: [NSLayoutConstraint] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [routeButton, toRouteButton, fromRouteButton].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            $0.setBackgroundColor(color: Asset.accentColor.color, forState: .normal)
            
            $0.tintColor = .white
            $0.layer.cornerRadius = 10
            $0.layer.cornerCurve = .continuous
        })
        
        contentView.addSubview(routeContainer)
        contentView.addSubview(buildingButton)
        
        routeContainer.addSubview(routeButton)
        routeContainer.addSubview(fromRouteButton)
        routeContainer.addSubview(toRouteButton)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        indoorRouteConstraint = routeContainer.trailingAnchor.constraint(equalTo: buildingButton.leadingAnchor, constant: -8)
        singleRouteConstraint = routeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        NSLayoutConstraint.activate([
            routeContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            routeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            routeContainer.heightAnchor.constraint(equalToConstant: 46),
            
            routeButton.heightAnchor.constraint(equalTo: routeContainer.heightAnchor),
            fromRouteButton.heightAnchor.constraint(equalTo: routeContainer.heightAnchor),
            toRouteButton.heightAnchor.constraint(equalTo: routeContainer.heightAnchor),
            buildingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buildingButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
        ].priority(.defaultHigh))
        
        singleLine = [
            contentView.heightAnchor.constraint(equalToConstant: 46).withPriority(.defaultHigh),
            buildingButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            buildingButton.widthAnchor.constraint(equalToConstant: 100).withPriority(.defaultLow)
        ]
        
        multyLine = [
            contentView.heightAnchor.constraint(equalToConstant: 46 * 2 + 8).withPriority(.defaultHigh),
            routeContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buildingButton.heightAnchor.constraint(equalToConstant: 46),
            buildingButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ]
        
        routeConstraint = [
            routeButton.leadingAnchor.constraint(equalTo: routeContainer.leadingAnchor),
            routeButton.trailingAnchor.constraint(equalTo: routeContainer.trailingAnchor),
        ]
        
        routeFromToConstraint = [
            fromRouteButton.leadingAnchor.constraint(equalTo: routeContainer.leadingAnchor),
            toRouteButton.leadingAnchor.constraint(equalTo: fromRouteButton.trailingAnchor, constant: 8),
            toRouteButton.trailingAnchor.constraint(equalTo: routeContainer.trailingAnchor),
            fromRouteButton.widthAnchor.constraint(equalTo: toRouteButton.widthAnchor),
        ]
        
        routeConstraint.activate()
        routeFromToConstraint.activate()
    }
    
    func configutate(routeVariant: RouteVariant = .to, showIndoor: Bool = true) {
        routeButton.isHidden = !(routeVariant == .from || routeVariant == .to)
        currentVariant = routeVariant
        
        [fromRouteButton, toRouteButton].forEach({ $0.isHidden = !(routeVariant == .fromTo) })
        
        if (routeVariant == .fromTo && showIndoor) {
            singleLine.deactivate()
            multyLine.activate()
            singleRouteConstraint?.isActive = true
            indoorRouteConstraint?.isActive = false
        } else {
            multyLine.deactivate()
            singleLine.activate()
            singleRouteConstraint?.isActive = !showIndoor
            indoorRouteConstraint?.isActive = showIndoor
        }
        
        if routeVariant != .fromTo {
            routeButton.setTitle(routeVariant == .from ? L10n.MapInfo.Route.from : L10n.MapInfo.Route.route, for: .normal)
            routeButton.setImage(routeVariant == .from ? Asset.Images.from.image : UIImage(systemName: "figure.walk"), for: .normal)
        }
        
        buildingButton.isHidden = !showIndoor
    }
    
    @objc func routeSingleClick(_ sender: UIButton?) {
        onRouteClick?(currentVariant == .to ? .to : .from)
    }
    
    @objc func routeToClick(_ sender: UIButton?) {
        onRouteClick?(.to)
    }
    
    @objc func routeFromClick(_ sender: UIButton?) {
        onRouteClick?(.from)
    }
    
    @objc func buildingClick(_ sender: UIButton?) {
        onBuildingClick?()
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
