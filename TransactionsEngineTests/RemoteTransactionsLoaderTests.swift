//
//  RemoteTransactionsLoaderTests.swift
//  TransactionsEngineTests
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import XCTest

class HTTPClient {
    
}

class RemoteTransactionsLoader {
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
}

class RemoteTransactionsLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteTransactionsLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty, "Expected to not request data from url when created")
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
    }
}
