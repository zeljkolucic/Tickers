//
//  TickersEndpoint.swift
//  Tickers
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Foundation

public enum TickersEndpoint {
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
