//
//  APIClient.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 2/12/21.
//

import Foundation
import Combine

struct REAPIClient {
    
    private let networkEngine: NetworkEngine
    
    init(networkEngine: NetworkEngine = NetworkEngine()) {
        self.networkEngine = networkEngine
    }
    
    func getTokenID<T: Codable>(with dataRequest: T, requestType: TokenizationAPI) -> AnyPublisher<String, Error> {
        guard let request = networkEngine.createPOSTRequest(requestType: requestType,
                                                            requestBody: dataRequest) else {
            let error = REBaseErrorResponse(error: RETokenError(code: "sdk-internal",
                                                                 message: "Failed to build request",
                                                                 details: []))
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let subject = PassthroughSubject<String, Error>()
        networkEngine.sendRequest(responseModel: RETokenResponse.self, request: request) { result in
            switch result {
            case .success(let response):
                guard let id = response.id, !id.isEmpty else {
                    subject.send(completion: .failure(REBaseErrorResponse(error: RETokenError(code: "sdk-internal",
                                                                                               message: "Token response missing id",
                                                                                               details: []))))
                    return
                }
                subject.send(id)
                subject.send(completion: .finished)
            case .failure(let errorResponse):
                subject.send(completion: .failure(errorResponse))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
}
