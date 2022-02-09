import UIKit

class SearchVC: TableBottomSheetPage {
    private lazy var searchController: UISearchController = {
//        $0.obscuresBackgroundDuringPresentation = false
//        $0.searchBar.placeholder = L10n.ChoosingSearchController.searchPlaceholder
        $0.view.frame = navbar.frame
//        $0.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(UISearchController(searchResultsController: nil))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.addSubview(searchController.view)
        addChild(searchController)
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(UnitDetailVC(closable: true), animated: true)
    }
    
}

extension SearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = "Search \(indexPath.row)"
        return cell
    }
    
    func setupColor(color: UIColor) {
        view.backgroundColor = .clear
    }
}
