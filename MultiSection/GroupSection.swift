import Realm
import UIKit

protocol GroupCellDelegate: class {
    func groupCell(_ cell: GroupCell, tappedFavorite: Bool)
}

class GroupCell: UITableViewCell {
    
    var favoriteButton = UIButton(type: .system)
    weak var delegate: GroupCellDelegate?
    var lockSelection = false

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
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if self.lockSelection {
            return
        }
        super.setHighlighted(highlighted, animated: animated)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if self.lockSelection {
            return
        }
        super.setSelected(selected, animated: animated)
    }
}

protocol GroupSectionSelectionDelegate: class {
    func groupSection(_ groupSection: GroupSection, didSelect group: Group?)
}

class GroupSection: TableSection {

    weak var selectionDelegate: GroupSectionSelectionDelegate?

    convenience init(results: RLMResults<AnyObject>?, tableView: UITableView, sectionTitle: String?) {
        self.init(results: results,
                  tableView: tableView,
                  cellClass: GroupCell.self,
                  cellReuseIdentifier: "groupCell",
                  sectionTitle: sectionTitle)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let group = self.frozenResults?[indexPath.row] as? Group else {
            return
        }

        self.selectedObjectIdentifier = group.uuid
        self.selectionDelegate?.groupSection(self, didSelect: group)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedObjectIdentifier = nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        guard let group = self.frozenResults?[indexPath.row] as? Group, group.isInvalidated == false,
            let cell = c as? GroupCell else {
            return c
        }
        cell.textLabel?.text = group.name
        cell.setFavorited(favorited: group.isFavorite)
        cell.lockSelection = false
        cell.delegate = self
        
        if group.uuid == self.selectedObjectIdentifier {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let visibleIndexPathsInThisSection = self.table?.indexPathsForVisibleRows?.filter { (indexPath) -> Bool in
            return indexPath.section == self.delegate?.indexOfTableSection(self)
        }
        visibleIndexPathsInThisSection?.forEach { (indexPath) in
            guard let cell = tableView.cellForRow(at: indexPath) as? GroupCell else {
                return
            }
            cell.lockSelection = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tableView.visibleCells.forEach { (cell) in
            guard let cell = cell as? GroupCell else {
                return
            }
            cell.lockSelection = false
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let classToDelete = self.frozenResults?[indexPath.row] as? Group {
            if classToDelete.uuid == self.selectedObjectIdentifier {
                self.selectedObjectIdentifier = nil
            }
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
