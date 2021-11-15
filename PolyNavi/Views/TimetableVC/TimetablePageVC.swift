//
//  TimetablePageVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.11.2021.
//

import UIKit

class TimetablePageVC: UIPageViewController  {
    
    var targetPage: TimetableViewController?
    var appeared = false
    
    var dictOffsets: [Date:CGFloat] = [:]
    
    var scrollVar = 0.0
    
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
    
    private lazy var timetableNavbar: TimetableNavbar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        $0.leftButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return $0
    }(TimetableNavbar())
    
    private lazy var debug: UILabel = {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.font = .boldSystemFont(ofSize: 20)
        $0.backgroundColor = .systemBackground
        $0.text = ""
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        (view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView).delegate = self
        
        setViews()
    }
    
    
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
        view.addSubview(debug)
        NSLayoutConstraint.activate([
            timetableNavbar.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            timetableNavbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timetableNavbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timetableNavbar.heightAnchor.constraint(equalToConstant: 50),
            debug.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            debug.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            debug.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        targetPage = createTimetableVS(Date())
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
        dictOffsets[date] = -50
        return vc
    }
    
    func updateContentOffsetBlock(vc: TimetableViewController, offset: CGFloat) -> Void {
        dictOffsets[vc.date] = offset
        if appeared {
            timetableNavbar.blurAnimator.fractionComplete = calculateBlurByScroll(offset)
        }
    }
    
    func willAppear(page: TimetableViewController) {
        targetPage = page
        print(page.date)
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
        return min(1, max(0, (offset + 50) / 20))
    }
    
    // Возвращает значение между from и to пропорционально progress. Т.е. когда progress == 0 вернётся from, а когда progress == 1 вернётся to
    func lerp(_ from: CGFloat, _ to: CGFloat, _ progress: CGFloat) -> CGFloat {
        return from + (progress * (to - from))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let t = scrollView.contentOffset.x / view.bounds.width - 1
        if(abs(scrollVar - t) > 0.95) {
            print("CHANGE")
        }
        scrollVar = t
        if t != 0 && t != 1 && abs(t) > 0.05 {
            
            let fromDate = addWeak(date: targetPage!.date, count: -(t == 0 ? 0: t < 0 ? -1 : 1))
            
            let from = dictOffsets[fromDate] ?? -50
            let to = dictOffsets[targetPage!.date] ?? -50
            
            timetableNavbar.blurAnimator.fractionComplete = lerp(calculateBlurByScroll(from), calculateBlurByScroll(to), abs(t))
            
            DispatchQueue.main.async { [self] in
                self.debug.text = "\(from) \t-> \(to)\t\(fromDate)\t\(self.targetPage!.date)\tp: \(NSString(format: "%.2f", t))"
            }
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
