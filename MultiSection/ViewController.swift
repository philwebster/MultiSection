import Realm
import UIKit

class ViewController: UIViewController {
    
    var realm: RLMRealm?
    let tableView = UITableView()
    var sectionCollection: TableSectionCollection?
    var customSection: CustomSection?
    
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Show custom", style: .plain, target: self, action: #selector(self.toggleCustomSection))

        let realm = RLMRealm.default()
        self.realm = realm
        
        let nameSort = RLMSortDescriptor(keyPath: "name", ascending: true)
        
        let ownedPredicate = "SELF.isOwned == TRUE"
        let ownedClasses = Group.allObjects(in: realm).objectsWhere(ownedPredicate, args: getVaList([])).sortedResults(using: [nameSort])
        let ownedClassesSection = GroupSection(results: ownedClasses,
                                               tableView: self.tableView,
                                               cellClass: UITableViewCell.self,
                                               cellReuseIdentifier: "ownedCell",
                                               sectionTitle: "Owned Classes")
        
        let addOwnedClassSection = AddButtonSection(tableView: self.tableView) { [weak self] in
            self?.showAddClassAlert(isOwned: true)
        }
        
        let joinedPredicate = "SELF.isOwned == FALSE && SELF.isOrganization == FALSE"
        let joinedClasses = Group.allObjects(in: realm).objectsWhere(joinedPredicate, args: getVaList([])).sortedResults(using: [nameSort])
        let joinedClassesSection = GroupSection(results: joinedClasses,
                                                tableView: self.tableView,
                                                cellClass: UITableViewCell.self,
                                                cellReuseIdentifier: "joinedCell",
                                                sectionTitle: "Joined Classes")
        
        let addJoinedClassSection = AddButtonSection(tableView: self.tableView) { [weak self] in
            self?.showAddClassAlert(isOwned: false)
        }
        
        let organizations = Group.allObjects(in: realm).objectsWhere("SELF.isOrganization == TRUE", args: getVaList([]))
        let organizationsSection = GroupSection(results: organizations,
                                                tableView: self.tableView,
                                                cellClass: UITableViewCell.self,
                                                cellReuseIdentifier: "orgCell",
                                                sectionTitle: "Schools")
        organizationsSection.showsHeaderWhenEmpty = false
        
        let favorites = Group.allObjects(in: realm).objectsWhere("SELF.isFavorite == TRUE", args: getVaList([ ]))
        let favoritesSection = FavoriteGroupsSection(results: favorites,
                                                     tableView: self.tableView,
                                                     cellClass: UITableViewCell.self,
                                                     cellReuseIdentifier: "favoriteCell",
                                                     sectionTitle: "Favorites")
        favoritesSection.showsHeaderWhenEmpty = false

        let sections = [
            ownedClassesSection,
            addOwnedClassSection,
            joinedClassesSection,
            addJoinedClassSection,
            organizationsSection,
            favoritesSection
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
        self.navigationItem.leftBarButtonItem?.title = self.customSection == nil ? "Show custom" : "Hide custom"
    }
}
