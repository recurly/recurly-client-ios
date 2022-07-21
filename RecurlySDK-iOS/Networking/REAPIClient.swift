//
//  APIClient.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 2/12/21.
//

import Foundation
import Combine

struct REAPIClient {
    
    private let networkEngine = NetworkEngine()
    
    func getTokenID<T: Codable>(with dataRequest: T, requestType: TokenizationAPI) -> AnyPublisher<String, Error> {
        let subject = PassthroughSubject<String, Error>()
        guard let request = networkEngine.createPOSTRequest(requestType: requestType,
                                                            requestBody: dataRequest) else {
            return subject.eraseToAnyPublisher()
        }
        
        networkEngine.sendRequest(responseModel: RETokenResponse.self, request: request) { result in
            switch result {
            case .success(let response):
                subject.send(response.id ?? "")
                subject.send(completion: .finished)
            case .failure(let errorResponse):
                subject.send(completion: .failure(errorResponse))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
}
