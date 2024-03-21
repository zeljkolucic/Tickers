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
        
        _ = try? await sut.load()
        _ = try? await sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() async {
        let (sut, client) = makeSUT()
        client.stub(.failure(anyError))
        
        await expect(sut, toDeliver: .failure(.connectivity))
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() async {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        
        [199, 300, 400, 500].forEach { statusCode in
            let non200HTTPResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            client.stub(.success((anyData, non200HTTPResponse)))
            
            Task {
                await expect(sut, toDeliver: .failure(.invalidData))
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        let invalidJSON = Data("invalid json".utf8)
        let responseWith200StatusCode = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client.stub(.success((invalidJSON, responseWith200StatusCode)))
        
        await expect(sut, toDeliver: .failure(.invalidData))
    }
    
    func test_load_deliversNoTickersOn200HTTPResponseWithEmptyJSON() async {
        let url = anyURL
        let (sut, client) = makeSUT()
        let emptyJSON = Data("[]".utf8)
        let responseWith200StatusCode = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client.stub(.success((emptyJSON, responseWith200StatusCode)))
        
        await expect(sut, toDeliver: .success([]))
    }
    
    func test_load_deliversTickersOn200HTTPResponseWithValidJSON() async {
        let url = anyURL
        let (sut, client) = makeSUT()
        
        let ticker0 = makeTicker(
            symbol: .init(rawValue: "tBTCUSD")!,
            bid: 64714,
            bidSize: 25.78401731,
            ask: 64715,
            askSize: 6.89066008,
            dailyChange: -3037,
            dailyChangeRelative: -0.04482591,
            lastPrice: 64714,
            volume: 5876.96541021,
            high: 68168,
            low: 62527
        )
        
        let ticker1 = makeTicker(
            symbol: .init(rawValue: "tLTCUSD")!,
            bid: 81.345,
            bidSize: 795.74956821,
            ask: 81.42,
            askSize: 1216.31224574,
            dailyChange: -1.709,
            dailyChangeRelative: -0.0205688,
            lastPrice: 81.378,
            volume: 14006.97524145,
            high: 88,
            low: 77.927
        )
        
        let tickers = [ticker0.model, ticker1.model]
        let validJSON = try! JSONSerialization.data(withJSONObject: [ticker0.json, ticker1.json])
        let responseWith200StatusCode = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client.stub(.success((validJSON, responseWith200StatusCode)))
        
        await expect(sut, toDeliver: .success(tickers))
    }
    
    // MARK: - Helpers
    
    private func expect(_ sut: RemoteTickerRepository, toDeliver expectedResult: Result<[Ticker], RemoteTickerRepository.Error>, file: StaticString = #filePath, line: UInt = #line) async {
        var retrievedResult: Result<[Ticker], NSError>?
        
        do {
            let retrievedTickers = try await sut.load()
            retrievedResult = .success(retrievedTickers)
        } catch {
            retrievedResult = .failure(error as NSError)
        }
        
        switch (retrievedResult, expectedResult) {
        case let (.success(retrievedTickers), .success(expectedTickers)):
            XCTAssertEqual(retrievedTickers, expectedTickers, file: file, line: line)
        case let (.failure(retrievedError), .failure(expectedError)):
            XCTAssertEqual(retrievedError, expectedError as NSError, file: file, line: line)
        default:
            XCTFail("Expected to retrieve \(expectedResult), got \(String(describing: retrievedResult)) instead", file: file, line: line)
        }
    }
    
    private func makeTicker(
        symbol: Symbol,
        bid: Float,
        bidSize: Float,
        ask: Float,
        askSize: Float,
        dailyChange: Float,
        dailyChangeRelative: Float,
        lastPrice: Float,
        volume: Float,
        high: Float,
        low: Float
    ) -> (model: Ticker, json: [Any]) {
        let model = Ticker(name: symbol.name, lastPrice: lastPrice, dailyChangeRelative: dailyChangeRelative)
        let json: [Any] = [symbol.rawValue, bid, bidSize, ask, askSize, dailyChange, dailyChangeRelative, lastPrice, volume, high, low]
        return (model, json)
    }
    
    private func makeSUT(url: URL = anyURL, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteTickerRepository, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteTickerRepository(client: client, url: url)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private final class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        private var result: Result<(Data, HTTPURLResponse), Error>?
        
        func stub(_ result: Result<(Data, HTTPURLResponse), Error>) {
            self.result = result
        }
        
        func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
            requestedURLs.append(url)
            
            return switch result {
            case let .success((data, response)):
                (data, response)
            case let .failure(error):
                throw error
            case .none:
                (anyData, anyHTTPURLResponse)
            }
        }
    }
}

extension Ticker: Equatable {
    public static func == (lhs: Ticker, rhs: Ticker) -> Bool {
        lhs.name == rhs.name && lhs.lastPrice == rhs.lastPrice && lhs.dailyChangeRelative == rhs.dailyChangeRelative
    }
}
