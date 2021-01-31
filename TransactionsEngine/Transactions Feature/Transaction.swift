//
//  Transaction.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation 

public struct Amount {
    public let value: Int
    public let currencyISO: String
}

public struct Product {
    public let id: Int
    public let title: String
    public let icon: URL
}

public struct Transaction {
    public let id: String
    public let date: Date
    public let description: String
    public let category: String
    public let currency: String
    public let amount: Amount
    public let product: Product
    
    public init(id: String, date: Date, description: String, category: String, currency: String, amount: Amount, product: Product) {
        self.id = id
        self.date = date
        self.description = description
        self.category = category
        self.currency = currency
        self.amount = amount
        self.product = product
    }
}
