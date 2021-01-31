//
//  Transaction.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation 

public struct Amount: Equatable {
    public let value: Int
    public let currencyISO: String
    
    public init(value: Int, currencyISO: String) {
        self.value = value
        self.currencyISO = currencyISO
    }
}

public struct Product: Equatable {
    public let id: Int
    public let title: String
    public let icon: URL
    
    public init(id: Int, title: String, icon: URL) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}

public struct Transaction: Equatable {
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
