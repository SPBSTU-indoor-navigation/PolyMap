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
    
    private lazy var formmater: DateFormatter = {
        $0.dateFormat = "dd MMM YYYY"
        return $0
    }(DateFormatter())
    
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
        $0.text = "07 окт. 2021"
        $0.font = .preferredFont(forTextStyle: .body)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    private lazy var emptyDataView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 3
        $0.backgroundColor = UIColor.separator
        $0.isHidden = true
        return $0
    }(UIView())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setView() {
        self.mainBackView.addSubview(emptyDataView)
        self.mainBackView.addSubview(dateLabel)
        self.contentView.addSubview(mainBackView)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            self.mainBackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            self.mainBackView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.mainBackView.widthAnchor.constraint(greaterThanOrEqualTo: dateLabel.widthAnchor, constant: 50),
            self.mainBackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            self.mainBackView.heightAnchor.constraint(equalTo: dateLabel.heightAnchor, constant: 5),
            
            self.dateLabel.centerXAnchor.constraint(equalTo: mainBackView.centerXAnchor),
            self.dateLabel.centerYAnchor.constraint(equalTo: mainBackView.centerYAnchor),
            self.emptyDataView.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor, constant: -5),
            self.emptyDataView.centerXAnchor.constraint(equalTo: mainBackView.centerXAnchor),
            self.emptyDataView.heightAnchor.constraint(equalToConstant: 2),
            self.emptyDataView.widthAnchor.constraint(equalToConstant: 75),
            self.contentView.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
        ])
    }
    
    public func configure(withDate date: Date?) {
        if let wrapDate = date {
            self.dateLabel.text = self.formmater.string(from: wrapDate)
            self.emptyDataView.isHidden = true
        } else {
            self.dateLabel.isHidden = true
            self.emptyDataView.isHidden = false
        }
    }
}
