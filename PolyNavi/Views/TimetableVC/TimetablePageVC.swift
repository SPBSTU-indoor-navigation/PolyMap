//
//  TimetablePageVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.11.2021.
//

import UIKit

class TimetablePageVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Timetable.title
        self.delegate = self
        self.dataSource = self
        
        self.setViewControllers([TimetableViewController(date: Date())], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let t = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        return TimetableViewController(date: t)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            let t = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!
        return TimetableViewController(date: t)
    }
}
