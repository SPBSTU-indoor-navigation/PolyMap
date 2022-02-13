//
//  TimetablePageVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.11.2021.
//

import UIKit

class TimetablePageVC: UIPageViewController  {
    
    //MARK:- Properties
    var targetPage: TimetableViewController?
    var skipNextAppear: Date?
    var appeared = false
    var lastLoadedWeek: Timetable.Week?
    
    private lazy var safeAreaInset: UIEdgeInsets = {
        return $0
    }(UIEdgeInsets(top: timetableNavbar.height, left: 0, bottom: timetableToolBar.height, right: 0))
    
    var dictOffsets: [Date:CGFloat] = [:]
    var currentVC: TimetableViewController?
    
    //MARK:- Views
    private lazy var timetableNavbar: TimetableNavbar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        $0.leftButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        $0.forwardPage.addTarget(self, action: #selector(forwardPageAction), for: .touchUpInside)
        $0.reversePage.addTarget(self, action: #selector(reversePageAction), for: .touchUpInside)
        return $0
    }(TimetableNavbar())
    
    private lazy var timetableToolBar: TimetableToolBar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.toCorrectPositionButton.addTarget(self, action: #selector(scrollToCurrentPageOrRow), for: .touchUpInside)
        $0.iCal.addTarget(self, action: #selector(getICal), for: .touchUpInside)
        return $0
    }(TimetableToolBar())
    
    
    //MARK:- Init, Live cycle and layout
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        (view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView).delegate = self
        
        setViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appeared = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appeared = false
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
        
        view.addSubview(timetableNavbar)
        view.addSubview(timetableToolBar)
        NSLayoutConstraint.activate([
            timetableNavbar.topAnchor.constraint(equalTo: view.topAnchor),
            timetableNavbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timetableNavbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timetableNavbar.heightAnchor.constraint(equalToConstant: timetableNavbar.height),
            
            timetableToolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            timetableToolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timetableToolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timetableToolBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 55)
        ])
        
        targetPage = createTimetableVS(Date())
        currentVC = targetPage
        updateNavbar(date: targetPage!.date, week: targetPage!.weekData)
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
        vc.dateLoaded = dateLoaded
        vc.additionalSafeAreaInsets = safeAreaInset
        dictOffsets[vc.date] = -timetableNavbar.height
        return vc
    }
    
    func updateContentOffsetBlock(vc: TimetableViewController, offset: CGFloat) -> Void {
        dictOffsets[vc.date] = offset
        updateBlurEffect(calculateBlurByScroll(offset))
        currentVC = vc
    }
    
    func updateButtonTitle(isCurrentVC: Bool, withoutCurrentDate: Bool) {
        let label = withoutCurrentDate ? L10n.Timetable.notHaveCurrentDay : L10n.Timetable.toTodayTimetable
        
        UIView.performWithoutAnimation {
            timetableToolBar.toCorrectPositionButton.setTitle(label, for: .normal)
            timetableToolBar.toCorrectPositionButton.layoutIfNeeded()
        }
        
        timetableToolBar.toCorrectPositionButton.isEnabled = !withoutCurrentDate
    }
    
    func willAppear(page: TimetableViewController) {
        if (skipNextAppear != page.date) {
            targetPage = page
        }
        skipNextAppear = nil
    }
    
    func dateLoaded(week: Timetable.Week?) {
        lastLoadedWeek = week
        
        guard let loadedStartDay = week?.date_start else {return}
        
        guard let loadedStartDate = TimetableWeek.dateParser.date(from: loadedStartDay) else {return}
        guard let currentStartDate = timetableNavbar.currentStartDay else {return}
        
        if Calendar.current.isDate(loadedStartDate, inSameDayAs: currentStartDate) {
            timetableNavbar.setDateLabel(with: loadedStartDate, isOdd: week?.is_odd)
        }
    }
    
    func updateNavbar(date: Date, week: Timetable.Week?) {
        if let week = week {
            return timetableNavbar.setDateLabel(with: date, isOdd: week.is_odd)
        }
        
        guard let lastLoadedWeek = lastLoadedWeek else { return timetableNavbar.setDateLabel(with: date) }
        
        let lastLoadedDate = TimetableWeek.dateParser.date(from: lastLoadedWeek.date_start)!
        let currentDate = TimetableProvider.shared.startOfWeek(date)
        let delta = abs(Calendar.current.dateComponents([.weekOfYear], from: currentDate, to: lastLoadedDate).weekOfYear!)
        
        
        timetableNavbar.setDateLabel(with: date, isOdd: delta % 2 == 0 ? lastLoadedWeek.is_odd : !lastLoadedWeek.is_odd)
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
            updateNavbar(date: pageVC.date, week: pageVC.weekData)
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
        updateNavbar(date: targetPage!.date, week: targetPage?.weekData)
    }
    
    @objc
    func getICal(_ sender: UIButton) {
        let provider = TimetableProvider.shared
        guard
            let facultyID = GroupsAndTeacherStorage.shared.institute?.ID,
            let groupID = GroupsAndTeacherStorage.shared.groupNumber?.ID,
            let date = currentVC?.date,
            let url = URL(string: "https://ruz.spbstu.ru/faculty/\(facultyID)/groups/\(groupID)/ical?date=\(provider.apiFormatDate(provider.startOfWeek(date)))")
        else {
            return
        }
        UIApplication.shared.open(url)
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
        updateNavbar(date: targetPage!.date, week: targetPage?.weekData)
    }
}
