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
    var onRotate: (()->Void)?
    var currentConstraint: NSLayoutConstraint?
    
    var levelLabels: [UILabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var background: UIStackView = {
        let blur: UIVisualEffectView = {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8
            
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.isUserInteractionEnabled = false
            return $0
        }(UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)))
        
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
    
    lazy var rotateToBuilding: UIButton = {
        let blur: UIVisualEffectView = {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.isUserInteractionEnabled = false
            return $0
        }(UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)))
        
        $0.setImage(Asset.Images.rotateBuilding.image.withTintColor(.secondaryLabel), for: .normal)
        $0.insertSubview(blur, at: 0)
        $0.bringSubviewToFront($0.imageView!)
        $0.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        $0.imageView?.layer.minificationFilter = .trilinear
        
        $0.addTarget(self, action: #selector(onTapRotate(_:)), for: .touchUpInside)
        
        $0.addShadow()
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton())
    
    lazy var current: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 6.5
        $0.isUserInteractionEnabled = true
        
        $0.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(_:))))
        
        $0.backgroundColor = .systemGray3
        return $0
    }(UIView())
    
    func createLevelLabel(ordinal: Int) -> UILabel {
        return {
            $0.text = levels[ordinal]
            $0.font = .monospacedDigitSystemFont(ofSize: 17, weight: .medium)
            $0.textAlignment = .center
            $0.isUserInteractionEnabled = false
            $0.tag = ordinal
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .secondaryLabel
            return $0
        }(UILabel())
    }
    
    
    func layoutViews() {
        addSubview(background)
        background.addSubview(current)
        addSubview(rotateToBuilding)
        
        currentConstraint = current.centerYAnchor.constraint(equalTo: background.topAnchor, constant: 40)
        
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.widthAnchor.constraint(equalTo: widthAnchor),
            current.widthAnchor.constraint(equalTo: widthAnchor, constant: -5),
            current.heightAnchor.constraint(equalTo: widthAnchor, constant: -5),
            current.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            currentConstraint!,
            rotateToBuilding.topAnchor.constraint(equalTo: background.bottomAnchor, constant: 8),
            rotateToBuilding.widthAnchor.constraint(equalToConstant: 44),
            rotateToBuilding.heightAnchor.constraint(equalToConstant: 44),
            bottomAnchor.constraint(equalTo: rotateToBuilding.bottomAnchor),
            topAnchor.constraint(equalTo: background.topAnchor)
        ])
        
        changeLevels()
    }
    
    @objc private func onTapRotate(_ sender: UIButton) {
        onRotate?()
    }
    
    var moved = false
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        onLevelTap(Int(sender.location(in: background).y / 45))
    }
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
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
                        var targetPos = currentPos + 45 * dir
                        
                        if targetPos < 22.5 {
                            targetPos = 22.5
                        } else if targetPos > 45.0 * CGFloat(levelLabels.count) - 22.5 {
                            targetPos = 45.0 * CGFloat(levelLabels.count) - 22.5
                        }
                        
                        currentConstraint?.constant = targetPos
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
                onLevelTap(max(0, min(Int(sender.location(in: background).y / 45), levelLabels.count-1)))
            }
        default:
            break
        }
    }
    
    func changeLevels() {
        for b in levelLabels {
            b.removeFromSuperview()
        }
        
        levelLabels = []
        
        
        for key in Array(levels.keys).sorted(by:>) {
            let button = createLevelLabel(ordinal: key)
            levelLabels.append(button)
            background.addArrangedSubview(button)
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    func onLevelTap(_ button: Int) {
        currentConstraint?.constant = CGFloat(button) * 45.0 + 22.5
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
        onChange?(levelLabels[button].tag)
    }
    
}

extension LevelSwitcher {
    
    func updateLevels(levels: [Int:String], selected: Int = 0) {
        self.levels = levels
        changeLevels()
        currentConstraint?.constant = CGFloat(Array(levels.keys).sorted(by:>).firstIndex(of: selected)!) * 45.0 + 22.5
    }
}
