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
    
    func loadImageData(from url: URL, completion: @escaping (TransactionImageLoader.Result) -> Void) {
        client.get(from: url) { (_) in
            
        }
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
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT()
        sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT()
        sut.loadImageData(from: url, completion: { _ in })
        sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteTransactionImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteTransactionImageLoader(client: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
}
