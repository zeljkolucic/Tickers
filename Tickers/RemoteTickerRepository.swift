//
//  RemoteTickerRepository.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Foundation

public final class RemoteTickerRepository {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() async throws {
        guard let response = try? await client.get(from: url) else {
            throw Error.connectivity
        }
        
        guard (200..<300).contains(response.statusCode) else {
            throw Error.invalidData
        }
    }
}
