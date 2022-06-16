//
//  ToggleCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.04.2022.
//

import UIKit

class ToggleCell: BaseCellTitled {
    
    static var identifire = String(describing: ToggleCell.self)
    
    var action: ((Bool)->Void)? = nil
    
    lazy var switcher: UISwitch = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
    }(UISwitch())
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        container.addSubview(switcher)
        
        NSLayoutConstraint.activate([
            switcher.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            title.trailingAnchor.constraint(equalTo: switcher.leadingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(title: String, value: Bool, onToggle: ((Bool)->Void)? = nil) {
        self.title.text = title
        switcher.isOn = value
        action = onToggle
    }
    
    func toggleSwitch() {
        switcher.setOn(!switcher.isOn, animated: true)
        didToggleSwitch(switcher)
    }
    
    @objc private func didToggleSwitch(_ sender: UISwitch) {
        action?(sender.isOn)
    }
    
}
