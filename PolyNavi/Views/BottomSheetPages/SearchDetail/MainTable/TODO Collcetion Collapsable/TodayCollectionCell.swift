//
//  TodayCollectionCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 28.03.2022.
//

import UIKit

class TodayCollectionCell: UICollectionViewCell, FlowLayoutCell {
    static var identifier: String = String(describing: TodayCollectionCell.self)
    
    lazy var circle: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 30
        return $0
    }(UIView())
    
    lazy var mainLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textAlignment = .left
        $0.text = "125"
        return $0
    }(UILabel())
    
    private lazy var subTitleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var listConstraints = [
        circle.widthAnchor.constraint(equalToConstant: 60),
        circle.heightAnchor.constraint(equalToConstant: 60),
        circle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
        circle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        
        mainLabel.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 10),
        mainLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
        mainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
    ]
    
    lazy var stripConstraints = [
        circle.widthAnchor.constraint(equalToConstant: 60),
        circle.heightAnchor.constraint(equalToConstant: 60),
        circle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        circle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
        
        mainLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
        mainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        mainLabel.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 10),
    ]
    
    func setViews() {
        
        contentView.addSubview(circle)
        contentView.addSubview(mainLabel)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemBlue.cgColor
        
        
        NSLayoutConstraint.activate(stripConstraints)

        
    }
    
    func layoutBeginChange(layoutType: LayoutType) {
        changeLayout(layoutType: layoutType)
    }
    
    func changeLayout(layoutType: LayoutType, animated: Bool = true) {
        layer.borderColor = layoutType == .list ? UIColor.systemGreen.cgColor : UIColor.systemBlue.cgColor
        
        Animator().animate(withDuration: 0.3, animations: { [self] in
            if layoutType == .list {
                NSLayoutConstraint.deactivate(stripConstraints)
                NSLayoutConstraint.activate(listConstraints)
                mainLabel.textAlignment = .left
            } else {
                NSLayoutConstraint.deactivate(listConstraints)
                NSLayoutConstraint.activate(stripConstraints)
                mainLabel.textAlignment = .center
            }
            layoutIfNeeded()
        }).play(animated: animated)
    }
    
}
