//
//  Transaction.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation 

struct Amount {
    let value: Int
    let currencyISO: String
}

struct Product {
    let id: Int
    let title: String
    let icon: URL
}

struct Transaction {
    let id: String
    let date: Date
    let description: String
    let category: String
    let currency: String
    let amount: Amount
    let product: Product
}
