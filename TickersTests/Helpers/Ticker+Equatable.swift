//
//  Ticker+Equatable.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Tickers
import Foundation

extension Ticker: Equatable {
    public static func == (lhs: Ticker, rhs: Ticker) -> Bool {
        lhs.symbol == rhs.symbol && lhs.lastPrice == rhs.lastPrice && lhs.dailyChangeRelative == rhs.dailyChangeRelative
    }
}
