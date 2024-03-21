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
    
    func get(from url: URL) async throws {
        let (data, response) = try await session.data(from: url)
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_get_deliversErrorOnRequestError() async {
        URLProtocolStub.startIntereceptingRequests()
        let url = anyURL
        let error = anyError
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        
        do {
            try await sut.get(from: url)
            XCTFail("Expected error, got success instead")
        } catch let receivedError as NSError {
            XCTAssertEqual(receivedError.domain, error.domain)
            XCTAssertEqual(receivedError.code, error.code)
        }
        URLProtocolStub.stopIntereceptingRequests()
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error? = nil) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startIntereceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopIntereceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
