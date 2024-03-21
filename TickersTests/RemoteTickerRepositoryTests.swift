//
//  RemoteTickerRepositoryTests.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Tickers
import XCTest

final class RemoteTickerRepositoryTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        do {
            try sut.load()
            try sut.load()
        } catch {
            XCTFail("Expected success, got error instead")
        }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = NSError(domain: "any error", code: 0)
        client.error = error
        
        do {
            try sut.load()
            XCTFail("Expected to deliver error on client error")
        } catch let error as RemoteTickerRepository.Error {
            XCTAssertEqual(error, .connectivity)
        } catch {
            XCTFail("Expected to deliver connectivity error, got \(error) instead")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteTickerRepository, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteTickerRepository(client: client, url: url)
        return (sut, client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL) throws {
            requestedURLs.append(url)
            if let error {
                throw error
            }
        }
    }
}
