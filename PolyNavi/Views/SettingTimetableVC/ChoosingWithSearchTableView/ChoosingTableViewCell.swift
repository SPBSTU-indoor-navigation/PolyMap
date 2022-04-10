//
//  ChoosingTableViewCell.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 19.10.2021.
//

import UIKit
import M13Checkbox


class ChoosingTableViewCell: UITableViewCell {
    
    public static var identifire: String {
        return String(describing: self)
    }
    
    private lazy var titleLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        return $0
    }(UILabel())
    
    private lazy var checkBox: M13Checkbox = {
        $0.checkmarkLineWidth = 2
        $0.boxLineWidth = 0
        $0.tintColor = Asset.accentColor.color
        $0.isEnabled = false
        return $0
    }(M13Checkbox())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

//MARK:-Setviews and configure
extension ChoosingTableViewCell {
    
    private func setViews() {
        [titleLabel, checkBox].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
        }
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: checkBox.leadingAnchor, constant: -10),
            
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            checkBox.heightAnchor.constraint(equalToConstant: 35),
            checkBox.widthAnchor.constraint(equalToConstant: 35),
            
            contentView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12)
        ])
    }
    
    public func configure(title: String, status: Bool) {
        checkBox.setCheckState((status) ? .checked : .unchecked, animated: false)
        titleLabel.text = title
        accessibilityIdentifier = title
    }
    
    public func toogleCheckbox() {
        checkBox.setCheckState((checkBox.checkState == .checked) ? .unchecked : .checked, animated: true)
    }
}
