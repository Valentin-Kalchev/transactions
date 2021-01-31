//
//  RemoteTransactionsLoaderTests.swift
//  TransactionsEngineTests
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import XCTest
import TransactionsEngine


class RemoteTransactionsLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty, "Expected to not request data from url when created")
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load(completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load(completion: { _ in })
        sut.load(completion: { _ in })
        
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
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWith: .success([])) {
            client.complete(withStatusCode: 200, data: data(from: [:]))
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWith: .success([])) {
            client.complete(withStatusCode: 200, data: data(from: ["data":[]]))
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONData() {
        let (transaction, json) = makeTransaction()
        let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWith: .success([transaction])) {
            client.complete(withStatusCode: 200, data: data(from: ["data": [json]]))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteTransactionsLoader? = RemoteTransactionsLoader(url: anyURL(), client: client)
        
        var receivedResults = [TransactionsLoader.Result]()
         
        sut?.load(completion: { (result) in
            receivedResults.append(result)
        })
        sut = nil
        
        let (_, json) = makeTransaction()
        client.complete(withStatusCode: 200, data: data(from: ["data": [json]]))
        
        XCTAssertTrue(receivedResults.isEmpty, "Expected no result after sut is deallocated")
    }
    
    private func makeTransaction() -> (transaction: Transaction, json: [String: Any?]) {
        let transaction = Transaction(id: "id", date: "2018-03-19".date!,
                                      description: "description",
                                      category: "category",
                                      currency: "currency",
                                      amount: Amount(value: 123, currencyISO: "GBP"),
                                      product: Product(id: 123, title: "title", icon: URL(string: "http://product-url.com")!))
        
        let json: [String: Any?] = ["id": transaction.id,
                    "date": transaction.date.string,
                    "description": transaction.description,
                    "category": transaction.category,
                    "currency": transaction.currency,
                    "amount": [
                        "value": transaction.amount.value,
                        "currency_iso": transaction.amount.currencyISO
                    ],
                    "product": [
                        "id": transaction.product.id,
                        "title": transaction.product.title,
                        "icon": transaction.product.icon.absoluteString
                    ]]
        
        return (transaction, json)
    }
    
    private func expect(sut: RemoteTransactionsLoader, toCompleteWith expectedResult: TransactionsLoader.Result, when action: () -> (), file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load")
        
        sut.load { (receivedResult) in
            switch (expectedResult, receivedResult) {
            case (let .success(expectedResult), let .success(receivedResult)):
                XCTAssertEqual(expectedResult, receivedResult, file: file, line: line)
                
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
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteTransactionsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteTransactionsLoader(url: url, client: client)
        
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func data(from json: [String: Any?]) -> Data {
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteTransactionsLoader.Error) -> TransactionsLoader.Result {
        return .failure(error)
    }
}
