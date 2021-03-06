import UIKit

class TableSectionCollection: TableSection {
    
    var sections: [TableSection] {
        didSet {
            self.setSectionDelegates()
            self.table?.reloadData()
        }
    }
    
    init(sections: [TableSection], tableView: UITableView) {
        self.sections = sections
        super.init(results: nil, tableView: tableView)
        self.setSectionDelegates()
    }
    
    func setSectionDelegates() {
        self.sections.forEach { $0.delegate = self }
    }
}

extension TableSectionCollection: TableSectionDelegate {
    
    func indexOfTableSection(_ section: TableSection) -> Int? {
        return self.sections.index(of: section)
    }
}

extension TableSectionCollection {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].tableView(tableView, cellForRowAt: indexPath)
    }
}

extension TableSectionCollection {
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return self.sections[indexPath.section].tableView(tableView, shouldHighlightRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return self.sections[indexPath.section].tableView(tableView, willSelectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.sections[indexPath.section].tableView(tableView, didSelectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return self.sections[indexPath.section].tableView(tableView, willDeselectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.sections[indexPath.section].tableView(tableView, didDeselectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.sections[indexPath.section].tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.sections[indexPath.section].tableView(tableView, estimatedHeightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        return self.sections[indexPath.section].tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.sections[section].tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.sections[section].tableView(tableView, viewForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return self.sections[indexPath.section].tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.sections[indexPath.section].tableView(tableView, canEditRowAt:indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.sections.forEach { $0.tableView(tableView, willBeginEditingRowAt: indexPath) }
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        let selection = self.sections.flatMap { $0.selectedIndexPath }.first
        self.table?.selectRow(at: selection, animated: false, scrollPosition: .none)
        self.sections.forEach { $0.tableView(tableView, didEndEditingRowAt: indexPath) }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.sections[indexPath.section].tableView(tableView, commit: editingStyle, forRowAt: indexPath)
    }
}
