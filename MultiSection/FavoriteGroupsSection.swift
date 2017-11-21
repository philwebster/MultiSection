import Realm
import UIKit

class FavoriteGroupsSection: TableSection {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.visibleResults?.count == 0 ? 0 : 44
    }
        
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.visibleResults?.count == 0 {
            return nil
        }

        let bigLabel = UILabel()
        bigLabel.textAlignment = .center
        bigLabel.text = "⭐️ Favorites ⭐️"
        bigLabel.font = UIFont.systemFont(ofSize: 16)
        bigLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bigLabel.backgroundColor = UIColor(displayP3Red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        return bigLabel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        guard let group = self.visibleResults?[indexPath.row] as? Group, group.isInvalidated == false else {
            return cell
        }
        cell.textLabel?.text = group.name
        cell.accessoryType = .checkmark
        return cell
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
