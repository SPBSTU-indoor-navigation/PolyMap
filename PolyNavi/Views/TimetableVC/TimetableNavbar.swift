//
//  TimetableNavbar.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 13.11.2021.
//

import UIKit

class TimetableNavbar: UIView  {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var bottomLine: UIView = {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    public lazy var rightButton: UIButton = {
        $0.setTitle(L10n.Timetable.editButton, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 17)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .system))
    
    public lazy var leftButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .close))
    
    private lazy var text: UILabel = {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.font = .boldSystemFont(ofSize: 17)
        $0.text = L10n.Timetable.title
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    private lazy var blurBackground: UIVisualEffectView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIVisualEffectView(effect: nil))
    
    var blurAnimator = UIViewPropertyAnimator(duration: 3, curve: .linear)
    
    func setViews() {
        addSubview(blurBackground)
        addSubview(bottomLine)
        addSubview(text)
        addSubview(rightButton)
        addSubview(leftButton)
        backgroundColor = .blue
        
        blurAnimator.addAnimations {
//            self.blurBackground.effect = UIBlurEffect(style: .systemMaterial)
            self.backgroundColor = .red
            self.bottomLine.backgroundColor = .systemGray4.withAlphaComponent(0.4)
        }
        
        
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
            text.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            rightButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            leftButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
