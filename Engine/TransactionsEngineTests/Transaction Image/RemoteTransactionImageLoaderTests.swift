//
//  RemoteTransactionImageLoaderTests.swift
//  TransactionsEngineTests
//
//  Created by Valentin Kalchev (Zuant) on 01/02/21.
//

import XCTest
import TransactionsEngine

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
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        [199, 201, 300, 400, 500].enumerated().forEach { (index, code) in
            expect(sut: sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: Data(), at: index)
            }
        }
    }
    
    func test_load_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        expect(sut: sut, toCompleteWith: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteTransactionImageLoader? = RemoteTransactionImageLoader(client: client)
        
        var results = [TransactionImageLoader.Result]()
        sut?.loadImageData(from: anyURL(), completion: { (result) in
            results.append(result)
        })
        sut = nil
        client.complete(withStatusCode: 200, data: Data("non-empty data".utf8))
        XCTAssertTrue(results.isEmpty, "Instance delivers results after being deallocated")
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
            case (let .success(expectedData), let .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
                
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
    
    private func failure(_ error: RemoteTransactionImageLoader.Error) -> TransactionImageLoader.Result {
        return .failure(error)
    }
}
