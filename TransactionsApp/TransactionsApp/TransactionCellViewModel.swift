//
//  TransactionCellViewModel.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import UIKit
import TransactionsEngine
 
class TransactionCellViewModel {
    private let imageLoader: TransactionImageLoader
    private let transaction: Transaction
    
    init(imageLoader: TransactionImageLoader, transaction: Transaction) {
        self.imageLoader = imageLoader
        self.transaction = transaction
    }
    
    var description: String {
        return transaction.description
    }
    
    var category: String {
        return transaction.category
    }
    
    var cost: String {
        let value = transaction.amount.value
        switch transaction.amount.currencyISO {
        case "GBP":
            return "£\(value)"
        default:
            return "\(value)"
        }
    }
    
    var onImageLoad: ((UIImage?) -> Void)?
    func loadImage() {
        imageLoader.loadImageData(from: transaction.product.icon) { [weak self] (result) in
            switch result {
            case let .success(data):
                self?.onImageLoad?(UIImage(data: data))
                
            case .failure:
                self?.onImageLoad?(nil)
            }
        }
    }
}
