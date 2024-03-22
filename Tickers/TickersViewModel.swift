//
//  TickersViewModel.swift
//  Tickers
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Foundation

public final class TickersViewModel {
    public var message: String?
    
    private let tickerRepository: TickerRepository
    
    public init(tickerRepository: TickerRepository) {
        self.tickerRepository = tickerRepository
    }
    
    public func load() async {
        do {
            _ = try await tickerRepository.load()
        } catch {
            message = "An error occurred. Please try again."
        }
    }
}
