import UIKit

class SearchVC: NavbarBottomSheetPage {
    
    var isSearch = false
    var mapViewDelegate: MapViewDelegate?
    var mapInfoDelegate: MapInfoDelegate?
    var searchable: [Searchable] {
        set {
            searchTableView.searchable = newValue
        }
        
        get {
            searchTableView.searchable
        }
    }
    
    private lazy var searchBar: UISearchBar = {
        $0.placeholder = L10n.ChoosingSearchController.searchPlaceholder
        $0.searchBarStyle = .minimal
        $0.frame = navbar.frame
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        $0.delegate = self
        
        return $0
    }(UISearchBar())

    lazy var searchTableView: SearchTableView = {
        $0.searchTableViewDelegate = self
        return $0
    }(SearchTableView(frame: .zero, style: .grouped))
    
    override func viewDidLoad() {
        navbar.addSubview(searchBar)
        super.viewDidLoad()
        
        contentView.addSubview(searchTableView)
        
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: background.trailingAnchor)
        ])
    
    }
    
    func cancelEdit() {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.endEditing(true)
        isSearch = false
        searchTableView.proccesSearcheble()
    }
    
    override func onStateChange(verticalSize: BottomSheetViewController.VerticalSize) {
        super.onStateChange(verticalSize: verticalSize)
        if isSearch && verticalSize != .big {
            cancelEdit()
        }
    }
    
}

extension SearchVC: SearchTableViewDelegate {
    func willBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
        searchBar.endEditing(true)
    }
    
    func didScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
        update(progress: scrollView.topContentOffset.y / 20)
    }
    
    func willEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func didSelect(_ searchable: Searchable) {
        let annotation = searchable.annotation
        
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
        searchTableView.proccesSearcheble(searchText: searchText)
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


