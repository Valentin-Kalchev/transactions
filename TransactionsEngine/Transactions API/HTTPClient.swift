//
//  HTTPClient.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation
 
public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
