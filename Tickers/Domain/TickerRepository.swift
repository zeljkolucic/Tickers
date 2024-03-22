//
//  TickerRepository.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Foundation

public protocol TickerRepository {
    func load() async throws -> [Ticker]
}
