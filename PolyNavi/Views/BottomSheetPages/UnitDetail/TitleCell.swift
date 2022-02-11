//
//  LabelCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 10.02.2022.
//

import UIKit

class TitleCell: UITableViewCell {
    private lazy var timeLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Saint Petersburg State University of Industrial Technologies and Design"
        $0.font = .systemFont(ofSize: 29, weight: .bold)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        return $0
    }(UILabel())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        contentView.addSubview(timeLabel)
        
        backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -45),
            contentView.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor),
        ])
        
    }

}
