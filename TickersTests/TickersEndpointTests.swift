//
//  TickersEndpointTests.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 22.3.24..
//

import XCTest

enum TickersEndpoint {
    case get([String])
    
    public func url(from baseURL: URL) -> URL {
        switch self {
        case let .get(symbols):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/v2/tickers"
            components.queryItems = [
                URLQueryItem(name: "symbols", value: symbols.joined(separator: ","))
            ].compactMap { $0 }
            return components.url!
        }
    }
}

final class TickersEndpointTests: XCTestCase {
    func test_get_deliversURLFromBaseURL() {
        let baseURL = URL(string: "https://base-url.com")!
        let symbols = ["tBTCUSD", "tETHUSD"]
        
        let receivedUrl = TickersEndpoint.get(symbols).url(from: baseURL)
        
        XCTAssertEqual(receivedUrl.scheme, "https")
        XCTAssertEqual(receivedUrl.host, "base-url.com")
        XCTAssertEqual(receivedUrl.path, "/v2/tickers")
        XCTAssertEqual(receivedUrl.query()?.contains("symbols=tBTCUSD,tETHUSD"), true)
    }
}
