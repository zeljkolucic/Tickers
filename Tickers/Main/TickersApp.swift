//
//  TickersApp.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import SwiftUI

@main
struct TickersApp: App {
    @State private var selectedIndex = 0
    
    private let baseURL = URL(string: "https://api-pub.bitfinex.com")!
    private let timeInterval: TimeInterval = 1
    
    var body: some Scene {
        WindowGroup {
            let url = TickersEndpoint.get(Symbol.allCases.map { $0.rawValue }).url(from: baseURL)
            let viewModel = TickersViewModel(tickerRepository: RemoteTickerRepository(client: URLSessionHTTPClient(), url: url), timeInterval: timeInterval)
            TabView(selection: $selectedIndex) {
                TickersListView(viewModel: viewModel)
                    .tabItem {
                        Label(Localizable.TabBar.title.localized, systemImage: selectedIndex == 0 ? "chart.bar.fill" : "chart.bar")
                    }
            }
            .tint(.primaryGreen)
        }
    }
}
