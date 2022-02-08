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
    
    private lazy var closeButton: UIButton = {
        $0.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .close))
    
    private lazy var navbar: UIView = {
//        $0.backgroundColor = .systemBlue.withAlphaComponent(0.8)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var container: UIView = {
        $0.frame = view.frame
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        $0.layer.cornerRadius = 11
        $0.clipsToBounds = true
        
        let blur: UIVisualEffectView = {
            $0.frame = view.bounds
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return $0
        }(UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)))
        
        
        $0.insertSubview(blur, at: 0)
        return $0
    }(UIView())
    
    private lazy var tableView: UITableView = {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UITableView())
    
    @objc
    func close(_ sender: UIButton?) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        view.addSubview(container)
        
        container.addSubview(tableView)
        container.addSubview(navbar)
        navbar.addSubview(closeButton)
        
        
        additionalSafeAreaInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: container.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            navbar.heightAnchor.constraint(equalToConstant: 50),
            navbar.topAnchor.constraint(equalTo: container.topAnchor),
            navbar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            navbar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: navbar.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: navbar.trailingAnchor, constant: -20)
        ])
        
        tableView.reloadData()
        

        view.layer.shadowRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = RootBottomSheetViewController.Constants.shadowOpacity
       
        
        view.backgroundColor = .clear

        
//        view.alpha = 0.5
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
        
        t.setupColor(color: indexPath.row % 2 == 0 ? .systemBlue : .systemGreen)
        navigationController?.pushViewController(t, animated: true)
    }
    
    func setupColor(color: UIColor) {
        view.backgroundColor = .clear
    }
}
