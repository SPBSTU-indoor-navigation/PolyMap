//
//  Timetable+DatasourceDelegate.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 10.10.2021.
//

import UIKit
import SkeletonView

extension TimetableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfDaysWithLessons.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDaysWithLessons[section].lessons.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if arrayOfDaysWithLessons.isEmpty {
            return nil
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: DateTableViewCell.identifire) as! DateTableViewCell
        view.configure(withDate: arrayOfDaysWithLessons[section].date)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = arrayOfDaysWithLessons[indexPath.section].lessons[indexPath.row]
        
        if let lessonBreak = element as? BreakModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EmptyLessonTableViewCell.identifire) as? EmptyLessonTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(model: lessonBreak)
            return cell
        } else if let lesson = element as? LessonModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonCellView.identifire) as? LessonCellView else {
                return UITableViewCell()
            }
            
            cell.configure(model: lesson)
            return cell
        }
        
        return UITableViewCell()
    }
}

//MARK:-SkeletonView
extension TimetableViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if (indexPath.row % 2 == 0) {
            return SkeletonDateTableViewCell.identifire
        }
        return SkeletonLessonCellView.identifire
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        8
    }
}
