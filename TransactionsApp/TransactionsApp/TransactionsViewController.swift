//
//  TransactionsViewController.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit

class TransactionCellController {
    func view(for tableView: UITableView) -> TransactionTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
        cell.descriptionLabel.text = "description here"
        cell.categoryLabel.text = "category here"
        cell.costLabel.text = "cost here"
        return cell
    }
}

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var transactionImageView: UIImageView!
    @IBOutlet var costLabel: UILabel!
}

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var removeButton: UIButton!
    
    var tableModel: [TransactionCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableModel.append(TransactionCellController())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.row].view(for: tableView)
    }
}

