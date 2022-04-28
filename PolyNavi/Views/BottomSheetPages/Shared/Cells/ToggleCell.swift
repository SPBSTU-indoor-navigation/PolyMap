//
//  ToggleCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 17.04.2022.
//

import UIKit

class ToggleCell: UITableViewCell {
    
    static var identifire = String(describing: ToggleCell.self)
    
    var action: ((Bool)->Void)? = nil
    
    lazy var switcher: UISwitch = {
        $0.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)
        return $0
    }(UISwitch())
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Asset.Colors.bottomSheetGroupped.color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(title: String, onToggle: ((Bool)->Void)? = nil) {
        
        if #available(iOS 14.0, *) {
            var content = defaultContentConfiguration()
            content.text = title
            
            contentConfiguration = content
        } else {
            textLabel?.text = title
        }
        
        accessoryView = switcher
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
