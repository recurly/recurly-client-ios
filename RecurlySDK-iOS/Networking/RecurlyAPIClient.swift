//
//  APIClient.swift
//  RecurlySDK-iOS
//

import Foundation
import Combine

/// Seam allowing `RecurlyTokenizationManager` to be tested with an injected fake, without
/// driving a real `URLSession` round-trip through `NetworkEngine`.
protocol TokenAPIClient {
    func getToken<T: Codable>(with dataRequest: T, requestType: TokenizationAPI) -> AnyPublisher<RecurlyToken, Error>
    func getTokenID<T: Codable>(with dataRequest: T, requestType: TokenizationAPI) -> AnyPublisher<String, Error>
}

struct RecurlyAPIClient: TokenAPIClient {
    
    private let networkEngine: NetworkEngine
    
    init(networkEngine: NetworkEngine = NetworkEngine()) {
        self.networkEngine = networkEngine
    }
    
    /// Maps a decoded tokenization response into the public `RecurlyToken`, or a "missing id"
    /// SDK-internal error when the response lacks one. Pure and side-effect free — this is the
    /// seam used to unit test the success/failure mapping without a network round-trip.
    static func makeToken(from result: Result<RecurlyTokenResponse, RecurlyBaseErrorResponse>) -> Result<RecurlyToken, Error> {
        switch result {
        case .success(let response):
            guard let id = response.id, !id.isEmpty else {
                return .failure(RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "sdk-internal",
                                                                         message: "Token response missing id",
                                                                         details: [])))
            }
            return .success(RecurlyToken(id: id, type: response.type, card: response.card))
        case .failure(let errorResponse):
            return .failure(errorResponse)
        }
    }
    
    /// Sends a tokenization request and emits the full `RecurlyToken` (id, type, and card metadata when present).
    func getToken<T: Codable>(with dataRequest: T, requestType: TokenizationAPI) -> AnyPublisher<RecurlyToken, Error> {
        guard let request = networkEngine.createPOSTRequest(requestType: requestType,
                                                            requestBody: dataRequest) else {
            let error = RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "sdk-internal",
                                                                 message: "Failed to build request",
                                                                 details: []))
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let subject = PassthroughSubject<RecurlyToken, Error>()
        networkEngine.sendRequest(responseModel: RecurlyTokenResponse.self, request: request) { result in
            switch Self.makeToken(from: result) {
            case .success(let token):
                subject.send(token)
                subject.send(completion: .finished)
            case .failure(let error):
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    /// Sends a tokenization request and emits the token id only.
    func getTokenID<T: Codable>(with dataRequest: T, requestType: TokenizationAPI) -> AnyPublisher<String, Error> {
        getToken(with: dataRequest, requestType: requestType)
            .map(\.id)
            .eraseToAnyPublisher()
    }
    
}
