//
//  SearchHeaderView.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 26.03.2022.
//

import UIKit

class SearchHeaderView: UITableViewHeaderFooterView {
    static var identifier: String = String(describing: SearchHeaderView.self)
    
    lazy var title: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.textColor = .secondaryLabel
        $0.text = "Buildings"
        return $0
    }(UILabel())
    
    private lazy var separator: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .separator
        return $0
    }(UIView())
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(title)
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            contentView.bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ].priority(.defaultHigh))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(text: String) {
        title.text = text
    }
}
