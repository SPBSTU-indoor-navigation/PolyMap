import UIKit

class SearchVC: NavbarBottomSheetPage {
    
    var isSearch = false
    var searchable: [Searchable] = []
    var mapViewDelegate: MapViewDelegate?
    var mapInfoDelegate: MapInfoDelegate?
    
    
    private var lastSearch: String = " "
    private var searchableSections: [(String,[Searchable])] = []
    
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
        $0.register(OccupantSearchCell.self, forCellReuseIdentifier: OccupantAnnotation.identifier)
        $0.register(AttractionSearchCell.self, forCellReuseIdentifier: AttractionAnnotation.identifier)
        $0.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchHeaderView.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.separatorColor = .clear
        return $0
    }(UITableView(frame: .zero, style: .grouped))
    
    lazy var emptyResult: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .callout)
        $0.textColor = .secondaryLabel
        $0.text = "Ничего не найдено"
        $0.isHidden = true
        return $0
    }(UILabel())
    
    override func viewDidLoad() {
        
        navbar.addSubview(searchBar)
        background.addSubview(tableView)
        super.viewDidLoad()
        
        tableView.addSubview(emptyResult)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            
            emptyResult.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 50),
            emptyResult.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
        ])
        
        proccesSearcheble()
    }
    
    func proccesSearcheble(searchText: String = "") {
        let searchText = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if searchText == lastSearch { return }
        lastSearch = searchText
        
        let searchable: [Searchable]
        
        if searchText.isEmpty {
            searchable = self.searchable
        } else {
            searchable = self.searchable.filter({ searchable in
                
                guard let title = searchable.mainTitle else { return false }
                
                return title.lowercased().contains(searchText)
            })
        }
        

        
        searchableSections = []
        
        let buildings = searchable.filter({ $0 is AttractionAnnotation }).sorted(by: comparator)
        if !buildings.isEmpty {
            searchableSections.append(("Buildings", buildings))
        }
        
        let occupants = searchable.filter({ $0 is OccupantAnnotation })
        
        let grouped = Dictionary(grouping: occupants, by: { $0.place })
        for group in grouped {
            searchableSections.append((group.key ?? "-", group.value.sorted(by: comparator)))
        }
        
        tableView.reloadData()
        emptyResult.isHidden = !searchableSections.isEmpty
    }
    
    func cancelEdit() {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.endEditing(true)
        isSearch = false
        proccesSearcheble()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchableSections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchable = searchableSections[indexPath.section].1[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: (searchable as? Identifiable)?.identifier ?? OccupantAnnotation.identifier, for: indexPath)
        
        if searchable is OccupantAnnotation {
            (cell as? OccupantSearchCell)?.configurate(searchable: searchable)
        } else if searchable is AttractionAnnotation {
            (cell as? AttractionSearchCell)?.configurate(searchable: searchable)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchHeaderView.identifier) as? SearchHeaderView else { return nil}

        header.configurate(text: searchableSections[section].0)
        
        return header
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let annotation = searchableSections[indexPath.section].1[indexPath.row].annotation
        searchBar.endEditing(true)
        
        mapInfoDelegate?.select(annotation)
        mapViewDelegate?.focusAndSelect(annotation: annotation, focusVariant: .center)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        proccesSearcheble(searchText: searchText)
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

fileprivate func comparator(a: Searchable, b: Searchable) -> Bool {
    return (a.mainTitle ?? "") < (b.mainTitle ?? "")
}
