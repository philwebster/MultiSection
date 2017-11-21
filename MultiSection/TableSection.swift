import Realm
import UIKit

protocol TableSectionDelegate: class {
    func indexOfTableSection(_ section: TableSection) -> Int?
}

class TableSection: NSObject {
    
    var results: RLMResults<AnyObject>?
    weak var table: UITableView?
    var sectionTitle: String?
    var showsHeaderWhenEmpty = true
    var cellClass: UITableViewCell.Type
    var cellReuseIdentifier: String
    weak var delegate: TableSectionDelegate?
    var changeToken: RLMNotificationToken?
    
    init(results: RLMResults<AnyObject>?, tableView: UITableView, cellClass: UITableViewCell.Type = UITableViewCell.self, cellReuseIdentifier: String = "cell", sectionTitle: String? = nil) {
        self.results = results
        self.table = tableView
        self.cellClass = cellClass
        self.cellReuseIdentifier = cellReuseIdentifier
        self.sectionTitle = sectionTitle
        self.table?.register(self.cellClass, forCellReuseIdentifier: self.cellReuseIdentifier)
        
        super.init()
        
        self.changeToken = self.results?.addNotificationBlock { [weak self] (results, change, error) in
            self?.results = results
            if let change = change {
                self?.handleChange(change)
            }
        }
    }
    
    func handleChange(_ change: RLMCollectionChange) {
        let sectionIndex = self.delegate?.indexOfTableSection(self) ?? 0
        let additions = change.insertions.map { IndexPath(row: Int($0), section: sectionIndex) }
        let deletions = change.deletions.map { IndexPath(row: Int($0), section: sectionIndex) }
        let modifications = change.modifications.map { IndexPath(row: Int($0), section: sectionIndex) }
        
        self.table?.beginUpdates()
        self.table?.insertRows(at: additions, with: .automatic)
        self.table?.deleteRows(at: deletions, with: .automatic)
        self.table?.reloadRows(at: modifications, with: .automatic)
        self.table?.endUpdates()
    }
}

extension TableSection: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(self.results?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
    }
}

extension TableSection: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.results?.count ?? 0 > 0 || self.showsHeaderWhenEmpty {
            return self.sectionTitle
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.results?.count ?? 0 > 0 || self.showsHeaderWhenEmpty {
            return UITableViewAutomaticDimension
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
}
