import Realm
import UIKit

class ViewController: UIViewController {
    
    var realm: RLMRealm?
    let tableView = UITableView()
    var sectionCollection: TableSectionCollection?
    var customSection: CustomSection?
    var selectionLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        self.tableView.tableFooterView = UIView()
        
        NSLayoutConstraint.activate([
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join school", style: .plain, target: self, action: #selector(self.joinSchoolTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add custom", style: .plain, target: self, action: #selector(self.toggleCustomSection))
        
        let addDataButton = UIButton(type: .system)
        addDataButton.addTarget(self, action: #selector(self.addDataTapped(sender:)), for: .touchUpInside)
        addDataButton.setTitle("Add Data", for: .normal)
        addDataButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(addDataButton)
        NSLayoutConstraint.activate([
            addDataButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -8),
            addDataButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8),
            ])

        let selectionLabel = UILabel()
        selectionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(selectionLabel)
        NSLayoutConstraint.activate([
            selectionLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 8),
            selectionLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8),
            ])
        self.selectionLabel = selectionLabel

        let realm = RLMRealm.default()
        self.realm = realm
        
        let nameSort = RLMSortDescriptor(keyPath: "name", ascending: true)
        
        let allClassesSection = AllClassesSection(results: nil, tableView: self.tableView)
        allClassesSection.allClassesSelectionDelegate = self
        
        let ownedPredicate = "SELF.isOwned == TRUE"
        let ownedClasses = Group.allObjects(in: realm).objectsWhere(ownedPredicate, args: getVaList([])).sortedResults(using: [nameSort])
        let ownedClassesSection = GroupSection(results: ownedClasses,
                                               tableView: self.tableView,
                                               cellClass: GroupCell.self,
                                               cellReuseIdentifier: "ownedCell",
                                               sectionTitle: "Owned Classes")
        ownedClassesSection.selectionDelegate = self
        
        let addOwnedClassSection = AddButtonSection(tableView: self.tableView) { [weak self] in
            self?.showAddClassAlert(isOwned: true)
        }
        
        let joinedPredicate = "SELF.isOwned == FALSE && SELF.isOrganization == FALSE"
        let joinedClasses = Group.allObjects(in: realm).objectsWhere(joinedPredicate, args: getVaList([])).sortedResults(using: [nameSort])
        let joinedClassesSection = GroupSection(results: joinedClasses,
                                                tableView: self.tableView,
                                                cellClass: GroupCell.self,
                                                cellReuseIdentifier: "joinedCell",
                                                sectionTitle: "Joined Classes")
        joinedClassesSection.selectionDelegate = self
        
        let addJoinedClassSection = AddButtonSection(tableView: self.tableView) { [weak self] in
            self?.showAddClassAlert(isOwned: false)
        }
        
        let organizations = Group.allObjects(in: realm).objectsWhere("SELF.isOrganization == TRUE", args: getVaList([]))
        let organizationsSection = GroupSection(results: organizations,
                                                tableView: self.tableView,
                                                cellClass: GroupCell.self,
                                                cellReuseIdentifier: "orgCell",
                                                sectionTitle: "Schools")
        organizationsSection.selectionDelegate = self
        organizationsSection.showsHeaderWhenEmpty = false
        
        let favorites = Group.allObjects(in: realm).objectsWhere("SELF.isFavorite == TRUE", args: getVaList([ ]))
        let favoritesSection = FavoriteGroupsSection(results: favorites,
                                                     tableView: self.tableView,
                                                     cellClass: GroupCell.self,
                                                     cellReuseIdentifier: "favoriteCell",
                                                     sectionTitle: "Favorites")
        favoritesSection.showsHeaderWhenEmpty = false

        let variedHeightSection = VariedHeightSection(results: nil,
                                                      tableView: self.tableView,
                                                      cellClass: UITableViewCell.self,
                                                      cellReuseIdentifier: "variedCell",
                                                      sectionTitle: "Varied Height Cells")

        let sections = [
            allClassesSection,
            ownedClassesSection,
            addOwnedClassSection,
            joinedClassesSection,
            addJoinedClassSection,
            organizationsSection,
            favoritesSection,
            variedHeightSection
        ]
        self.sectionCollection = TableSectionCollection(sections: sections, tableView: self.tableView)
        self.tableView.dataSource = self.sectionCollection
        self.tableView.delegate = self.sectionCollection
    }
    
    func showAddClassAlert(isOwned: Bool, isOrganization: Bool = false) {
        let title = isOrganization ? "Enter school name" : "Enter class name"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .`default`, handler: { [weak self] _ in
            let newGroup = Group()
            newGroup.name = alert.textFields?.first?.text ?? "No name"
            newGroup.isOwned = isOwned
            newGroup.isOrganization = isOrganization
            self?.realm?.beginWriteTransaction()
            self?.realm?.add(newGroup)
            try? self?.realm?.commitWriteTransactionWithoutNotifying([])
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func joinSchoolTapped() {
        self.showAddClassAlert(isOwned: false, isOrganization: true)
    }
    
    func toggleCustomSection() {
        if self.customSection == nil {
            let customSection = CustomSection(color: UIColor.red, message: "Reminder: Do your homework", tableView: self.tableView)
            self.customSection = customSection
            self.sectionCollection?.sections.insert(customSection, at: 0)
        }
        else {
            self.customSection = nil
            self.sectionCollection?.sections.remove(at: 0)
        }
        self.navigationItem.leftBarButtonItem?.title = self.customSection == nil ? "Add custom" : "Remove custom"
    }
    
    func addDataTapped(sender: UIButton) {
        if sender.title(for: .normal) == "Remove Data" {
            self.deleteAllObjects()
            sender.setTitle("Add Data", for: .normal)
            return
        }

        sender.setTitle("Remove Data", for: .normal)
        
        Thread {
            for _ in 0..<20 {
                self.addRandomGroup()
                usleep(250000)
            }
            }.start()
        
        Thread {
            for _ in 0..<20 {
                self.updateRandomGroup()
                usleep(250000)
            }
            }.start()
        
        Thread {
            for _ in 0..<10 {
                self.deleteRandomGroup()
                usleep(500000)
            }
            }.start()
    }
    
    func deleteAllObjects() {
        Thread {
            let realm = RLMRealm.default()
            realm.beginWriteTransaction()
            realm.deleteAllObjects()
            try? realm.commitWriteTransactionWithoutNotifying([])
        }.start()
    }
    
    func addRandomGroup() {
        let realm = RLMRealm.default()
        let newGroup = Group()
        newGroup.name = "\(String(describing: Calendar.current.dateComponents([.nanosecond], from: Date()).nanosecond!))"
        newGroup.isOwned = arc4random() % 2 == 0
        if !newGroup.isOwned {
            newGroup.isOrganization = arc4random() % 2 == 0
        }
        newGroup.isFavorite = arc4random() % 2 == 0
        newGroup.name = (newGroup.isOrganization ? "school " : "class ") + newGroup.name
        realm.beginWriteTransaction()
        realm.add(newGroup)
        try? realm.commitWriteTransactionWithoutNotifying([])
    }
    
    func updateRandomGroup() {
        let realm = RLMRealm.default()
        let groups = Group.allObjects()
        let randomIndex = UInt(arc4random_uniform(UInt32(groups.count)))
        realm.beginWriteTransaction()
        guard randomIndex < groups.count else {
            try? realm.commitWriteTransactionWithoutNotifying([])
            return
        }
        if let group = groups.object(at: randomIndex) as? Group, group.isInvalidated == false {
            group.isOrganization = arc4random() % 2 == 0
        }
        try? realm.commitWriteTransactionWithoutNotifying([])
    }
    
    func deleteRandomGroup() {
        let realm = RLMRealm.default()
        let groups = Group.allObjects()
        let randomIndex = UInt(arc4random_uniform(UInt32(groups.count)))
        realm.beginWriteTransaction()
        guard randomIndex < groups.count else {
            try? realm.commitWriteTransactionWithoutNotifying([])
            return
        }
        if let group = groups.object(at: randomIndex) as? Group, group.isInvalidated == false {
            realm.delete(group)
        }
        try? realm.commitWriteTransactionWithoutNotifying([])
    }
}

extension ViewController: AllClassesSelectionDelegate {
    
    func allClassesSectionWasSelected(_ allClassesSection: AllClassesSection) {
        self.selectionLabel?.text = "Selection: All Classes"
    }
}

extension ViewController: GroupSectionSelectionDelegate {
    
    func groupSection(_ groupSection: GroupSection, didSelect group: Group?) {
        
        self.selectionLabel?.text = "Selection: \(group?.name ?? "")"
    }
}
