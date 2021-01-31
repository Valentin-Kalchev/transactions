//
//  RemoteItemsMapper.swift
//  TransactionsEngine
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import Foundation
 
final class RemoteItemsMapper {
    struct Root: Decodable {
        let data: [RemoteTransaction]?
    }
    
    private static var OK_200: Int { return 200 }
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteTransaction] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteTransactionsLoader.Error.invalidData
        }
        
        return root.data ?? []
    }
}
