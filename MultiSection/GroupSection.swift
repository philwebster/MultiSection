import Realm
import UIKit

class Group: RLMObject {
    @objc dynamic var name: String = ""
    @objc dynamic var isOwned: Bool = false
    @objc dynamic var isOrganization: Bool = false
}

class GroupSection: TableSection {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        guard let group = self.results?.object(at: UInt(indexPath.row)) as? Group else {
            return cell
        }
        cell.textLabel?.text = group.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let classToDelete = self.results?.object(at: UInt(indexPath.row)) as? Group {
            let title = classToDelete.isOwned ? "Delete" : "Leave"
            let action = UIContextualAction(style: .destructive, title: title, handler: { (action, sourceView, completionHandler) in
                self.results?.realm.beginWriteTransaction()
                classToDelete.realm?.delete(classToDelete)
                try? self.results?.realm.commitWriteTransactionWithoutNotifying([])
                completionHandler(true)
            })
            return UISwipeActionsConfiguration(actions: [action])
        }
        
        return nil
    }
}
