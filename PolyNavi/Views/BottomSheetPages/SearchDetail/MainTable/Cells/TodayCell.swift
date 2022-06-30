//
//  TodayCell.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 30.03.2022.
//

import UIKit

class TodayCellModel {
    var searchable: Searchable
    var title: String
    var timeStart: Date
    var timeEnd: Date
    
    init(searchable: Searchable, title: String, timeStart: Date, timeEnd: Date) {
        self.searchable = searchable
        self.title = title
        self.timeStart = timeStart
        self.timeEnd = timeEnd
    }
    
    func timeInterval() -> String {
        let timeFormatter: DateFormatter = {
            $0.timeStyle = .short
            return $0
        }(DateFormatter())
        
        return "\(timeFormatter.string(from: timeStart)) – \(timeFormatter.string(from: timeEnd))"
    }
    
}

class TodayCellAttraction: TodayCellIcon {
    static var identifier: String = String(describing: TodayCellAttraction.self)
    
    lazy var attractionIcon: AttractionSearchIcon = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.border = 2
        return $0
    }(AttractionSearchIcon())
    
    override var icon: (UIView & SearchableConfigurate)? { attractionIcon }
}

class TodayCellOccupant: TodayCellIcon {
    static var identifier: String = String(describing: TodayCellOccupant.self)
    
    lazy var occupantIcon: OccupantSearchIcon = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(OccupantSearchIcon())
    
    override var icon: (UIView & SearchableConfigurate)? { occupantIcon }
}


class TodayCellIcon: TodayCell {
    var icon: (UIView & SearchableConfigurate)? { get {
        return {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(OccupantSearchIcon()) } }
    
    override func setupViews() {
        
        guard let icon = icon else {
            super.setupViews()
            return
        }

        contentView.addSubview(icon)
        super.setupViews()
        
        let sizeDelta = 0.3
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: progress.topAnchor, constant: sizeDelta),
            icon.leadingAnchor.constraint(equalTo: progress.leadingAnchor, constant: sizeDelta),
            icon.trailingAnchor.constraint(equalTo: progress.trailingAnchor, constant: -sizeDelta),
            icon.bottomAnchor.constraint(equalTo: progress.bottomAnchor, constant: -sizeDelta),
        ])
    }
    
    override func configurate(_ model: TodayCellModel) {
        super.configurate(model)
        icon?.configurate(searchable: model.searchable)
    }
}

class TodayCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .body)
        return $0
    }(UILabel())
    
    private lazy var subTitleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    private lazy var subSubTitleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    lazy var progress: CircularProgressBar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.progress = 0.4
        $0.color = Asset.accentColor.color
        return $0
    }(CircularProgressBar())

    private var currentModel: TodayCellModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            self.setTimeCursor()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    func setupViews() {
        backgroundColor = Asset.Colors.bottomSheetGroupped.color
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(subSubTitleLabel)
        
        contentView.addSubview(progress)
        
        NSLayoutConstraint.activate([
            progress.widthAnchor.constraint(equalToConstant: 50),
            progress.heightAnchor.constraint(equalToConstant: 50),
            progress.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            progress.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
  
            titleLabel.leadingAnchor.constraint(equalTo: progress.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            
            subSubTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subSubTitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subSubTitleLabel.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 2),
            
            
            contentView.bottomAnchor.constraint(equalTo: subSubTitleLabel.bottomAnchor, constant: 10)
        ])
    }
    
    func setTimeCursor() {
        guard let model = currentModel else { return }
        
        let timeProgress = (model.timeStart.distance(to: Date()) / model.timeStart.distance(to: model.timeEnd)).clamped(0, 1)
        
        progress.isHidden = timeProgress == 0
        progress.progress = timeProgress
    }
    
    func configurate(_ model: TodayCellModel) {
        currentModel = model
        titleLabel.text = model.title
        subTitleLabel.text = model.searchable.mainTitle
        subSubTitleLabel.text = model.timeInterval()
        
        setTimeCursor()
    }
}
