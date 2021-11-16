//
//  TimetablePageVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.11.2021.
//

import UIKit

class TimetablePageVC: UIPageViewController  {
    
    var targetPage: TimetableViewController?
    var skipNextAppear: Date?
    var appeared = false
    
    var dictOffsets: [Date:CGFloat] = [:]
    var currentVC: TimetableViewController?
    
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appeared = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appeared = false
    }
    
    private lazy var timetableNavbar: TimetableNavbar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        $0.leftButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        $0.toCorrectPositionButton.addTarget(self, action: #selector(scrollToCurrentPageOrRow), for: .touchUpInside)
        $0.forwardPage.addTarget(self, action: #selector(forwardPageAction), for: .touchUpInside)
        $0.reversePage.addTarget(self, action: #selector(reversePageAction), for: .touchUpInside)
        return $0
    }(TimetableNavbar())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        (view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView).delegate = self
        
        setViews()
    }
    
    func updateBlurEffect(_ val: CGFloat) {
        if appeared {
            timetableNavbar.blurAnimator.fractionComplete = val
        }
    }
    
    
    func setViews() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = L10n.Timetable.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.Timetable.editButton, style: .plain, target: self, action: #selector(editButtonAction(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonAction(_:)))
        
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        var newSafeArea = UIEdgeInsets()
        newSafeArea.top += timetableNavbar.height
        self.additionalSafeAreaInsets = newSafeArea
        
        view.addSubview(timetableNavbar)
        NSLayoutConstraint.activate([
            timetableNavbar.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            timetableNavbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timetableNavbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timetableNavbar.heightAnchor.constraint(equalToConstant: timetableNavbar.height),
        ])
        
        targetPage = createTimetableVS(Date())
        currentVC = targetPage
        setViewControllers([targetPage!], direction: .forward, animated: true, completion: nil)
    }
}

//MARK:- PageViewController
extension TimetablePageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func addWeak(date: Date, count: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: count, to: date)!
    }
    
    func createTimetableVS(_ date: Date) -> TimetableViewController {
        let vc = TimetableViewController(date: date)
        vc.willAppear = willAppear
        vc.updateContentOffsetBlock = updateContentOffsetBlock
        vc.updateButtonTitle = updateButtonTitle
        dictOffsets[date] = -timetableNavbar.height
        return vc
    }
    
    func updateContentOffsetBlock(vc: TimetableViewController, offset: CGFloat) -> Void {
        dictOffsets[vc.date] = offset
        updateBlurEffect(calculateBlurByScroll(offset))
        currentVC = vc
    }
    
    func updateButtonTitle(isCurrentVC: Bool, withoutCurrentDate: Bool) {
        timetableNavbar.toCorrectPositionButton.isEnabled = true
        if isCurrentVC {
            if withoutCurrentDate {
                timetableNavbar.toCorrectPositionButton.setTitle(L10n.Timetable.notHaveCurrentDay, for: .normal)
                timetableNavbar.toCorrectPositionButton.isEnabled = false
            } else {
                timetableNavbar.toCorrectPositionButton.setTitle(L10n.Timetable.toTodayTimetable, for: .normal)
            }
        } else {
            timetableNavbar.toCorrectPositionButton.setTitle(L10n.Timetable.toCurrentWeek, for: .normal)
        }
    }
    
    func willAppear(page: TimetableViewController) {
        if (skipNextAppear != page.date) {
            targetPage = page
        }
        skipNextAppear = nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return createTimetableVS(addWeak(date: targetPage!.date, count: -1))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return createTimetableVS(addWeak(date: targetPage!.date, count: +1))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            guard let pageVC = viewControllers?.first as? TimetableViewController else { return }
            targetPage = pageVC
        }
    }
    
}


extension TimetablePageVC: UIScrollViewDelegate {
    
    func calculateBlurByScroll(_ offset: CGFloat) -> CGFloat {
        return min(1, max(0, (offset + timetableNavbar.height) / 5))
    }
    
    func lerp(_ from: CGFloat, _ to: CGFloat, _ progress: CGFloat) -> CGFloat {
        return from + (progress * (to - from))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let t = scrollView.contentOffset.x / view.bounds.width - 1
 
        if t != 0 && t != 1 && abs(t) > 0.05 {
            
            let fromDate = addWeak(date: targetPage!.date, count: -(t == 0 ? 0: t < 0 ? -1 : 1))
            
            let from = dictOffsets[fromDate] ?? -timetableNavbar.height
            let to = dictOffsets[targetPage!.date] ?? -timetableNavbar.height
            
            updateBlurEffect(lerp(calculateBlurByScroll(from), calculateBlurByScroll(to), abs(t)))
        }

    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let t = scrollView.contentOffset.x / view.bounds.width - 1
        if (targetContentOffset.pointee.x == view.bounds.width) {
            skipNextAppear = addWeak(date: targetPage!.date, count: -(t == 0 ? 0: t < 0 ? -1 : 1))
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
    
    @objc
    func scrollToCurrentPageOrRow(_ sender: UIButton) {
        guard let currentVC = self.currentVC else {return}
        if Calendar.current.isDate(currentVC.date, inSameDayAs: Date()) {
            currentVC.scrollToCurrentDate(date: currentVC.date)
            return
        }
        
        let direction: UIPageViewController.NavigationDirection = (Date() > currentVC.date) ? .forward : .reverse
        self.targetPage = createTimetableVS(Date())
        self.currentVC = targetPage
        setViewControllers([self.targetPage!], direction: direction, animated: true)
    }
    
    @objc
    func forwardPageAction(_ sender: UIButton) {
        scrollToNextPage(direction: .forward)
    }
    
    @objc
    func reversePageAction(_ sender: UIButton) {
        scrollToNextPage(direction: .reverse)
    }
    
    func scrollToNextPage(direction: UIPageViewController.NavigationDirection) {
        guard let current = self.currentVC else {
            return
        }
        self.targetPage = createTimetableVS(addWeak(date: current.date, count: direction == .forward ? +1 : -1))
        self.currentVC = targetPage
        setViewControllers([self.targetPage!], direction: direction, animated: true)
    }
}
