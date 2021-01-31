//
//  TransactionsViewController.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var removeButton: UIButton!
    
    var tableModel: [TransactionCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var onViewDidLoad: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.row].view(for: tableView)
    }
}

