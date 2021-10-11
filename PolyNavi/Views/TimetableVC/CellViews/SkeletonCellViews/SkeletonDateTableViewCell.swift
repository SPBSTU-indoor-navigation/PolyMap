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
    
    private lazy var dateLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.isSkeletonable = true
        $0.skeletonCornerRadius = 3
        $0.text = "Text txt"
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
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        self.isSkeletonable = true;
        self.contentView.isSkeletonable = true
        self.mainBackView.isSkeletonable = true
        
        self.mainBackView.addSubview(dateLabel)
        self.contentView.addSubview(mainBackView)
        
        NSLayoutConstraint.activate([
            self.mainBackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            self.mainBackView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.mainBackView.widthAnchor.constraint(equalToConstant: 150),
            self.mainBackView.heightAnchor.constraint(equalToConstant: 20),
            
            self.dateLabel.centerXAnchor.constraint(equalTo: self.mainBackView.centerXAnchor),
            self.dateLabel.bottomAnchor.constraint(equalTo: self.mainBackView.bottomAnchor, constant: -2),
            self.dateLabel.heightAnchor.constraint(equalToConstant: 8),
            
            self.contentView.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
        ])
    }
}
