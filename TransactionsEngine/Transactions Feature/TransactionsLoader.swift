//
//  TransactionsLoader.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation

protocol TransactionsLoader {
    typealias Result = Swift.Result<[Transaction], Error>
    func load(completion: @escaping (Result) -> Void)
}
