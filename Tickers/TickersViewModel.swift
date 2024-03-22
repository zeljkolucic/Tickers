//
//  TickersViewModel.swift
//  Tickers
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Foundation

public final class TickersViewModel {
    public var message: String?
    public var tickers = [Ticker]()
    
    private let tickerRepository: TickerRepository
    
    public init(tickerRepository: TickerRepository) {
        self.tickerRepository = tickerRepository
    }
    
    public func load() async {
        do {
            tickers = try await tickerRepository.load()
        } catch {
            message = Localizable.Error.message.localized
        }
    }
}
