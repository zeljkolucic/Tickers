//
//  URLSessionHTTPClientTests.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 21.3.24..
//

import XCTest

final class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(from: url)
        
        guard let response = response as? HTTPURLResponse else {
            throw UnexpectedValuesRepresentation()
        }
        
        return (data, response)
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startIntereceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopIntereceptingRequests()
    }
    
    func test_get_deliversErrorOnRequestError() async {
        let error = anyError()
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        do {
            _ = try await makeSUT().get(from: anyURL())
            XCTFail("Expected error, got success instead")
        } catch let receivedError as NSError {
            XCTAssertEqual(receivedError.domain, error.domain)
            XCTAssertEqual(receivedError.code, error.code)
        }
    }
    
    func test_get_succeedsOnHTTPURLResponseWithData() async {
        let data = anyData()
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: data, response: response, error: nil)
        
        do {
            let (receivedData, receivedResponse) = try await makeSUT().get(from: anyURL())
            XCTAssertEqual(receivedData, data)
            XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        } catch {
            XCTFail("Expected to succeed, got \(error) instead")
        }
    }
    
    func test_get_succeedsOnEmptyDataHTTPURLResponseWithNilData() async {
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        do {
            let (receivedData, receivedResponse) = try await makeSUT().get(from: anyURL())
            let emptyData = Data()
            XCTAssertEqual(receivedData, emptyData)
            XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        } catch {
            XCTFail("Expected to succeed, got \(error) instead")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
