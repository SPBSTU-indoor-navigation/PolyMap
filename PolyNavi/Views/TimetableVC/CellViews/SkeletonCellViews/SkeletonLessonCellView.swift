//
//  SkeletonLessonCellView.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 10.10.2021.
//

import UIKit
import SkeletonView


class SkeletonLessonCellView: UITableViewCell {
    public static var identifire: String {
        return String(describing: self)
    }

    private lazy var mainBackView: UIView = {
        $0.backgroundColor = .secondarySystemGroupedBackground
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 15
        $0.isSkeletonable = true
        return $0
    }(UIView())
    
    private lazy var divider: UIView = {
        $0.backgroundColor = .systemGray3
        $0.layer.cornerRadius = 2
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var timeLabel: UILabel = {
        $0.text = "Text txt txt"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.isSkeletonable = true
        $0.skeletonCornerRadius = 5
        return $0
    }(UILabel())
    
    private lazy var textView: UITextView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.linesCornerRadius = 5
        $0.skeletonLineSpacing = 6
        $0.isSkeletonable = true
        return $0
    }(UITextView())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setViews() {
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.isSkeletonable = true
        self.contentView.isSkeletonable = true
    
        mainBackView.addSubview(timeLabel)
        mainBackView.addSubview(textView)
        mainBackView.addSubview(divider)
        
        self.contentView.addSubview(mainBackView)
        
        NSLayoutConstraint.activate([
            mainBackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            mainBackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            mainBackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            
            timeLabel.centerYAnchor.constraint(equalTo: mainBackView.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: mainBackView.leadingAnchor, constant: 10),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            
            divider.topAnchor.constraint(equalTo: mainBackView.topAnchor, constant: 2),
            divider.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor, constant: -2),
            divider.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 10),
            divider.widthAnchor.constraint(equalToConstant: 2),
            
            textView.topAnchor.constraint(equalTo: mainBackView.topAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 5),
            textView.trailingAnchor.constraint(equalTo: mainBackView.trailingAnchor, constant: -5),
            textView.heightAnchor.constraint(equalToConstant: 100),
            
            mainBackView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 5),
            self.contentView.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
        ])
    }
}
