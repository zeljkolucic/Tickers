//
//  Helpers.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Foundation

var anyURL: URL {
    URL(string: "https://any-url.com")!
}

var anyHTTPURLResponse: HTTPURLResponse {
    HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
}
