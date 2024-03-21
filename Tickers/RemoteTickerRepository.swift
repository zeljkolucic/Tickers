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
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
