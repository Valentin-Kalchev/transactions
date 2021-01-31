//
//  TransactionCellViewModel.swift
//  TransactionsApp
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation
import TransactionsEngine
 
class TransactionCellViewModel {
    private let transaction: Transaction
    init(transaction: Transaction) {
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
}
