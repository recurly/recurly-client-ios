//
//  MockURLProtocol.swift
//  RecurlySDK-iOSTests
//
//  URLProtocol stub used to exercise NetworkEngine/RecurlyAPIClient/RecurlyTokenizationManager
//  end-to-end offline, without requiring a network connection or PUBLIC_KEY.
//

import Foundation

class MockURLProtocol: URLProtocol {

    /// Set before each test to control the stubbed response for the next request.
    /// Return an `Error` in the tuple to simulate a transport-level failure (e.g. no connectivity).
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse?, Data?, Error?))?

    /// Convenience factory for a `URLSession` wired to this stub, for injecting into `NetworkEngine(session:)`.
    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("MockURLProtocol.requestHandler must be set before use")
        }

        do {
            let (response, data, error) = try handler(request)

            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }

            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // no-op
    }
}
