import UIKit


class FirstVC: UIViewController, UITableViewDataSource, UITableViewDelegate, BottomSheetChildViewControllerProtocol {

    var scrollView: UIScrollView? {
        return tableView
    }
    
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
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.reloadData()
        
        view.layer.cornerRadius = 15
//        view.clipsToBounds = true
        view.layer.shadowRadius = 50
        view.layer.shadowOpacity = 1
        view.backgroundColor = .black
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func didSelectRowAtIndexPath(_ tableView: UITableView, indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let t = FirstVC()
        if indexPath.row % 3 == 0 { t.setupColor(color: .red) }
        if indexPath.row % 3 == 1 { t.setupColor(color: .blue) }
        if indexPath.row % 3 == 2 { t.setupColor(color: .green) }
        navigationController?.pushViewController(t, animated: true)
    }
    
    func setupColor(color: UIColor) {
        view.backgroundColor = color
    }
}
