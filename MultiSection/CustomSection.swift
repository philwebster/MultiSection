import UIKit

class CustomColorCell: UITableViewCell {
    
    var messageLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.messageLabel.font = UIFont.systemFont(ofSize: 24)
        self.messageLabel.textAlignment = .center
        self.messageLabel.textColor = UIColor.white
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.messageLabel)
        NSLayoutConstraint.activate([
            self.messageLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.messageLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.messageLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.messageLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}

class CustomSection: TableSection {
    
    var color: UIColor
    var message: String?
    var isHidden: Bool = false
    
    init(color: UIColor, message: String?, tableView: UITableView) {
        self.color = color
        self.message = message
        super.init(results: nil, tableView: tableView, cellClass: CustomColorCell.self, cellReuseIdentifier: "colorCell", sectionTitle: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        guard let colorCell = cell as? CustomColorCell else {
            return cell
        }
        
        colorCell.contentView.backgroundColor = self.color
        colorCell.messageLabel.text = self.message
        
        return colorCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.isHidden ? 0 : 80
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
