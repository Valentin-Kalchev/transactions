//
//  RemoteTransactionImageLoader.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 01/02/21.
//

import Foundation

public class RemoteTransactionImageLoader: TransactionImageLoader {
    private let client: HTTPClient
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func loadImageData(from url: URL, completion: @escaping (TransactionImageLoader.Result) -> Void) {
        client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                } else {
                    completion(.success(data))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
