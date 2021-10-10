//
//  ViewController.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 05.10.2021.
//

import UIKit

class ViewController: UIViewController {
    private var arrayOfDaysWithLessons: [TimetableWeek.TimetableDay] = []
    
    private lazy var tableView: UITableView = {
        $0.register(LessonCellView.self, forCellReuseIdentifier: LessonCellView.identifire)
        $0.register(DateTableViewCell.self, forCellReuseIdentifier: DateTableViewCell.identifire)
        $0.register(EmptyLessonTableViewCell.self, forCellReuseIdentifier: EmptyLessonTableViewCell.identifire)
        $0.separatorStyle = .none
        $0.allowsSelection = false
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        return $0
    }(UITableView())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setViews()
        
        TimetableProvider.shared.loadTimetable(startDate: nil) { response in
            guard let response = response else { return }
            let timetable = TimetableWeek.convert(response)
            self.arrayOfDaysWithLessons = timetable.days
            DispatchQueue.main.async {
                self.loadData()
            }
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfDaysWithLessons.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDaysWithLessons[section].lessons.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            guard let dateCell = tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.identifire) as? DateTableViewCell else {
                return UITableViewCell()
            }
            dateCell.configure(withDate: arrayOfDaysWithLessons[indexPath.section].date)
            return dateCell
        }

        let element = arrayOfDaysWithLessons[indexPath.section].lessons[indexPath.row - 1]
        
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
        if arrayOfDaysWithLessons[indexPath.section].lessons.count == 1 {
            cell.cornernIfOne()
        } else if indexPath.row == 1 {
            cell.cornernIfFirst()
        } else if indexPath.row == self.arrayOfDaysWithLessons[indexPath.section].lessons.count {
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
        for i in 0..<arrayOfDaysWithLessons.count {
            arrayOfDaysWithLessons[i].lessons = LessonModel.createCorrectTimeTable(currentArray: arrayOfDaysWithLessons[i].lessons)
        }
        self.tableView.reloadData()
    }
}
