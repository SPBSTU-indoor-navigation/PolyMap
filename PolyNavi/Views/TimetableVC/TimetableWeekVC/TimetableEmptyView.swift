//
//  TimetableEmptyView.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 21.11.2021.
//

import UIKit


class TimetableEmptyView: UIView {
    
    private lazy var imageView: UIImageView = {
        $0.image = UIImage(systemName: "bed.double", withConfiguration: UIImage.SymbolConfiguration(pointSize: 100))
        return $0
    }(UIImageView())
    
    private lazy var descriptionLabel: UILabel = {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .callout)
        $0.text = L10n.Timetable.emptyWeek
        return $0
    }(UILabel())
    
    internal lazy var refreshButton: UIButton = {
        $0.setTitle("Refresh", for: .normal)
        return $0
    }(UIButton(type: .system))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        setViews()
    }
    
    func setViews() {
        backgroundColor = .clear
        [imageView, descriptionLabel, refreshButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            refreshButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            refreshButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 100),
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
}
