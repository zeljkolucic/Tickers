//
//  URLSessionHTTPClient.swift
//  Tickers
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Foundation

public final class URLSessionHTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(from: url)
        
        guard let response = response as? HTTPURLResponse else {
            throw UnexpectedValuesRepresentation()
        }
        
        return (data, response)
    }
}
