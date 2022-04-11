//
//  TimetableNavbar.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 13.11.2021.
//

import UIKit

class TimetableNavbar: UIView  {
    
    let height: CGFloat = 100.0
    var currentStartDay: Date? = nil
    
    private lazy var stringDateFormatter: DateFormatter = {
        $0.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMdd", options: 0, locale: Locale.current)!
        return $0
    }(DateFormatter())
    
    private lazy var  containerForNavBarElement: UIView = {
        $0.backgroundColor = .clear
        return $0
    }(UIView())
    
    private lazy var containerViewWithDate: UIView = {
        $0.backgroundColor = .clear
        return $0
    }(UIView())
    
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
        $0.accessibilityIdentifier = "settings"
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
    
    public lazy var leftButton: UIButton = {
        return $0
    }(UIButton(type: .close))
    
    private lazy var dateLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .callout)
        $0.lineBreakMode = .byWordWrapping
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.accessibilityIdentifier = "ttDay"
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
        [reversePage, dateStackView, forwardPage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.containerViewWithDate.addSubview($0)
        }
        
        [text, rightButton, leftButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.containerForNavBarElement.addSubview($0)
        }
        
        [blurBackground, bottomLine, containerForNavBarElement, containerViewWithDate].forEach {
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
            
            containerForNavBarElement.topAnchor.constraint(equalTo: topAnchor),
            containerForNavBarElement.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerForNavBarElement.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerForNavBarElement.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            
            text.centerXAnchor.constraint(equalTo: containerForNavBarElement.centerXAnchor),
            text.centerYAnchor.constraint(equalTo: containerForNavBarElement.centerYAnchor),
            
            rightButton.trailingAnchor.constraint(equalTo: containerForNavBarElement.trailingAnchor, constant: -20),
            rightButton.centerYAnchor.constraint(equalTo: text.centerYAnchor),
            
            leftButton.leadingAnchor.constraint(equalTo: containerForNavBarElement.leadingAnchor, constant: 18),
            leftButton.centerYAnchor.constraint(equalTo: text.centerYAnchor),
            
            containerViewWithDate.topAnchor.constraint(equalTo: leftButton.bottomAnchor, constant: 5),
            containerViewWithDate.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerViewWithDate.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerViewWithDate.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            dateStackView.centerXAnchor.constraint(equalTo: containerViewWithDate.centerXAnchor),
            dateStackView.centerYAnchor.constraint(equalTo: containerViewWithDate.centerYAnchor),
            
            reversePage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            reversePage.centerYAnchor.constraint(equalTo: containerViewWithDate.centerYAnchor),
            
            forwardPage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            forwardPage.centerYAnchor.constraint(equalTo: containerViewWithDate.centerYAnchor),
        ])
    }
    
    public func setDateLabel(with date: Date, isOdd: Bool? = nil) {
        currentStartDay = TimetableProvider.shared.startOfWeek(date)
        let lastDay = Calendar.current.date(byAdding: .day, value: 6, to: currentStartDay!)!
        dateLabel.text = "\(stringDateFormatter.string(from: currentStartDay!)) - \(stringDateFormatter.string(from: lastDay))"
        
        guard let odd = isOdd else { return oddLabel.text = "" }
        oddLabel.text =  "\(odd ? L10n.Timetable.dataOddWeek : L10n.Timetable.dateEvenWeek)"
    }
}
