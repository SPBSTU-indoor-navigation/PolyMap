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
    
    private lazy var labelsStackView: UIStackView = {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isSkeletonable = true
        $0.skeletonCornerRadius = 10
        return $0
    }(UIStackView())
    
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
        $0.isSkeletonable = true
        return $0
    }(UIView())
    
    private lazy var timeLabel: UILabel = {
        $0.text = "Text txt txt"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.isSkeletonable = true
        return $0
    }(UILabel())
    
    private lazy var subjectNameLabel: UILabel = {
        $0.text = "Text txt txt"
        return $0
    }(UILabel())
    
    private lazy var teacherNameLabel: UILabel = {
        $0.text = "Text txt txt"
        return $0
    }(UILabel())
    
    private lazy var placeLabel: UILabel = {
        $0.text = "Text txt txt"
        return $0
    }(UILabel())
    
    private lazy var typeOfLessonLabel: UILabel = {
        $0.text = "Text txt txt"
        return $0
    }(UILabel())
    
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
        [subjectNameLabel, typeOfLessonLabel, teacherNameLabel, placeLabel].forEach {
            $0.isSkeletonable = true
            $0.skeletonCornerRadius = 10
            labelsStackView.addArrangedSubview($0)
        }
        mainBackView.addSubview(timeLabel)
        mainBackView.addSubview(labelsStackView)
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
            
            labelsStackView.topAnchor.constraint(equalTo: mainBackView.topAnchor, constant: 10),
            labelsStackView.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 5),
            labelsStackView.trailingAnchor.constraint(equalTo: mainBackView.trailingAnchor, constant: -10),
            
            mainBackView.bottomAnchor.constraint(equalTo: labelsStackView.bottomAnchor, constant: 5),
            self.contentView.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
        ])
    }
}
