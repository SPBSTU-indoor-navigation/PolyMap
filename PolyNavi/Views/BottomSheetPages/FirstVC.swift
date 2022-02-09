import UIKit

class FirstVC: NavbarBottomSheetPage {
    
    private lazy var searchController: UISearchController = {
        $0.obscuresBackgroundDuringPresentation = false
        $0.searchBar.placeholder = L10n.ChoosingSearchController.searchPlaceholder
        return $0
    }(UISearchController(searchResultsController: nil))
    
    private lazy var tableView: UITableView = {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UITableView())
    
    override func viewDidLoad() {
        background.addSubview(tableView)
    
        super.viewDidLoad()
    
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: background.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: background.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            
        ])
        
        tableView.reloadData()
    }

}

extension FirstVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = "First \(indexPath.row)"
        return cell
    }
    
    func setupColor(color: UIColor) {
        view.backgroundColor = .clear
    }
}

extension FirstVC: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
        update(progress: scrollView.topContentOffset.y / 20)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.row == 0) {
            navigationController?.pushViewController(UnitDetailVC(closable: true), animated: true)
        } else {
            navigationController?.pushViewController(SearchVC(closable: true), animated: true)
        }
        
//        let t = FirstVC()
//        t.setupColor(color: indexPath.row % 2 == 0 ? .systemBlue : .systemGreen)
//        navigationController?.pushViewController(t, animated: true)
    }
}
