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
    
    private class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startIntereceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopIntereceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }
        
        override func stopLoading() {}
    }
}
