//
//  RemoteTransactionsLoaderTests.swift
//  TransactionsEngineTests
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import XCTest
import TransactionsEngine

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

struct RemoteAmount: Decodable {
    let value: Int
    let currency_iso: String
}

struct RemoteProduct: Decodable {
    let id: Int
    let title: String
    let icon: String
}

struct RemoteTransaction: Decodable {
    let id: String
    let date: String
    let description: String
    let category: String
    let currency: String
    let amount: RemoteAmount
    let product: RemoteProduct
}

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

class RemoteTransactionsLoader: TransactionsLoader {
    private let client: HTTPClient
    private let url: URL
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (TransactionsLoader.Result) -> Void) {
        self.client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                do {
                    let remoteTransactions = try RemoteItemsMapper.map(data, from: response)
                    completion(.success(remoteTransactions.toModel()))
                
                } catch {
                    completion(.failure(Error.invalidData))
                }
                
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private extension Array where Element == RemoteTransaction {
    func toModel() -> [Transaction] {
        return self.map { Transaction(id: $0.id,
                                      date: $0.date.date!,
                                      description: $0.description,
                                      category: $0.category,
                                      currency: $0.currency,
                                      amount: Amount(value: $0.amount.value,
                                                     currencyISO: $0.amount.currency_iso),
                                      
                                      product: Product(id: $0.product.id,
                                                       title: $0.product.title,
                                                       icon: URL(string: $0.product.icon)!))
        }
    }
}


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
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
    
    private func data(from json: [String: Any?]) -> Data {
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteTransactionsLoader.Error) -> TransactionsLoader.Result {
        return .failure(error)
    }
}

extension XCTestCase {
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Expected instance to be deallocated", file: file, line: line)
        }
    }
    
    func anyError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
