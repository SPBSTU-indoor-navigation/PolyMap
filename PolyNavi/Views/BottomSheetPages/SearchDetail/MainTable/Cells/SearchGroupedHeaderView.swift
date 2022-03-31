//
//  SearchGroupedHeaderView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 27.03.2022.
//

import UIKit

class SearchGroupedHeaderView: UITableViewHeaderFooterView {
    static var identifier: String = String(describing: SearchGroupedHeaderView.self)

    lazy var title: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            contentView.bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
        ].priority(.defaultHigh))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(text: String) {
        title.text = text
    }
}
