//
//  RemoteTickerRepository.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Foundation

public final class RemoteTickerRepository: TickerRepository {
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
    
    private struct RemoteTicker: Decodable {
        let symbol: Symbol
        let bid: Float
        let bidSize: Float
        let ask: Float
        let askSize: Float
        let dailyChange: Float
        let dailyChangeRelative: Float
        let lastPrice: Float
        let volume: Float
        let high: Float
        let low: Float
        
        init(from decoder: any Decoder) throws {
            var container = try decoder.unkeyedContainer()
            self.symbol = try container.decode(Symbol.self)
            self.bid = try container.decode(Float.self)
            self.bidSize = try container.decode(Float.self)
            self.ask = try container.decode(Float.self)
            self.askSize = try container.decode(Float.self)
            self.dailyChange = try container.decode(Float.self)
            self.dailyChangeRelative = try container.decode(Float.self)
            self.lastPrice = try container.decode(Float.self)
            self.volume = try container.decode(Float.self)
            self.high = try container.decode(Float.self)
            self.low = try container.decode(Float.self)
        }
        
        var ticker: Ticker {
            Ticker(symbol: symbol, lastPrice: lastPrice, dailyChangeRelative: dailyChangeRelative)
        }
    }
    
    public func load() async throws -> [Ticker] {
        guard let (data, response) = try? await client.get(from: url) else {
            throw Error.connectivity
        }
        
        guard (200..<300).contains(response.statusCode), let tickers = try? JSONDecoder().decode([RemoteTicker].self, from: data) else {
            throw Error.invalidData
        }
        
        return tickers.map { $0.ticker }
    }
}
