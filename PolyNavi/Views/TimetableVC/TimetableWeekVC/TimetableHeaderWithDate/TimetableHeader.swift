//
//  TimetableHeader.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 20.11.2021.
//

import UIKit

class TimetableHeader: UIView {
    
    private lazy var stringDateFormatter: DateFormatter = {
        $0.dateFormat = "dd.MM.yyyy"
        return $0
    }(DateFormatter())
    
    private lazy var dateFormatter: DateFormatter = {
        $0.dateFormat = "yyyy.MM.dd"
        return $0
    }(DateFormatter())
    
    private lazy var dateLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .callout)
        $0.lineBreakMode = .byWordWrapping
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    private lazy var oddLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.lineBreakMode = .byWordWrapping
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setViews() {
        addSubview(dateLabel)
        addSubview(oddLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            oddLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3),
            oddLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    public func setDateLabel(with week: Timetable.Week) {
        let firstDay = dateFormatter.date(from: week.date_start)!
        let lastDay = dateFormatter.date(from: week.date_end)!
        dateLabel.text = "\(stringDateFormatter.string(from: firstDay)) - \(stringDateFormatter.string(from: lastDay))"
        oddLabel.text = "\(week.is_odd ? "Четная" : "Нечетная")"
    }
    
    public func setDateLabel(with date: Date) {
        let firstDay = TimetableProvider.shared.startOfWeek(date)
        let lastDay = Calendar.current.date(byAdding: .day, value: 7, to: firstDay)!
        dateLabel.text = "\(stringDateFormatter.string(from: firstDay)) - \(stringDateFormatter.string(from: lastDay))"
    }
}
