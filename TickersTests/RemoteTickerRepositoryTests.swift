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
        
        await expect(sut, toDeliver: .failure(.connectivity))
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() async {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        
        [199, 300, 400, 500].forEach { statusCode in
            let non200HTTPResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            client.result = .success((anyData, non200HTTPResponse))
            
            Task {
                await expect(sut, toDeliver: .failure(.invalidData))
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        let invalidJSON = "invalid json".data(using: .utf8)!
        let responseWith200StatusCode = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client.result = .success((invalidJSON, responseWith200StatusCode))
        
        await expect(sut, toDeliver: .failure(.invalidData))
    }
    
    // MARK: - Helpers
    
    private func expect(_ sut: RemoteTickerRepository, toDeliver expectedResult: Result<[Ticker], RemoteTickerRepository.Error>, file: StaticString = #filePath, line: UInt = #line) async {
        var receivedError: NSError?
        
        do {
            try await sut.load()
        } catch {
            receivedError = error as NSError
        }
        
        switch expectedResult {
        case .success:
            break
        case let .failure(error):
            XCTAssertEqual(receivedError, error as NSError, file: file, line: line)
        }
    }
    
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
