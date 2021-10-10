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
