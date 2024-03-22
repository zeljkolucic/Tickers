//
//  HTTPClientSpy.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Tickers
import Foundation

final class HTTPClientSpy: HTTPClient {
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
            (anyData(), anyHTTPURLResponse())
        }
    }
}
