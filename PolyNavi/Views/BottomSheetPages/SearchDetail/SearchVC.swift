import UIKit
import MapKit

class SearchVC: NavbarBottomSheetPage {
    
    var isSearch = false {
        didSet {
            UIView.animate(withDuration: 0.2, animations: { [self] in
                
                searchTableView.isHidden = false
                mainTableView.isHidden = false
                
                searchTableView.alpha = isSearch ? 1 : 0
                mainTableView.alpha = !isSearch ? 1 : 0
            }, completion: { _ in
                self.searchTableView.isHidden = !self.isSearch
                self.mainTableView.isHidden = self.isSearch
            })
            
        }
    }
    var verticalSizeBeforeSearch: BottomSheetViewController.VerticalSize?
    
    var mapViewDelegate: MapViewDelegate?
    var mapInfoDelegate: MapInfoDelegate?
    var searchable: [Searchable] = [] {
        didSet {
            searchTableView.searchable = searchable
            mainTableView.searchable = searchable
        }
    }
    
    private lazy var searchBar: UISearchBar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = L10n.ChoosingSearchController.searchPlaceholder
        $0.searchBarStyle = .minimal
        $0.frame = navbar.frame
        $0.returnKeyType = .search
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        $0.delegate = self
        
        return $0
    }(UISearchBar())
    
    lazy var mainTableView: MainSearchTableView = {
        $0.mainSearchTableViewDelegate = self
        return $0
    }(MainSearchTableView(frame: .zero, style: .insetGrouped))

    lazy var searchTableView: SearchTableView = {
        $0.searchTableViewDelegate = self
        return $0
    }(SearchTableView(frame: .zero, style: .grouped))
    
    override func viewDidLoad() {
        navbar.addSubview(searchBar)
        super.viewDidLoad()
        
        contentView.addSubview(searchTableView)
        contentView.addSubview(mainTableView)
        
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            
            searchBar.leadingAnchor.constraint(equalTo: navbar.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: navbar.trailingAnchor),
            searchBar.centerYAnchor.constraint(equalTo: navbar.centerYAnchor),
            
            mainTableView.topAnchor.constraint(equalTo: navbar.bottomAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            mainTableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
        ])
        
        isSearch = false
    
    }
    
    override func nextStateAfterTap(current: BottomSheetViewController.VerticalSize) -> BottomSheetViewController.VerticalSize? {
        if !isSearch {
            return super.nextStateAfterTap(current: current)
        }
        return nil
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
        if isSearch && verticalSize == .small {
            cancelEdit()
        }
    }
    
    override func onButtomSheetScroll(progress: CGFloat) {
        super.onButtomSheetScroll(progress: progress)
        if isSearch {
            searchBar.endEditing(true)
        }
    }
    
    private func select(annotation: MKAnnotation) {
        mapInfoDelegate?.select(annotation)
        mapViewDelegate?.focusAndSelect(annotation: annotation, focusVariant: .center)
    }
    
}

extension SearchVC: SearchTableViewDelegate, MainSearchTableViewDelegate {
    
    private func deginScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }
    
    private func didScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
        update(progress: scrollView.topContentOffset.y / 20)
    }
    
    
    func mainSearchTableDidScroll(_ scrollView: UIScrollView) { didScroll(scrollView) }
    func searchTableDidScroll(_ scrollView: UIScrollView) { didScroll(scrollView) }
    
    
    func mainSearchTableWillBeginDragging(_ scrollView: UIScrollView) { deginScroll(scrollView) }
    func searchTableWillBeginDragging(_ scrollView: UIScrollView) {
        deginScroll(scrollView)
        searchBar.endEditing(true)
    }
    
    
    func mainSearchTableWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func searchTableWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    
    func mainSearchTable(didSelect searchable: Searchable) {
        select(annotation: searchable.annotation)
    }
    
    func searchTable(didSelect searchable: Searchable) {
        select(annotation: searchable.annotation)
        searchBar.endEditing(true)
    }
}


extension SearchVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        verticalSizeBeforeSearch = delegate?.verticalSize()
        delegate?.change(verticalSize: .big, animated: true)
        isSearch = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelEdit()
        if delegate?.horizontalSize() == .big && delegate?.verticalSize() == .big {
            let size = verticalSizeBeforeSearch ?? .medium
            delegate?.change(verticalSize: size != .small ? size : .medium, animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
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


