//
//  Timetable+DatasourceDelegate.swift
//  PolyNavi
//
//  Created by Никита Фролов  on 10.10.2021.
//

import UIKit

extension TimetableViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfDaysWithLessons.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDaysWithLessons[section].timetableCell.count
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
        let element = arrayOfDaysWithLessons[indexPath.section].timetableCell[indexPath.row]

        if let lessonBreak = element as? BreakModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TimetableBreakTableViewCell.identifire) as? TimetableBreakTableViewCell else {
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
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if appeared {
            self.updateContentOffsetBlock?(self, scrollView.contentOffset.y)
        }
    }

}
