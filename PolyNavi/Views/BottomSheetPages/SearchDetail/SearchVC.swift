import UIKit

class SearchCell: UITableViewCell {
    public static var identifire: String {
        return String(describing: self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
//        contentView.addSubview(title)
//        contentView.addSubview(content)
//        backgroundColor = Asset.Colors.bottomSheetGroupped.color
//
//        NSLayoutConstraint.activate([
//            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            content.topAnchor.constraint(equalTo: title.bottomAnchor),
//            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            contentView.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 8),
//        ])
    }
}

class SearchVC: NavbarBottomSheetPage {
    
    var isSearch = false
    
    private var preferredScrollProgress = 0.0
    
    private lazy var searchBar: UISearchBar = {
        $0.placeholder = L10n.ChoosingSearchController.searchPlaceholder
        $0.searchBarStyle = .minimal
        $0.frame = navbar.frame
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        $0.delegate = self
        
        return $0
    }(UISearchBar())
    
    lazy var tableView: UITableView = {
        $0.register(SearchCell.self, forCellReuseIdentifier: SearchCell.identifire)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UITableView())
    
    override func viewDidLoad() {
        
        navbar.addSubview(searchBar)
        background.addSubview(tableView)
        super.viewDidLoad()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
        ])
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let unitDetail = UnitDetailVC(closable: true)
//        unitDetail.configurate(unitInfo: UnitInfo()
        navigationController?.pushViewController(unitDetail, animated: true)
    }
    
    func cancelEdit() {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.endEditing(true)
        isSearch = false
    }
    
    override func onStateChange(verticalSize: BottomSheetViewController.VerticalSize) {
        super.onStateChange(verticalSize: verticalSize)
        if isSearch && verticalSize != .big {
            cancelEdit()
        }
    }
    
    override func onButtomSheetScroll(progress: CGFloat) {
        super.onButtomSheetScroll(progress: progress)
        let limit = 0.9
        if progress > limit {
            tableView.alpha = 1 - (progress - limit) / (1 - limit)
            update(progress: preferredScrollProgress * tableView.alpha)
        } else if tableView.alpha != 1 {
            tableView.alpha = 1
            update(progress: preferredScrollProgress * tableView.alpha)
        }
    }
    
}

extension SearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifire, for: indexPath)
//        cell.backgroundColor = .clear
//        cell.textLabel?.text = "Search \(indexPath.row)"
//        cell.imageView?.image = Asset.Annotation.Amenity.classroom.image
//        cell.detailTextLabel?.text = "bar"
        return cell
    }
    
    func setupColor(color: UIColor) {
        view.backgroundColor = .clear
    }
}

extension SearchVC: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
        searchBar.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
        preferredScrollProgress = scrollView.topContentOffset.y / 20
        update(progress: preferredScrollProgress)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}


extension SearchVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        delegate?.change(verticalSize: .big, animated: true)
        isSearch = true
        return true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelEdit()
        if delegate?.horizontalSize() == .big && delegate?.verticalSize() == .big {
            delegate?.change(verticalSize: .medium, animated: true)
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        DispatchQueue.main.async {
            if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
        return true
    }
}
