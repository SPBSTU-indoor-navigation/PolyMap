//
//  LessonCellView.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 05.10.2021.
//

import UIKit


class LessonCellView: UITableViewCell {
    
    let timeCursorRadius = 8.0
    let timeCursorBorder = 5.0
    var currentTimeAnchor: NSLayoutConstraint?
    var dividerAnchor: NSLayoutConstraint?
    
    public static var identifire: String {
        return String(describing: self)
    }
    
    private var model: LessonModel?
    
    private lazy var labelsStackView: UIStackView = {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIStackView())
    
    private lazy var mainBackView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var divider: UIView = {
        $0.backgroundColor = .systemGray3
        $0.layer.cornerRadius = 2
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var timeCursor: UIView = {
        let center: UIView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .systemRed
            $0.layer.cornerRadius = timeCursorRadius/2
            return $0
        }(UIView())
        
        $0.backgroundColor = .secondarySystemGroupedBackground
        $0.layer.cornerRadius = timeCursorRadius/2
       
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.addSubview(center)
        NSLayoutConstraint.activate([
            center.centerYAnchor.constraint(equalTo: $0.centerYAnchor),
            center.centerXAnchor.constraint(equalTo: $0.centerXAnchor),
            center.widthAnchor.constraint(equalToConstant: timeCursorRadius),
            center.heightAnchor.constraint(equalToConstant: timeCursorRadius)
        ])
        return $0
    }(UIView())
    
    private lazy var timeStart: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .body)
        return $0
    }(UILabel())
    
    private lazy var timeEnd: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .body)
        return $0
    }(UILabel())
    
    private lazy var subjectNameLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        return $0
    }(UILabel())
    
    private lazy var teacherNameLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        return $0
    }(UILabel())
    
    private lazy var placeLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .body)
        return $0
    }(UILabel())
    
    private lazy var typeOfLessonLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .body)
        return $0
    }(UILabel())
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (_) in
            self.setTimeCursor()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        setTimeCursor()
    }
}
    

//MARK:- Set views
extension LessonCellView {
    private func setViews() {
        [subjectNameLabel, typeOfLessonLabel, teacherNameLabel, placeLabel].forEach {
            labelsStackView.addArrangedSubview($0)
        }
        mainBackView.addSubview(timeStart)
        mainBackView.addSubview(timeEnd)
        mainBackView.addSubview(labelsStackView)
        mainBackView.addSubview(divider)
        divider.addSubview(timeCursor)
        
        self.contentView.addSubview(mainBackView)
    
        
        currentTimeAnchor = timeCursor.centerYAnchor.constraint(equalTo: divider.topAnchor, constant: 20)
        dividerAnchor = divider.leadingAnchor.constraint(equalTo: mainBackView.leadingAnchor, constant: 0)
        NSLayoutConstraint.activate([
            mainBackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            mainBackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            mainBackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            timeStart.topAnchor.constraint(equalTo: subjectNameLabel.topAnchor),
            timeStart.trailingAnchor.constraint(equalTo: divider.leadingAnchor),
            timeStart.leadingAnchor.constraint(equalTo: mainBackView.leadingAnchor),
            
            timeEnd.bottomAnchor.constraint(equalTo: placeLabel.bottomAnchor),
            timeEnd.trailingAnchor.constraint(equalTo: divider.leadingAnchor),
            timeEnd.leadingAnchor.constraint(equalTo: mainBackView.leadingAnchor),
            
            divider.topAnchor.constraint(equalTo: mainBackView.topAnchor, constant: 5),
            divider.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor, constant: -5),
            divider.widthAnchor.constraint(equalToConstant: 2),
            dividerAnchor!,
            
            timeCursor.widthAnchor.constraint(equalToConstant: timeCursorRadius + timeCursorBorder),
            timeCursor.heightAnchor.constraint(equalToConstant: timeCursorRadius + timeCursorBorder),
            timeCursor.centerXAnchor.constraint(equalTo: divider.centerXAnchor),
            currentTimeAnchor!,

            labelsStackView.topAnchor.constraint(equalTo: mainBackView.topAnchor, constant: 10),
            labelsStackView.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 5),
            labelsStackView.trailingAnchor.constraint(equalTo: mainBackView.trailingAnchor, constant: -10),
            
            mainBackView.bottomAnchor.constraint(equalTo: labelsStackView.bottomAnchor, constant: 10),
            self.contentView.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
        ])
    }
    
    public func setTimeCursor() {
        
        guard let start = model?.timeStart else { return }
        guard let end = model?.timeEnd else { return }

        let progress = start.distance(to: Date()) / start.distance(to: end)

        if (0...1 ~= progress) {
            let cursorHeigth = timeCursorBorder + timeCursorRadius
            timeCursor.isHidden = false
            currentTimeAnchor?.constant = cursorHeigth / 2 + (divider.frame.height - cursorHeigth) * progress
        } else {
            timeCursor.isHidden = true
        }
    }
    
    public func configure(model: LessonModel) {
        let timeFormatter: DateFormatter = {
            $0.timeStyle = .short
            return $0
        }(DateFormatter())
        
        self.model = model
        timeEnd.text = timeFormatter.string(from: model.timeEnd)
        timeStart.text = timeFormatter.string(from: model.timeStart)
        subjectNameLabel.text = model.subjectName
        typeOfLessonLabel.text = model.typeName
        teacherNameLabel.text = model.teacher
        placeLabel.text = model.place
        
        switch model.type {
        case .Lecture:
            divider.backgroundColor = .systemGreen
        case .Practice, .Other:
            divider.backgroundColor = .systemPink
        }
        
        if (model.teacher.isEmpty && labelsStackView.arrangedSubviews.contains(teacherNameLabel)) {
            labelsStackView.removeArrangedSubview(teacherNameLabel)
        }

        if (!model.teacher.isEmpty && !labelsStackView.arrangedSubviews.contains(teacherNameLabel)) {
            guard let index = labelsStackView.arrangedSubviews.firstIndex(of: placeLabel) else {return}
            labelsStackView.insertArrangedSubview(teacherNameLabel, at: index)
        }
        
        let timeStartSize = (timeStart.text ?? "22:22").size(withAttributes: [NSAttributedString.Key.font: timeStart.font!])
        let timeEndSize = (timeEnd.text ?? "22:22").size(withAttributes: [NSAttributedString.Key.font: timeEnd.font!])
        let maxTime = ("22:22").size(withAttributes: [NSAttributedString.Key.font: timeStart.font!])
        dividerAnchor?.constant = max(max(timeEndSize.width, timeStartSize.width) + 10 , maxTime.width + 20)
        
        setTimeCursor()
        
    }
}

