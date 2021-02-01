//
//  TransactionsViewModel.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 01/02/21.
//

import Foundation 
import TransactionsEngine

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
