//
//  TransactionCellController.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit

class TransactionCellController {
    private let viewModel: TransactionCellViewModel
    init(viewModel: TransactionCellViewModel) {
        self.viewModel = viewModel
    }
    
    func view(for tableView: UITableView) -> TransactionTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
        cell.descriptionLabel.text = viewModel.description
        cell.categoryLabel.text = viewModel.category
        cell.costLabel.text = viewModel.cost
        return cell
    }
}
