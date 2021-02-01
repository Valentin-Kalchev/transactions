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
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    func loadImageData(from url: URL, completion: @escaping (TransactionImageLoader.Result) -> Void) {
        client.get(from: url) { (_) in
            completion(.failure(Error.connectivity))
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
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWith: failure(.connectivity)) {
            client.complete(with: anyError())
        }
    }
    
    private func failure(_ error: RemoteTransactionImageLoader.Error) -> TransactionImageLoader.Result {
        return .failure(error)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteTransactionImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteTransactionImageLoader(client: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(sut: RemoteTransactionImageLoader, toCompleteWith expectedResult: TransactionImageLoader.Result, when action: (() -> Void), file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load")
        sut.loadImageData(from: anyURL()) { (receivedResult) in
            switch (expectedResult, receivedResult) {
            case (let .failure(expectedError), let .failure(receivedError)):
                XCTAssertEqual(expectedError as NSError?, receivedError as NSError?, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
