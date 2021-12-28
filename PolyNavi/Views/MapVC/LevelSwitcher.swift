//
//  LevelSwitcher.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 22.12.2021.
//
import UIKit

class LevelSwitcher: UIView {
    
    var levels: [String] = ["1", "2", "3"]
    var onChange: ((Int)->Void)?

    var levelButtons: [UIButton] = []
    
    
    //    init(levels: [String], onChange: @escaping (Int)->Void) {
    //        self.levels = levels
    //        self.onChange = onChange
    //    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var background: UIStackView = {
        $0.axis = .vertical
        $0.backgroundColor = .systemBlue
        $0.spacing = 5
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIStackView())
    

    func createLevelButton(index: Int) -> UIButton {
        return {
            $0.setTitle(levels[index], for: .normal)
            $0.tag = index
            $0.backgroundColor = .red.withAlphaComponent(0.5)
            
            $0.addTarget(self, action: #selector(onLevelTap(_:)), for: .touchUpInside)
            $0.translatesAutoresizingMaskIntoConstraints = false
            
            $0.becomeFirstResponder()
            return $0
        }(UIButton())
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
        changeLevels()
    }
    
    func layoutViews() {
        addSubview(background)
        
        NSLayoutConstraint.activate([
            background.widthAnchor.constraint(equalTo: widthAnchor),
            widthAnchor.constraint(equalToConstant: 40),
            heightAnchor.constraint(equalTo: background.heightAnchor)
        ])
        
    }
    
    func changeLevels() {
        for b in levelButtons {
            b.removeFromSuperview()
        }
        
        levelButtons = []
        
        for i in 0..<levels.count {
            let button = createLevelButton(index: i)
            levelButtons.append(button)
            background.addArrangedSubview(button)
            
            NSLayoutConstraint.activate([
//                button.widthAnchor.constraint(equalTo: background.widthAnchor),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    @objc
    func onLevelTap(_ sender: UIButton) {
        onChange?(sender.tag)
    }
}
