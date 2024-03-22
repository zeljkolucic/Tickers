//
//  URLProtocolStub.swift
//  TickersTests
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Foundation

class URLProtocolStub: URLProtocol {
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
