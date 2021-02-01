//
//  TransactionTableViewCell.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit
 
class TransactionTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var transactionImageView: UIImageView!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var highlightView: UIView! 
}
