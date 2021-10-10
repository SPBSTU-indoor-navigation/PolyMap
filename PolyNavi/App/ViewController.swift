//
//  ViewController.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 05.10.2021.
//

import UIKit

class ViewController: UIViewController {

    var arr: [[LessonModel]] = [
        [
            LessonModel(subjectName: "Выч мат", timeStart:"10:00", timeEnd: "11:30", type: "Лекция", place: "Гидрак", teacher: "Устинов С.М."),
            LessonModel(subjectName: "Выч мат", timeStart:"14:00", timeEnd: "11:30", type: "Лекция", place: "Гидрак", teacher: "Устинов С.М."),
            LessonModel(subjectName: "Выч мат", timeStart:"16:00", timeEnd: "11:30", type: "Лекция", place: "Гидрак", teacher: "Устинов С.М."),
        ],
        
        [
            LessonModel(subjectName: "Выч мат", timeStart:"10:00", timeEnd: "11:30", type: "Лекция", place: "Гидрак", teacher: "Устинов С.М."),
            LessonModel(subjectName: "Выч мат", timeStart:"12:00", timeEnd: "11:30", type: "Лекция", place: "Гидрак", teacher: "Устинов С.М."),
        ],
        
        [
            LessonModel(subjectName: "Выч мат", timeStart:"10:00", timeEnd: "11:30", type: "Лекция", place: "Гидрак", teacher: "Устинов С.М."),
        ],
    ]
    
    private lazy var tableView: UITableView = {
        $0.register(LessonCellView.self, forCellReuseIdentifier: LessonCellView.identifire)
        $0.register(DateTableViewCell.self, forCellReuseIdentifier: DateTableViewCell.identifire)
        $0.register(EmptyLessonTableViewCell.self, forCellReuseIdentifier: EmptyLessonTableViewCell.identifire)
        $0.separatorStyle = .none
        $0.allowsSelection = false
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        return $0
    }(UITableView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            guard let dateCell = tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.identifire) as? DateTableViewCell else {
                return UITableViewCell()
            }
            return dateCell
        }

        let element = arr[indexPath.section][indexPath.row - 1]
        
        if element.isEmptyLesson() {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EmptyLessonTableViewCell.identifire) as? EmptyLessonTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(time: element.timeStart + "-" + element.timeEnd)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonCellView.identifire) as? LessonCellView else {
            return UITableViewCell()
        }
        
        cell.configure(model: element)
        if arr[indexPath.section].count == 1 {
            cell.cornernIfOne()
        } else if indexPath.row == 1 {
            cell.cornernIfFirst()
        } else if indexPath.row == self.arr[indexPath.section].count {
            cell.cornernIfLast()
        }
        return cell
    }
}


extension ViewController {
    private func setViews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


extension ViewController {
    private func loadData() {
        for i in 0..<arr.count {
            arr[i] = LessonModel.createCorrectTimeTable(currentArray: arr[i])
        }
        self.tableView.reloadData()
    }
}
