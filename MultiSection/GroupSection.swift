import Realm
import UIKit

class GroupSection: TableSection {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        guard let group = self.visibleResults?[indexPath.row] as? Group, group.isInvalidated == false else {
            return cell
        }
        cell.textLabel?.text = group.name
        cell.accessoryType = group.isFavorite ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath), let group = self.visibleResults?[indexPath.row] as? Group else {
            return
        }
        self.results?.realm.beginWriteTransaction()
        group.isFavorite = cell.accessoryType == .checkmark ? false : true
        try? self.results?.realm.commitWriteTransactionWithoutNotifying([])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let classToDelete = self.visibleResults?[indexPath.row] as? Group {
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
