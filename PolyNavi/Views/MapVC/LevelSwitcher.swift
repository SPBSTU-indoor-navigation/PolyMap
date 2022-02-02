//
//  LevelSwitcher.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 22.12.2021.
//
import UIKit

class LevelSwitcher: UIView {
    
    var levels: [Int:String] = [:]
    var onChange: ((Int)->Void)?
    var currentConstraint: NSLayoutConstraint?

    var levelButtons: [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var background: UIStackView = {
        $0.axis = .vertical
        $0.addSubview(blur)
        $0.spacing = 5
        $0.layoutMargins = UIEdgeInsets(top: 2.5, left: 0, bottom: 2.5, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.addShadow()
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
        return $0
    }(UIStackView())
    
    lazy var blur: UIVisualEffectView = {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
        
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.isUserInteractionEnabled = false
        return $0
    }(UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)))
    
    lazy var current: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 6.5
        $0.isUserInteractionEnabled = true

        $0.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(_:))))
        
        $0.backgroundColor = .systemGray3
        return $0
    }(UIView())
    
    func createLevelButton(ordinal: Int) -> UILabel {
        return {
            $0.text = levels[ordinal]
            $0.textAlignment = .center
            $0.isUserInteractionEnabled = false
//            $0.setTitle(levels[ordinal], for: .normal)
            $0.tag = ordinal
//            $0.setTitleColor(.label, for: .normal)
//            $0.setTitleColor(.secondaryLabel, for: .highlighted)
//
//            $0.addTarget(self, action: #selector(onLevelTap(_:)), for: .touchUpInside)
            $0.translatesAutoresizingMaskIntoConstraints = false
            return $0
        }(UILabel())
    }

    
    func layoutViews() {
        addSubview(background)
        background.addSubview(current)
        
        currentConstraint = current.centerYAnchor.constraint(equalTo: background.topAnchor, constant: 40)
        
        NSLayoutConstraint.activate([
            background.widthAnchor.constraint(equalTo: widthAnchor),
            heightAnchor.constraint(equalTo: background.heightAnchor),
            current.widthAnchor.constraint(equalTo: widthAnchor, constant: -5),
            current.heightAnchor.constraint(equalTo: widthAnchor, constant: -5),
            current.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            currentConstraint!
        ])
        
        changeLevels()
    }

    
    var moved = false
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        print(Int(sender.location(in: background).y / 45))
        onLevelTap_(Int(sender.location(in: background).y / 45))
    }
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {

        let position = sender.location(in: current)
        switch sender.state {
        case .began:
            print([position.y, current.frame.width])
            moved = true
            UIView.animate(withDuration: 0.15) {
                self.current.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        case .changed:
            if moved {
                let pos = sender.location(in: background)
                let currentPos = currentConstraint!.constant


                func move(dir: CGFloat) {
                    UIView.animate(withDuration: 0.15) { [self] in
                        currentConstraint?.constant = currentPos + 45 * dir
                        layoutIfNeeded()
                    }
                }

                if pos.y > currentPos + 25.0 {
                    move(dir: 1)
                } else if pos.y < currentPos - 25.0 {
                    move(dir: -1)
                }


            }
        case .ended:
            if moved {
                moved = false
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: { [self] in
                    current.transform = .identity
                })
                onLevelTap_(Int(sender.location(in: background).y / 45))
            }
        default:
            break
        }
    }
    
    func changeLevels() {
        for b in levelButtons {
            b.removeFromSuperview()
        }
        
        levelButtons = []
    
        
        for key in Array(levels.keys).sorted(by:>) {
            let button = createLevelButton(ordinal: key)
            levelButtons.append(button)
            background.addArrangedSubview(button)
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    func onLevelTap_(_ button: Int) {
        currentConstraint?.constant = CGFloat(button) * 45.0 + 22.5
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
        onChange?(levelButtons[button].tag)
    }
    
    @objc
    func onLevelTap(_ sender: UIButton) {
        currentConstraint?.constant = sender.layer.position.y
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
        onChange?(sender.tag)
    }
}

extension LevelSwitcher {
    
    func updateLevels(levels: [Int:String], selected: Int = 0) {
        
        self.levels = levels
        changeLevels()
        currentConstraint?.constant = CGFloat(Array(levels.keys).sorted(by:>).firstIndex(of: selected)!) * 45.0 + 22.5
//        UIView.animate(withDuration: 0.15) {
//            self.layoutIfNeeded()
//            self.background.layoutIfNeeded()
//        }
    }
}
