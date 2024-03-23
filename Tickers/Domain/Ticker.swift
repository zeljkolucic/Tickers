//
//  Ticker.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Foundation

public struct Ticker: Identifiable {
    public let symbol: Symbol
    public let lastPrice: Float
    public let dailyChangeRelative: Float
    
    public var id: String {
        symbol.name
    }
    
    var price: String {
        lastPrice.formatted(.currency(code: symbol.currencyCode))
    }
    
    var dailyChangePercentage: String {
        let formatter = NumberFormatter()
        formatter.positivePrefix = "+"
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        let numberToFormat = NSNumber(value: dailyChangeRelative)
        return formatter.string(from: numberToFormat) ?? String(dailyChangeRelative)
    }
    
    public init(symbol: Symbol, lastPrice: Float, dailyChangeRelative: Float) {
        self.symbol = symbol
        self.lastPrice = lastPrice
        self.dailyChangeRelative = dailyChangeRelative
    }
}
