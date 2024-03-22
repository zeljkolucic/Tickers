//
//  TickersViewModelTests.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Tickers
import XCTest

final class TickersViewModel {
    var message: String?
    
    private let tickerRepository: TickerRepository
    
    init(tickerRepository: TickerRepository) {
        self.tickerRepository = tickerRepository
    }
    
    func load() async {
        do {
            _ = try await tickerRepository.load()
        } catch {
            message = "An error occurred. Please try again."
        }
    }
}

final class TickersViewModelTests: XCTestCase {
    func test_init_doesNotLoad() {
        let (_, repository) = makeSUT()
        
        XCTAssertEqual(repository.loadCallCount, 0)
    }
    
    func test_load_deliversErrorMessageOnLoadFailure() async {
        let (sut, repository) = makeSUT()
        repository.stub(error: anyError())
        
        await sut.load()
        
        XCTAssertEqual(sut.message, "An error occurred. Please try again.")
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
        private var error: Error?
        
        func stub(error: Error) {
            self.error = error
        }
        
        func load() async throws -> [Ticker] {
            loadCallCount += 1
            if let error {
                throw error
            }
            return []
        }
    }
}
