//
//  TickersViewModelTests.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Tickers
import XCTest

final class TickersViewModel {
    private let tickerRepository: TickerRepository
    
    init(tickerRepository: TickerRepository) {
        self.tickerRepository = tickerRepository
    }
    
    func load() {
        
    }
}

final class TickersViewModelTests: XCTestCase {
    func test_init_doesNotLoad() {
        let (_, repository) = makeSUT()
        
        XCTAssertEqual(repository.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: TickersViewModel, repository: TickerRepositorySpy) {
        let repository = TickerRepositorySpy()
        let sut = TickersViewModel(tickerRepository: repository)
        trackForMemoryLeaks(repository)
        trackForMemoryLeaks(sut)
        return (sut, repository)
    }
    
    private class TickerRepositorySpy: TickerRepository {
        var loadCallCount = 0
        
        func load() async throws -> [Ticker] {
            loadCallCount += 1
            return []
        }
    }
}
