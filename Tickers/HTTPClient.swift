//
//  HTTPClient.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}
