//
//  DateTableViewCell.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 08.10.2021.
//

import UIKit


class DateTableViewCell: UITableViewHeaderFooterView {
    
    public static var identifire: String {
        return String(describing: DateTableViewCell.self)
    }
    
    private lazy var formmater: DateFormatter = {
        $0.dateFormat = "EE dd MMM"
        return $0
    }(DateFormatter())
    
    private lazy var mainBackView: UIView = {
        $0.backgroundColor = .secondarySystemGroupedBackground
        $0.layer.cornerRadius = 15
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var dateLabel: UILabel = {
        $0.text = "-"
        $0.font = .preferredFont(forTextStyle: .body)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    private lazy var circle: UIView = {
        $0.backgroundColor = Asset.accentColor.color
        $0.layer.cornerRadius = 5
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var emptyDataView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 3
        $0.backgroundColor = UIColor.separator
        $0.isHidden = true
        return $0
    }(UIView())
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setView() {
        mainBackView.addSubview(emptyDataView)
        mainBackView.addSubview(dateLabel)
        mainBackView.addSubview(circle)

        addSubview(mainBackView)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalTo: mainBackView.heightAnchor, constant: 10),
            mainBackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            mainBackView.widthAnchor.constraint(greaterThanOrEqualTo: dateLabel.widthAnchor, constant: 50),
            mainBackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            mainBackView.heightAnchor.constraint(equalTo: dateLabel.heightAnchor, constant: 5),
            
            circle.centerYAnchor.constraint(equalTo: mainBackView.centerYAnchor),
            circle.centerXAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -10),
            circle.widthAnchor.constraint(equalToConstant: 10),
            circle.heightAnchor.constraint(equalToConstant: 10),
            
            dateLabel.centerXAnchor.constraint(equalTo: mainBackView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: mainBackView.centerYAnchor),
            emptyDataView.centerYAnchor.constraint(equalTo: mainBackView.centerYAnchor),
            emptyDataView.centerXAnchor.constraint(equalTo: mainBackView.centerXAnchor),
            emptyDataView.heightAnchor.constraint(equalToConstant: 2),
            emptyDataView.widthAnchor.constraint(equalToConstant: 75),
            bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
        ])
    }
    
    public func configure(withDate date: Date?) {
        if let wrapDate = date {
            dateLabel.text = formmater.string(from: wrapDate)
            emptyDataView.isHidden = true
            circle.isHidden = !Calendar.current.isDate(Date(), inSameDayAs: date!)
        } else {
            dateLabel.isHidden = true
            emptyDataView.isHidden = false
        }
    }
}
