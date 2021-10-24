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
        $0.text = L10n.Timetable.lessonsBreak
        $0.font = .preferredFont(forTextStyle: .headline)
        return $0
    }(UILabel())
    
    private lazy var mainView: UIView = {
        return $0
    }(UIView())
    
    private lazy var timeLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .body)
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
        [mainView, timeLabel, emptyLabel].forEach {$0.translatesAutoresizingMaskIntoConstraints = false}
        mainView.addSubview(emptyLabel)
        mainView.addSubview(timeLabel)
        contentView.addSubview(mainView)
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
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
