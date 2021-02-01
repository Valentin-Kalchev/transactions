//
//  TransactionsRefreshController.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 01/02/21.
//

import Foundation 

final class TransactionsRefreshController {
    private let viewModel: TransactionsViewModel
    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
    }
    
    func refresh() {
        viewModel.loadTransactions()
    }
}
