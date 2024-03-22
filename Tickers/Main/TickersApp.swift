//
//  TickersApp.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import SwiftUI

@main
struct TickersApp: App {
    private let baseURL = URL(string: "https://api-pub.bitfinex.com")!
    private let timeInterval: TimeInterval = 5
    
    var body: some Scene {
        WindowGroup {
            let url = TickersEndpoint.get(Symbol.allCases.map { $0.rawValue }).url(from: baseURL)
            let viewModel = TickersViewModel(tickerRepository: RemoteTickerRepository(client: URLSessionHTTPClient(), url: url), timeInterval: timeInterval)
            ContentView()
        }
    }
}
