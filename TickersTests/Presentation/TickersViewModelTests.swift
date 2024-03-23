//
//  TickersViewModelTests.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Tickers
import XCTest

final class TickersViewModelTests: XCTestCase {
    func test_init_doesNotLoad() {
        let (_, repository) = makeSUT()
        
        XCTAssertEqual(repository.loadCallCount, 0)
    }
    
    func test_loadTwice_loadsFromRepositoryTwice() async {
        let (sut, repository) = makeSUT()
        
        await sut.load()
        await sut.load()
        
        XCTAssertEqual(repository.loadCallCount, 2)
    }
    
    func test_load_deliversErrorMessageOnLoadFailure() async {
        let (sut, repository) = makeSUT()
        repository.stub(.failure(anyError()))
        
        await sut.load()
        
        XCTAssertEqual(sut.message, "An error occurred. Please try again.")
    }
    
    func test_load_deliversEmptyArrayOnSuccessfulLoadWithNoTickers() async {
        let (sut, repository) = makeSUT()
        repository.stub(.success([]))
        
        await sut.load()
        
        XCTAssertEqual(sut.tickers, [])
        XCTAssertNil(sut.message)
    }
    
    func test_load_deliversTickersOnSuccessfulLoad() async {
        let (sut, repository) = makeSUT()
        let ticker0 = Ticker(symbol: .tBTCUSD, lastPrice: 64714, dailyChangeRelative: -0.04482591)
        let ticker1 = Ticker(symbol: .tETHUSD, lastPrice: 3315.5, dailyChangeRelative: -0.06389407)
        repository.stub(.success([ticker0, ticker1]))
        
        await sut.load()
        
        XCTAssertEqual(sut.tickers, [ticker0, ticker1])
        XCTAssertNil(sut.message)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(timeInterval: TimeInterval = 1, file: StaticString = #filePath, line: UInt = #line) -> (sut: TickersViewModel, repository: TickerRepositorySpy) {
        let repository = TickerRepositorySpy()
        let sut = TickersViewModel(tickerRepository: repository, timeInterval: timeInterval)
        return (sut, repository)
    }
    
    private class TickerRepositorySpy: TickerRepository {
        var loadCallCount = 0
        private var stub: Result<[Ticker], Error>?
        
        func stub(_ stub: Result<[Ticker], Error>) {
            self.stub = stub
        }
        
        func load() async throws -> [Ticker] {
            loadCallCount += 1
            switch stub {
            case let .success(tickers):
                return tickers
            case let .failure(error):
                throw error
            default:
                return []
            }
        }
    }
}
