import UIKit

protocol AllClassesSelectionDelegate: class {
    func allClassesSectionWasSelected(_ allClassesSection: AllClassesSection)
}

class AllClassesSection: TableSection {
    
    weak var allClassesSelectionDelegate: AllClassesSelectionDelegate?
    
    required init(tableView: UITableView) {
        super.init(results: nil, tableView: tableView, cellReuseIdentifier: "allClassesCell")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.allClassesSelectionDelegate?.allClassesSectionWasSelected(self)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = "All Classes"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
