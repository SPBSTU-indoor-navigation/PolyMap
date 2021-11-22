//
//  TimetableToolBar.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 20.11.2021.
//

import UIKit

class TimetableToolBar: UIView {
    let height: CGFloat = 65.0
    
    public lazy var topLine: UIView = {
        $0.backgroundColor = .clear
        return $0
    }(UIView())
    
    public lazy var toCorrectPositionButton: UIButton = {
        $0.setTitle(L10n.Timetable.toTodayTimetable, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        return $0
    }(UIButton(type: .system))
    
    public lazy var iCal: UIButton = {
        $0.setTitle("iCal", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18)
        return $0
    }(UIButton(type: .system))
    
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
        [blurBackground, topLine, toCorrectPositionButton, iCal].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        blurAnimator.addAnimations {
            self.blurBackground.effect = UIBlurEffect(style: .systemMaterial)
            self.topLine.backgroundColor = .systemGray4.withAlphaComponent(0.4)
        }
        
        blurAnimator.pausesOnCompletion = true
        
        blurAnimator.fractionComplete = 1
        
        //TODO: разные констрейнты для разных экранов
        NSLayoutConstraint.activate([
            blurBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurBackground.topAnchor.constraint(equalTo: topAnchor),
            blurBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            topLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            topLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            topLine.bottomAnchor.constraint(equalTo: topAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 1),
            
            toCorrectPositionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            toCorrectPositionButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            iCal.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            iCal.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
        ])
    }
}
