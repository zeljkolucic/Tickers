//
//  TickersViewModel.swift
//  Tickers
//
//  Created by Zeljko Lucic on 22.3.24..
//

import SwiftUI
import Combine

public final class TickersViewModel: ObservableObject {
    @Published public var message: String?
    @Published public var isLoading = false
    @Published public var searchTerm = ""
    @Published public var tickers = [Ticker]()
    
    var filteredTickers: [Ticker] {
        guard searchTerm != "" else {
            return tickers
        }
        
        return tickers.filter { $0.symbol.name.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    var title: String {
        Localizable.NavigationBar.title.localized
    }
    
    private var timerCancellable: AnyCancellable?
    var cancellables = Set<AnyCancellable>()
    
    @ObservedObject private var reachability: Reachability
    private let tickerRepository: TickerRepository
    private let timeInterval: TimeInterval
    
    public init(reachability: Reachability, tickerRepository: TickerRepository, timeInterval: TimeInterval) {
        self.reachability = reachability
        self.tickerRepository = tickerRepository
        self.timeInterval = timeInterval
        observeConnectivityChanges()
    }
    
    private func observeConnectivityChanges() {
        reachability.$isConnected
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.startLoading()
                } else {
                    self?.message = Localizable.Error.message.localized
                    self?.stopLoading()
                }
            }.store(in: &cancellables)
    }
    
    func startLoading() {
        Task { @MainActor in
            do {
                stopLoading()
                
                isLoading = true
                let tickers = try await tickerRepository.load()
                self.tickers = tickers
                isLoading = false
                
                loadAtTimeIntervals()
            } catch {
                message = Localizable.Error.message.localized
            }
        }
    }
    
    private func loadAtTimeIntervals() {
        stopLoading()
        
        timerCancellable = Timer.publish(every: timeInterval, on: .main, in: .default)
            .autoconnect()
            .flatMap { _ in
                return Future<[Ticker], Error> { promise in
                    Task { [weak self] in
                        guard let self else { return }
                        
                        do {
                            let tickers = try await tickerRepository.load()
                            promise(.success(tickers))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .replaceError(with: tickers)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tickers in
                self?.tickers = tickers
            })
    }
    
    private func stopLoading() {
        timerCancellable = nil
    }
}
