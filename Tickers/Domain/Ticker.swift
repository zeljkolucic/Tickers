//
//  Ticker.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Foundation

public struct Ticker {
    public let name: String
    public let lastPrice: Float
    public let dailyChangeRelative: Float
    
    var price: String {
        lastPrice.formatted(.currency(code: "USD"))
    }
    
    var dailyChangePercentage: String {
        let formatter = NumberFormatter()
        formatter.positivePrefix = "+"
        formatter.numberStyle = .percent
        let numberToFormat = NSNumber(value: dailyChangeRelative)
        return formatter.string(from: numberToFormat) ?? String(dailyChangeRelative)
    }
    
    public init(name: String, lastPrice: Float, dailyChangeRelative: Float) {
        self.name = name
        self.lastPrice = lastPrice
        self.dailyChangeRelative = dailyChangeRelative
    }
}
