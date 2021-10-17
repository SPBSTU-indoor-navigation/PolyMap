//
//  LessonCellView.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 05.10.2021.
//

import UIKit


class LessonCellView: UITableViewCell {
    
    public static var identifire: String {
        return String(describing: self)
    }
    
    private var model = LessonModel(subjectName: "", timeStart: "", timeEnd: "", type: "", place: "", teacher: "")
    
    private lazy var labelsStackView: UIStackView = {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIStackView())
    
    private lazy var mainBackView: UIView = {
        $0.backgroundColor = .secondarySystemGroupedBackground
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var divider: UIView = {
        $0.backgroundColor = .systemGray3
        $0.layer.cornerRadius = 2
        $0.translatesAutoresizingMaskIntoConstraints = false
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK:- Set views
extension LessonCellView {
    private func setViews() {
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        [subjectNameLabel, typeOfLessonLabel, teacherNameLabel, placeLabel].forEach {
            labelsStackView.addArrangedSubview($0)
        }
        mainBackView.addSubview(timeStart)
        mainBackView.addSubview(timeEnd)
        mainBackView.addSubview(labelsStackView)
        mainBackView.addSubview(divider)
        
        self.contentView.addSubview(mainBackView)
        
        let timeStartSize = (timeStart.text ?? "22:22").size(withAttributes: [NSAttributedString.Key.font: timeStart.font!])
        let timeEndSize = (timeEnd.text ?? "22:22").size(withAttributes: [NSAttributedString.Key.font: timeEnd.font!])
        
        NSLayoutConstraint.activate([
            mainBackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            mainBackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            mainBackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            
            timeStart.topAnchor.constraint(equalTo: subjectNameLabel.topAnchor),
            timeStart.trailingAnchor.constraint(equalTo: divider.leadingAnchor, constant: 0),
            timeStart.leadingAnchor.constraint(equalTo: mainBackView.leadingAnchor, constant: 0),
            
            timeEnd.bottomAnchor.constraint(equalTo: placeLabel.bottomAnchor),
            timeEnd.trailingAnchor.constraint(equalTo: divider.leadingAnchor, constant: 0),
            timeEnd.leadingAnchor.constraint(equalTo: mainBackView.leadingAnchor, constant: 0),
            
            divider.topAnchor.constraint(equalTo: mainBackView.topAnchor, constant: 2),
            divider.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor, constant: -2),
            divider.leadingAnchor.constraint(equalTo: mainBackView.leadingAnchor, constant: max(timeEndSize.width, timeStartSize.width) + 20),
            divider.widthAnchor.constraint(equalToConstant: 2),
            
            labelsStackView.topAnchor.constraint(equalTo: mainBackView.topAnchor, constant: 10),
            labelsStackView.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 5),
            labelsStackView.trailingAnchor.constraint(equalTo: mainBackView.trailingAnchor, constant: -10),
            
            mainBackView.bottomAnchor.constraint(equalTo: labelsStackView.bottomAnchor, constant: 10),
            self.contentView.bottomAnchor.constraint(equalTo: mainBackView.bottomAnchor),
        ])
    }
    
    public func configure(model: LessonModel) {
        self.model = model
        timeStart.text = model.timeStart
        timeEnd.text = model.timeEnd
        subjectNameLabel.text = model.subjectName
        typeOfLessonLabel.text = model.type
        teacherNameLabel.text = model.teacher
        placeLabel.text = model.place
        
        mainBackView.layer.cornerRadius = 0
        mainBackView.layer.maskedCorners = []
        
        divider.backgroundColor = model.isLecture() ? .systemGreen : .systemPink
        
        if (model.teacher.isEmpty && labelsStackView.arrangedSubviews.contains(teacherNameLabel)) {
            labelsStackView.removeArrangedSubview(teacherNameLabel)
        }

        if (!model.teacher.isEmpty && !labelsStackView.arrangedSubviews.contains(teacherNameLabel)) {
            guard let index = labelsStackView.arrangedSubviews.firstIndex(of: placeLabel) else {return}
            labelsStackView.insertArrangedSubview(teacherNameLabel, at: index)
        }
    }
    
    public func cornernIfFirst() {
        mainBackView.layer.cornerRadius = 15
        mainBackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    public func cornernIfLast() {
        mainBackView.layer.cornerRadius = 15
        mainBackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    public func cornernIfOne() {
        mainBackView.layer.cornerRadius = 15
        mainBackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}



//MARK:-SwiftUI Canvas
import SwiftUI

class LessonCellView_Provide: PreviewProvider {
    static var previews: some View {
        ContainerView()
            .previewLayout(PreviewLayout.sizeThatFits)
            .frame(width: 300, height: 100)
    }
    
    struct ContainerView: UIViewRepresentable {
        
        func makeUIView(context: UIViewRepresentableContext<LessonCellView_Provide.ContainerView>) -> some UIView {
            let vc = LessonCellView()
            vc.configure(model: LessonModel(subjectName: "Выч мат", timeStart:"10:00", timeEnd: "11:30", type: "Лекция", place: "Гидрак", teacher: "Устинов С.М."))
            return vc
        }
        
        func updateUIView(_ uiView: LessonCellView_Provide.ContainerView.UIViewType, context: UIViewRepresentableContext<LessonCellView_Provide.ContainerView>) {
            
        }
    }
}
