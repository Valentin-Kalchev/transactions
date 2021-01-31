//
//  TransactionsAPIEndToEndTests.swift
//  TransactionsAPIEndToEndTests
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import XCTest
import TransactionsEngine

class TransactionsAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTEstServerGETTransactions_matchFixedTestAcountData() {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let url = URL(string: "http://www.mocky.io/v2/5b36325b340000f60cf88903")!
        let loader = RemoteTransactionsLoader(url: url, client: client)
        loader.load { (result) in
            switch result {
            case let .success(transactions):
                XCTAssertEqual(transactions.first, self.firstTransaction)
                // Compare response from the server, assuming that url won't return different array and only testing first item as an example 
            default:
                XCTFail("Expected different transcations")
            }
        }
    }
    
    private var firstTransaction: Transaction {
        return Transaction(id: "13acb877dc4d8030c5dacbde33d3496a2ae3asdc000db4c793bda9c3228baca1a28",
                            date: "2018-03-19".date!,
                            description: "Forbidden planet",
                            category: "General",
                            currency: "GBP",
                            amount: Amount(value: 13, currencyISO: "GBP"),
                            product: Product(id: 4279, title: "Lloyds Bank", icon: URL(string:"https://storage.googleapis.com/budcraftstorage/uploads/products/lloyds-bank/Llyods_Favicon-1_161201_091641.jpg")!))
    }
}
