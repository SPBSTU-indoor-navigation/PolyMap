//
//  DetailCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 05.03.2022.
//

import UIKit

class DetailCell: UITableViewCell {
    static var identifire = String(describing: DetailCell.self)
    
    private lazy var title: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .systemGray
        return $0
    }(UILabel())
    
    private lazy var content: UITextView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .body)
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.dataDetectorTypes = .all
        $0.backgroundColor = .clear
        $0.tintColor = Asset.accentColor.color
        $0.clipsToBounds = false
        $0.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        return $0
    }(UITextView())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setViews() {
        contentView.addSubview(title)
        contentView.addSubview(content)
        backgroundColor = Asset.Colors.bottomSheetGroupped.color
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            content.topAnchor.constraint(equalTo: title.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contentView.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 8),
        ])
    }
    
    func configurate(title: String, content: String) {
        self.title.text = title
        self.content.text = content
        
        self.content.sizeToFit()
    }

}
