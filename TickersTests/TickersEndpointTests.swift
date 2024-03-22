//
//  TickersEndpointTests.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Tickers
import XCTest

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
