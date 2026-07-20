//
//  APIClient.swift
//  RecurlySDK-iOS
//

import Foundation
import Combine

struct RecurlyAPIClient {
    
    private let networkEngine: NetworkEngine
    
    init(networkEngine: NetworkEngine = NetworkEngine()) {
        self.networkEngine = networkEngine
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
            switch result {
            case .success(let response):
                guard let id = response.id, !id.isEmpty else {
                    subject.send(completion: .failure(RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "sdk-internal",
                                                                                               message: "Token response missing id",
                                                                                               details: []))))
                    return
                }
                subject.send(RecurlyToken(id: id, type: response.type, card: response.card))
                subject.send(completion: .finished)
            case .failure(let errorResponse):
                subject.send(completion: .failure(errorResponse))
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
