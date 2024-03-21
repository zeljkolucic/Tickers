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
    
    func test_loadTwice_requestsDataFromURLTwice() async {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        
        try? await sut.load()
        try? await sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() async {
        let (sut, client) = makeSUT()
        client.result = .failure(anyError)
        
        do {
            try await sut.load()
            XCTFail("Expected to deliver error on client error")
        } catch let error as RemoteTickerRepository.Error {
            XCTAssertEqual(error, .connectivity)
        } catch {
            XCTFail("Expected to deliver connectivity error, got \(error) instead")
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() async {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        
        [199, 300, 400, 500].forEach { statusCode in
            let non200HTTPResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            client.result = .success((anyData, non200HTTPResponse))
            
            Task {
                do {
                    try await sut.load()
                    XCTFail("Expected to deliver error on non-200 HTTP response")
                } catch let error as RemoteTickerRepository.Error {
                    XCTAssertEqual(error, .invalidData)
                } catch {
                    XCTFail("Expected to deliver invalid data error, got \(error) instead")
                }
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        let invalidJSON = "invalid json".data(using: .utf8)!
        let responseWith200StatusCode = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client.result = .success((invalidJSON, responseWith200StatusCode))
        
        do {
            try await sut.load()
            XCTFail("Expected to deliver error on 200 HTTP response and invalid JSON")
        } catch let error as RemoteTickerRepository.Error {
            XCTAssertEqual(error, .invalidData)
        } catch {
            XCTFail("Expected to deliver invalid data error, got \(error) instead")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL) -> (sut: RemoteTickerRepository, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteTickerRepository(client: client, url: url)
        return (sut, client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var result: Result<(Data, HTTPURLResponse), Error>?
        
        func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
            requestedURLs.append(url)
            
            return switch result {
            case let .success(response):
                response
            case let .failure(error):
                throw error
            case .none:
                (anyData, anyHTTPURLResponse)
            }
        }
    }
}
