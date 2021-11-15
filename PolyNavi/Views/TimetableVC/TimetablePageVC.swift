//
//  TimetablePageVC.swift
//  PolyNavi
//
//  Created by Andrei Soprachev on 09.11.2021.
//

import UIKit

class TimetablePageVC: UIPageViewController  {
    
    var currentPage: PagePlaceholder?
    var targetPage: PagePlaceholder?
    var animatedPage: PagePlaceholder?
    var scrollT = 0.0
    
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
    
    private lazy var debug: UILabel = {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.font = .boldSystemFont(ofSize: 20)
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
        
        currentPage = createTimetableVS(0)
        animatedPage = currentPage
        setViewControllers([currentPage!], direction: .forward, animated: true, completion: nil)
    }
}

//MARK:- PageViewController
extension TimetablePageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func createTimetableVS(_ num: Int) -> PagePlaceholder {
        let vc = PagePlaceholder(num: num)
        vc.didApear = didApear
        vc.willApear = willApear
        vc.willDisapear = willDisappear(page:)
        return vc
    }
    
    func didApear(page: PagePlaceholder) {
//        print("didApear \(page.number)")
    }
    
    func willApear(page: PagePlaceholder) {
        print("willApear \(page.number)")
        targetPage = page
        if currentPage != page {
            currentPage = page
            print("Page: \(currentPage!.number)")
//            debug.text = "-> \(currentPage!.number)\ta: \(animatedPage!.number)"
        }
    }
    
    func willDisappear(page: PagePlaceholder) {
        print("willDisappear \(page.number)")
        if targetPage == page {
            targetPage = nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return createTimetableVS(currentPage!.number - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return createTimetableVS(currentPage!.number + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            guard let pageVC = viewControllers?.first as? PagePlaceholder else { return }
            
            animatedPage = pageVC
            if currentPage != pageVC {
                currentPage = pageVC
                print("Page: \(currentPage!.number)")
            }
            
//            debug.text = "-> \(currentPage!.number)\ta: \(animatedPage!.number)"
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
        process(t)

    }
    
    func process(_ t: CGFloat) {
        scrollT = abs(t)
        if t != 0 && t != 1 && abs(t) > 0.05 {
            let from = currentPage!.number - (t == 0 ? 0: t < 0 ? -1 : 1)
            let to = currentPage!.number
            DispatchQueue.main.async {
                
                self.debug.text = "\(from) \t-> \(to)\tp: \(NSString(format: "%.2f", t))\tPage: \(round(self.lerp(CGFloat(from), CGFloat(to), abs(t)) * 1000)/1000)"
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



class PagePlaceholder: UIViewController {
    
    var number = 0
    var offset: Int {
        get {
            return number == 0 ? 100: -50
        }
    }
    
    var didApear: ((PagePlaceholder) -> Void)?
    var willApear: ((PagePlaceholder) -> Void)?
    var didDisapear: ((PagePlaceholder) -> Void)?
    var willDisapear: ((PagePlaceholder) -> Void)?
    
    init(num: Int) {
        super.init(nibName: nil, bundle: nil)
        number = num
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var text: UILabel = {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.font = .boldSystemFont(ofSize: 50)
        $0.textAlignment = .center
        $0.text = "\(number)"
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UILabel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didApear?(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willApear?(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDisapear?(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDisapear?(self)
    }
    
    func layoutViews() {
        view.addSubview(text)
        
        NSLayoutConstraint.activate([
            text.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            text.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            text.topAnchor.constraint(equalTo: view.topAnchor, constant: 200)
        ])
    }
    
}
