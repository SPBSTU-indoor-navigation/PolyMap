//
//  DateTableViewCell.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 08.10.2021.
//

import UIKit


class DateTableViewCell: UITableViewCell {
    
    public static var identifire: String {
        return String(describing: self)
    }
    
    private lazy var mainBackView: UIView = {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
        $0.layer.borderWidth = 0.5
        $0.layer.cornerRadius = 15
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var dateLabel: UILabel = {
        $0.text = "07 окт. 2021"
        $0.font = .systemFont(ofSize: 12, weight: .bold)
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
        self.mainBackView.addSubview(dateLabel)
        self.contentView.addSubview(mainBackView)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            self.mainBackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            self.mainBackView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.mainBackView.widthAnchor.constraint(equalToConstant: 130),
            self.mainBackView.heightAnchor.constraint(equalToConstant: 20),
            
            self.dateLabel.centerXAnchor.constraint(equalTo: mainBackView.centerXAnchor),
            self.dateLabel.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
        ])
    }
}
