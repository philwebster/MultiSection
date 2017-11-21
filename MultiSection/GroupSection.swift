import Realm
import UIKit

protocol GroupCellDelegate: class {
    func groupCell(_ cell: GroupCell, tappedFavorite: Bool)
}

class GroupCell: UITableViewCell {
    
    var favoriteButton = UIButton(type: .system)
    weak var delegate: GroupCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryView = self.favoriteButton
        self.favoriteButton.addTarget(self, action: #selector(self.tappedFavorite(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFavorited(favorited: Bool) {
        self.favoriteButton.setTitle(favorited ? "⭐️" : "☆", for: .normal)
        self.favoriteButton.sizeToFit()
    }
    
    func tappedFavorite(_ sender: UIButton) {
        let favorite = sender.title(for: .normal) == "☆"
        self.delegate?.groupCell(self, tappedFavorite: favorite)
    }
}

protocol GroupSectionSelectionDelegate: class {
    func groupSection(_ groupSection: GroupSection, didSelect group: Group?)
}

class GroupSection: TableSection {
    
    weak var selectionDelegate: GroupSectionSelectionDelegate?
    var selectedIndexPath: IndexPath?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let group = self.frozenResults?[indexPath.row] as? Group else {
            return
        }
        self.selectedIndexPath = indexPath
        self.selectionDelegate?.groupSection(self, didSelect: group)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = nil
        self.selectionDelegate?.groupSection(self, didSelect: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        guard let group = self.frozenResults?[indexPath.row] as? Group, group.isInvalidated == false,
            let cell = c as? GroupCell else {
            return c
        }
        cell.textLabel?.text = group.name
        cell.setFavorited(favorited: group.isFavorite)
        cell.delegate = self
        
        if (indexPath == self.selectedIndexPath) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let classToDelete = self.frozenResults?[indexPath.row] as? Group {
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

extension GroupSection: GroupCellDelegate {
    func groupCell(_ cell: GroupCell, tappedFavorite: Bool) {
        guard let indexPath = self.table?.indexPath(for: cell),
            let group = self.frozenResults?[indexPath.row] as? Group,
            group.isInvalidated == false else {
            return
        }
        self.results?.realm.beginWriteTransaction()
        group.isFavorite = tappedFavorite
        try? self.results?.realm.commitWriteTransactionWithoutNotifying([])
    }
}
