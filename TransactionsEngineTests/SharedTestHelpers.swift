//
//  SharedTestHelpers.swift
//  TransactionsEngineTests
//
//  Created by Valentin Kalchev (Zuant) on 31/01/21.
//

import XCTest
 
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
