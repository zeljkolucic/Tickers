//
//  TickersListView.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import SwiftUI

struct TickersListView: View {
    @ObservedObject var viewModel: TickersViewModel
    
    init(viewModel: TickersViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            tickers
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.large)
        }
        .task {
            viewModel.loadAtTimeIntervals()
        }
    }
    
    @ViewBuilder
    private var tickers: some View {
        List {
            ForEach(viewModel.tickers) { ticker in
                TickerView(ticker: ticker)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        
    }
}

#Preview {
    class TickerRepositoryStub: TickerRepository {
        func load() async throws -> [Ticker] {
            return [
                Ticker(symbol: .tBTCUSD, lastPrice: 64714, dailyChangeRelative: 0.04482591),
                Ticker(symbol: .tETHUSD, lastPrice: 3315.5, dailyChangeRelative: -0.06389407)
            ]
        }
    }
    
    return TickersListView(viewModel: TickersViewModel(tickerRepository: TickerRepositoryStub(), timeInterval: 5))
}
