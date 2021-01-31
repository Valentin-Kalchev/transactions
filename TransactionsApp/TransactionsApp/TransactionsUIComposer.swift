//
//  TransactionsUIComposer.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit
import TransactionsEngine

final class TransactionsUIComposer {
    static func viewController(loader: TransactionsLoader) -> UINavigationController {
        let (navigationController, viewController) = TransactionsViewController.make()
        viewController.onViewDidLoad = {
            loader.load { [weak viewController] (result) in
                switch result {
                case let .success(transactions):
                    DispatchQueue.main.async {
                        viewController?.tableModel = transactions.map { TransactionCellController(viewModel: TransactionCellViewModel(transaction: $0)) }
                    }
                case let .failure(error):
                    print("Display error: \(error)")
                }
            }
        }
        return navigationController
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
