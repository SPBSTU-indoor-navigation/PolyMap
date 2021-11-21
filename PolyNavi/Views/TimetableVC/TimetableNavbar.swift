//
//  TimetableNavbar.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 13.11.2021.
//

import UIKit

class TimetableNavbar: UIView  {
    
    let height: CGFloat = 100.0
    
    private lazy var stringDateFormatter: DateFormatter = {
        $0.dateFormat = "dd.MM"
        return $0
    }(DateFormatter())
    
    private lazy var dateFormatter: DateFormatter = {
        $0.dateFormat = "yyyy.MM.dd"
        return $0
    }(DateFormatter())
    
    public lazy var bottomLine: UIView = {
        $0.backgroundColor = .clear
        return $0
    }(UIView())
    
    public lazy var rightButton: UIButton = {
        $0.setTitle(L10n.Timetable.editButton, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 17)
        return $0
    }(UIButton(type: .system))
    
    public lazy var forwardPage: UIButton = {
        $0.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        return $0
    }(UIButton(type: .system))
    
    public lazy var reversePage: UIButton = {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        return $0
    }(UIButton(type: .system))
    
    public lazy var toCorrectPositionButton: UIButton = {
        $0.setTitle(L10n.Timetable.toCurrentWeek, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        return $0
    }(UIButton(type: .system))
    
    public lazy var leftButton: UIButton = {
        return $0
    }(UIButton(type: .close))
    
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
    
    private lazy var dateStackView: UIStackView = {
        $0.spacing = 2
        $0.alignment = .center
        $0.axis = .vertical
        return $0
    }(UIStackView())
    
    private lazy var text: UILabel = {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.font = .boldSystemFont(ofSize: 17)
        $0.text = L10n.Timetable.title
        return $0
    }(UILabel())
    
    private lazy var blurBackground: UIVisualEffectView = {
        return $0
    }(UIVisualEffectView(effect: nil))
    
    var blurAnimator = UIViewPropertyAnimator(duration: 3, curve: .linear)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(oddLabel)
        [blurBackground, bottomLine, text, rightButton, leftButton, reversePage, forwardPage, dateStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        blurAnimator.addAnimations {
            self.blurBackground.effect = UIBlurEffect(style: .systemMaterial)
            self.bottomLine.backgroundColor = .systemGray4.withAlphaComponent(0.4)
        }
        
        blurAnimator.pausesOnCompletion = true
        
        
        //TODO: разные констрейнты для разных экранов
        NSLayoutConstraint.activate([
            blurBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurBackground.topAnchor.constraint(equalTo: topAnchor),
            blurBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            
            text.centerXAnchor.constraint(equalTo: centerXAnchor),
            text.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            rightButton.centerYAnchor.constraint(equalTo: text.centerYAnchor),
            
            leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            leftButton.centerYAnchor.constraint(equalTo: text.centerYAnchor),
            
//            toCorrectPositionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
//            toCorrectPositionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -0.5),
            
            dateStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            reversePage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            reversePage.centerYAnchor.constraint(equalTo: dateStackView.centerYAnchor),
            
            forwardPage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            forwardPage.centerYAnchor.constraint(equalTo: dateStackView.centerYAnchor),
        ])
    }
    
    public func setDateLabel(with week: Timetable.Week) {
        let firstDay = dateFormatter.date(from: week.date_start)!
        let lastDay = dateFormatter.date(from: week.date_end)!
        dateLabel.text = "\(stringDateFormatter.string(from: firstDay)) - \(stringDateFormatter.string(from: lastDay))"
        oddLabel.text = "\(week.is_odd ? "Четная" : "Нечетная")"
        oddLabel.isHidden = false
    }
    
    public func setDateLabel(with date: Date) {
        let firstDay = TimetableProvider.shared.startOfWeek(date)
        let lastDay = Calendar.current.date(byAdding: .day, value: 7, to: firstDay)!
        dateLabel.text = "\(stringDateFormatter.string(from: firstDay)) - \(stringDateFormatter.string(from: lastDay))"
        oddLabel.isHidden = true
    }
}
