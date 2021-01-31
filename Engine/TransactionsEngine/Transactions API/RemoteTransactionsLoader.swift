//
//  RemoteTransactionsLoader.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation

public class RemoteTransactionsLoader: TransactionsLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (TransactionsLoader.Result) -> Void) {
        self.client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                do {
                    let remoteTransactions = try RemoteItemsMapper.map(data, from: response)
                    completion(.success(remoteTransactions.toModel()))
                
                } catch {
                    completion(.failure(Error.invalidData))
                }
                
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private extension Array where Element == RemoteTransaction {
    func toModel() -> [Transaction] {
        return self.map { Transaction(id: $0.id,
                                      date: $0.date.date!,
                                      description: $0.description,
                                      category: $0.category,
                                      currency: $0.currency,
                                      amount: Amount(value: $0.amount.value,
                                                     currencyISO: $0.amount.currency_iso),
                                      
                                      product: Product(id: $0.product.id,
                                                       title: $0.product.title,
                                                       icon: URL(string: $0.product.icon)!))
        }
    }
}
