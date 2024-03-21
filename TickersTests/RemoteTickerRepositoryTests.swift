//
//  RemoteTickerRepositoryTests.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 21.3.24..
//

import XCTest

struct Ticker {
    
}

protocol HTTPClient {
    func get()
}

final class RemoteTickerRepository {
    
}

final class RemoteTickerRepositoryTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteTickerRepository()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    
    private final class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get() {}
    }
}
