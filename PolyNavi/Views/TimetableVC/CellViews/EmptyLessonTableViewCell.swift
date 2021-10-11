//
//  EmptyLessonTableViewCell.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 09.10.2021.
//

import UIKit


class EmptyLessonTableViewCell: UITableViewCell {
    
    public static var identifire: String {
        return String(describing: self)
    }
    
    private lazy var emptyLabel: UILabel = {
        $0.text = "Окно"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        return $0
    }(UILabel())
    
    private lazy var mainView: UIView = {
        $0.backgroundColor = .secondarySystemGroupedBackground
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.separator.cgColor
        return $0
    }(UIView())
    
    private lazy var timeLabel: UILabel = {
        $0.font = .systemFont(ofSize: 15, weight: .medium)
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
        [mainView, timeLabel, emptyLabel].forEach {$0.translatesAutoresizingMaskIntoConstraints = false}
        mainView.addSubview(emptyLabel)
        mainView.addSubview(timeLabel)
        contentView.addSubview(mainView)
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            emptyLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10),
            emptyLabel.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 5),
            timeLabel.centerXAnchor.constraint(equalTo: emptyLabel.centerXAnchor),
            
            mainView.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            contentView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
        ])
    }
    
    public func configure(time: String) {
        timeLabel.text = time
    }
}
