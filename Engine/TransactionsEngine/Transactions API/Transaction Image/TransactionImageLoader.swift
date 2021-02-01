//
//  TransactionImageLoader.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 01/02/21.
//

import Foundation 

public protocol TransactionImageLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void)
}
