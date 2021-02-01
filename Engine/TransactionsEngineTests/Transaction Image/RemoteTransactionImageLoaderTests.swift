//
//  RemoteTransactionImageLoaderTests.swift
//  TransactionsEngineTests
//
//  Created by Valentin Kalchev (Zuant) on 01/02/21.
//

import XCTest
import TransactionsEngine

class RemoteTransactionImageLoader {
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
}

protocol TransactionImageLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void)
}

class RemoteTransactionImageLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty, "Expected to not request data from url when created")
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteTransactionImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteTransactionImageLoader(client: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
}
