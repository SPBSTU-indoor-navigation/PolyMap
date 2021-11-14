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
        fromPage = createTimetableVS(Date())
        self.setViewControllers([fromPage!], direction: .forward, animated: true, completion: nil)
        let scrollView = self.view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = self
        setViews()
    }
    
    
    var appeared = false
    
    override func viewDidAppear(_ animated: Bool) {
        appeared = true
    }
    
    var currentPageDate: Date = Date()
    var nextPage: TimetableViewController?
    var fromPage: TimetableViewController?
    
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
        vc.willAppear = toPage
        vc.willDisappear = fromPage
        return vc
    }

    func toPage(_ page: TimetableViewController) {
        currentPageDate = page.date
        nextPage = page
    }
    
    func fromPage(_ page: TimetableViewController) {
        if nextPage != fromPage {
            fromPage = page
        }
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
            fromPage = pageVC
        }
    }
    
    func onScroll(pos: CGFloat) {
        if appeared {
            timetableNavbar.blurAnimator.fractionComplete = calculateBlurByScroll(pos)
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
    
    func calculateBlurByScroll(_ offset: CGFloat) -> CGFloat {
        return min(1, max(0, (offset + 50) / 20))
    }
    
    // Возвращает значение между from и to пропорционально progress. Т.е. когда progress == 0 вернётся from, а когда progress == 1 вернётся to
    func lerp(_ from: CGFloat, _ to: CGFloat, _ progress: CGFloat) -> CGFloat {
        return from + (progress * (to - from))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let t = abs(scrollView.contentOffset.x / view.bounds.width - 1)
        
        if appeared && t != 0 && t != 1 {
            print("\(fromPage?.tableView.contentOffset.y)  \(nextPage?.tableView.contentOffset.y)")
            let from = calculateBlurByScroll((fromPage?.tableView.contentOffset.y) ?? -50)
            let to = calculateBlurByScroll((nextPage?.tableView.contentOffset.y) ?? -50)
            
            
            timetableNavbar.blurAnimator.fractionComplete = lerp(from, to, t)
//            print(t)
        }
    }
}
