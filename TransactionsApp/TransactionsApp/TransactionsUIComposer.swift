//
//  TransactionsUIComposer.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit
import TransactionsEngine

final class TransactionsUIComposer {
    static func rootViewController(loader: TransactionsLoader) -> UINavigationController {
        let (navigationController, viewController) = TransactionsViewController.make()
        
        let viewModel = TransactionsViewModel(loader: loader)
        viewController.refreshController = TransactionsRefreshController(viewModel: viewModel)
        
        viewModel.onFeedLoad = { [weak viewController] (transactions) in
            DispatchQueue.main.async {
                viewController?.tableModel = transactions.map { TransactionCellController(viewModel: TransactionCellViewModel(transaction: $0)) }
                viewController?.tableView.reloadData()
            }
        }
        
        return navigationController
    }
}

final class TransactionsRefreshController {
    private let viewModel: TransactionsViewModel
    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
    }
    
    func refresh() {
        viewModel.loadTransactions()
    }
}

final class TransactionsViewModel {
    private let loader: TransactionsLoader
    init(loader: TransactionsLoader) {
        self.loader = loader
    }
    
    typealias Observer<T> = ((T) -> Void)
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[Transaction]>?
    
    func loadTransactions() {
        onLoadingStateChange?(true)
        loader.load { [weak self] (result) in
            if let transactions = try? result.get() {
                self?.onFeedLoad?(transactions)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}

private extension TransactionsViewController {
    static func make() -> (UINavigationController, TransactionsViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: TransactionsViewController.self))
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let viewController = navigationController.viewControllers.first as! TransactionsViewController
        return (navigationController, viewController)
    }
}
