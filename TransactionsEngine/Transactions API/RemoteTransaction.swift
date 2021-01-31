//
//  RemoteTransaction.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation

struct RemoteAmount: Decodable {
    let value: Int
    let currency_iso: String
}

struct RemoteProduct: Decodable {
    let id: Int
    let title: String
    let icon: String
}

struct RemoteTransaction: Decodable {
    let id: String
    let date: String
    let description: String
    let category: String
    let currency: String
    let amount: RemoteAmount
    let product: RemoteProduct
}
