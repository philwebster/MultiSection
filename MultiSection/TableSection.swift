import Realm
import UIKit

protocol TableSectionDelegate: class {
    func indexOfTableSection(_ section: TableSection) -> Int?
}

class TableSection: NSObject {
    
    var results: RLMResults<AnyObject>?
    var frozenResults: [RLMObject]?
    weak var table: UITableView?
    var sectionTitle: String?
    var showsHeaderWhenEmpty = true
    var cellClass: UITableViewCell.Type
    var cellReuseIdentifier: String
    weak var delegate: TableSectionDelegate?
    var changeToken: RLMNotificationToken?
    var selectedIndexPath: IndexPath?
    var selectedObjectIdentifier: String?
    
    init(results: RLMResults<AnyObject>?,
         tableView: UITableView,
         cellClass: UITableViewCell.Type = UITableViewCell.self,
         cellReuseIdentifier: String = "cell",
         sectionTitle: String? = nil) {

        self.results = results
        self.frozenResults = results?.allObjects
        self.table = tableView
        self.cellClass = cellClass
        self.cellReuseIdentifier = cellReuseIdentifier
        self.sectionTitle = sectionTitle
        self.table?.register(self.cellClass, forCellReuseIdentifier: self.cellReuseIdentifier)
        
        super.init()
        
        self.changeToken = self.results?.addNotificationBlock { [weak self] (results, change, error) in
            self?.handleChange(change, results: results)
        }
    }
    
    func handleChange(_ change: RLMCollectionChange?, results: RLMResults<AnyObject>?) {
        let sectionIndex = self.delegate?.indexOfTableSection(self) ?? 0
        let additions = change?.insertions.map { IndexPath(row: Int($0), section: sectionIndex) } ?? []
        let deletions = change?.deletions.map { IndexPath(row: Int($0), section: sectionIndex) } ?? []
        let modifications = change?.modifications.map { IndexPath(row: Int($0), section: sectionIndex) } ?? []

        self.table?.beginUpdates()
        self.frozenResults = results?.allObjects
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
        return Int(self.frozenResults?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
    }
}

extension TableSection: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.frozenResults?.count ?? 0 > 0 || self.showsHeaderWhenEmpty {
            return self.sectionTitle
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.frozenResults?.count ?? 0 > 0 || self.showsHeaderWhenEmpty {
            return UITableViewAutomaticDimension
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
}
