import UIKit

class CustomColorCell: UITableViewCell {
    
}

class CustomSection: TableSection {
    
    var color: UIColor
    var isHidden: Bool = false
    
    init(color: UIColor, tableView: UITableView) {
        self.color = color
        super.init(results: nil, tableView: tableView, cellClass: CustomColorCell.self, cellReuseIdentifier: "colorCell", sectionTitle: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        guard cell is CustomColorCell else {
            return cell
        }
        
        cell.contentView.backgroundColor = self.color
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.isHidden ? 0 : 80
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
