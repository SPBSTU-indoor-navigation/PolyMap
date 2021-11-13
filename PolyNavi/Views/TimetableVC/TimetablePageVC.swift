//
//  TimetablePageVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.11.2021.
//

import UIKit

class TimetablePageVC: UIPageViewController  {
    
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var timetableNavbar: TimetableNavbar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        $0.leftButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return $0
    }(TimetableNavbar())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        //        t.tableView.scroll
        
        self.setViewControllers([createTimetableVS(Date())], direction: .forward, animated: true, completion: nil)
        let scrollView = self.view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = self
        setViews()
    }
    
    
    var appeared = false
    
    override func viewDidAppear(_ animated: Bool) {
        //        timetableNavbar.blurAnimator.startAnimation()
        appeared = true
    }
    
    var currentPageDate: Date = Date()
    
    func setViews() {
        view.backgroundColor = .systemBackground
        
        
        navigationItem.title = L10n.Timetable.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.Timetable.editButton, style: .plain, target: self, action: #selector(editButtonAction(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction(_:)))
        
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        var newSafeArea = UIEdgeInsets()
        newSafeArea.top += 50
        self.additionalSafeAreaInsets = newSafeArea
        
        view.addSubview(timetableNavbar)
        NSLayoutConstraint.activate([
            timetableNavbar.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            timetableNavbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timetableNavbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timetableNavbar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
        
    }
    
}

//MARK:- PageViewController
extension TimetablePageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func createTimetableVS(_ date: Date) -> TimetableViewController {
        let vc = TimetableViewController(date: date)
        vc.updateContentOffsetBlock = onScroll
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return createTimetableVS(Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentPageDate)!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return createTimetableVS(Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentPageDate)!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            guard let pageVC = viewControllers?.first as? TimetableViewController else { return }
            currentPageDate = pageVC.date
            if #available(iOS 15.0, *) {
                navigationItem.title = ""
            }
        }
    }
    
    func onScroll(pos: CGFloat) {
        if appeared {
            print(pos)
            timetableNavbar.blurAnimator.fractionComplete = pos / 10 + 5
        }
    }
}

//MARK:- Navbar
extension TimetablePageVC {
    
    func reloadData() {
        self.dataSource = nil
        self.dataSource = self
        
        guard let pageVC = viewControllers?.first as? TimetableViewController else { return }
        pageVC.loadData()
    }
    
    @objc
    func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func editButtonAction(_ sender: UIButton) {
        let vc = SettingTimetableVC()
        vc.finishAction = { [weak self] in
            self?.reloadData()
        }
        let navSettingVC = UINavigationController(rootViewController: vc)
        self.present(navSettingVC, animated: true)
    }
    
}

extension TimetablePageVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        print(scrollView.contentOffset.x)
    }
}
