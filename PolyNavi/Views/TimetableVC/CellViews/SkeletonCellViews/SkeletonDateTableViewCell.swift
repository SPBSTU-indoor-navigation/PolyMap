//
//  SkeletonDateTableViewCell.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 10.10.2021.
//

import UIKit
import SkeletonView

class SkeletonDateTableViewCell: UITableViewCell {
    
    public static var identifire: String {
        return String(describing: self)
    }
    
    private lazy var mainBackView: UIView = {
        $0.backgroundColor = .secondarySystemGroupedBackground
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.layer.borderWidth = 0.5
        $0.layer.cornerRadius = 15
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var dateView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setView() {
        self.isSkeletonable = true;
        self.contentView.isSkeletonable = true
        self.mainBackView.isSkeletonable = true
        self.dateView.isSkeletonable = true
        self.dateView.skeletonCornerRadius = 5
        
        self.mainBackView.addSubview(dateView)
        self.contentView.addSubview(mainBackView)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            self.mainBackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            self.mainBackView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.mainBackView.widthAnchor.constraint(equalToConstant: 150),
            self.mainBackView.heightAnchor.constraint(equalToConstant: 20),
            
            self.dateView.centerXAnchor.constraint(equalTo: mainBackView.centerXAnchor),
            self.dateView.topAnchor.constraint(equalTo: mainBackView.topAnchor, constant: 5),
            self.dateView.widthAnchor.constraint(equalToConstant: 75),
            self.dateView.heightAnchor.constraint(equalToConstant: 5),
            self.contentView.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
        ])
    }
}
