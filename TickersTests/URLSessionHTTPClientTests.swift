//
//  URLSessionHTTPClientTests.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Tickers
import XCTest

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
    
    func test_get_failsOnAllInvalidRepresentationCases() async {
        await assertResultErrorNotNil(data: nil, response: nonHTTPURLResponse(), error: nil)
        await assertResultErrorNotNil(data: anyData(), response: nil, error: anyError())
        await assertResultErrorNotNil(data: nil, response: nonHTTPURLResponse(), error: anyError())
        await assertResultErrorNotNil(data: nil, response: anyHTTPURLResponse(), error: anyError())
        await assertResultErrorNotNil(data: anyData(), response: nonHTTPURLResponse(), error: anyError())
        await assertResultErrorNotNil(data: anyData(), response: anyHTTPURLResponse(), error: anyError())
        await assertResultErrorNotNil(data: anyData(), response: nonHTTPURLResponse(), error: nil)
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
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func assertResultErrorNotNil(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) async {
        let resultError = await resultErrorFor((data: data, response: response, error: error))
        XCTAssertNotNil(resultError, file: file, line: line)
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, file: StaticString = #file, line: UInt = #line) async -> Error? {
        let result = await resultFor(values, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead.", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, file: StaticString = #file, line: UInt = #line) async -> Result<(Data, HTTPURLResponse), Error> {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let sut = makeSUT(file: file, line: line)
        
        var receivedResult: Result<(Data, HTTPURLResponse), Error>!
        do {
            let (data, response) = try await sut.get(from: anyURL())
            receivedResult = .success((data, response))
        } catch {
            receivedResult = .failure(error)
        }
        return receivedResult
    }
}
