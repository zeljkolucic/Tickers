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
    func get(from url: URL)
}

final class RemoteTickerRepository {
    private let client: HTTPClient
    private let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

final class RemoteTickerRepositoryTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT(url: URL(string: "https://a-given-url.com")!)
        
        sut.load()
        
        XCTAssertFalse(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteTickerRepository, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteTickerRepository(client: client, url: url)
        return (sut, client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL) {
            requestedURLs.append(url)
        }
    }
}
