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
            ZStack {
                VStack {
                    message
                    tickers
                }
                if viewModel.isLoading {
                    ZStack {
                        Color.primaryBackground.opacity(0.2)
                            .ignoresSafeArea()
                        ProgressView()
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.large)
            .background(Color.primaryBackground)
            .searchable(text: $viewModel.searchTerm)
            .refreshable {
                viewModel.startLoading()
            }
        }
    }
    
    @ViewBuilder
    private var message: some View {
        if let message = viewModel.message {
            Label(message, systemImage: "wifi.exclamationmark")
                .foregroundStyle(.red)
        }
    }
    
    @ViewBuilder
    private var tickers: some View {
        List {
            ForEach(viewModel.filteredTickers) { ticker in
                TickerView(ticker: ticker)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.primaryBackground)
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
    
    return TickersListView(viewModel: TickersViewModel(reachability: Reachability(), tickerRepository: TickerRepositoryStub(), timeInterval: 10))
}
