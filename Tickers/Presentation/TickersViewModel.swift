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
    @Published public var tickers = [Ticker]()
    
    var title: String {
        Localizable.NavigationBar.title.localized
    }
    
    private var timerCancellable: AnyCancellable?
    
    private let tickerRepository: TickerRepository
    private let timeInterval: TimeInterval
    
    public init(tickerRepository: TickerRepository, timeInterval: TimeInterval) {
        self.tickerRepository = tickerRepository
        self.timeInterval = timeInterval
    }
    
    public func load() async {
        do {
            tickers = try await tickerRepository.load()
        } catch {
            message = Localizable.Error.message.localized
        }
    }
    
    public func loadAtTimeIntervals() {
        timerCancellable = nil
        
        timerCancellable = Timer
            .publish(every: timeInterval, on: .main, in: .default)
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
                .eraseToAnyPublisher()
                .receive(on: DispatchQueue.main)
            }
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.message = Localizable.Error.message.localized
                }
            } receiveValue: { [weak self] tickers in
                print(tickers)
                self?.tickers = tickers
            }
    }
    
    public func stopLoading() {
        timerCancellable = nil
    }
}
