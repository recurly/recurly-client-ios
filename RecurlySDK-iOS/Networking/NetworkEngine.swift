//
//  NetworkEngine.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 2/12/21.
//

import Foundation

class NetworkEngine {
    
    private func createRequest(requestType: BaseRequest) -> URLRequest? {
        guard let components = URLComponents(string: requestType.absoluteString),
              let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = requestType.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(requestType.userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }
    
    
    func createPOSTRequest(requestType: TokenizationAPI,
                           requestBodyObject: Dictionary<String, Any>) -> URLRequest? {
        
        guard var request = createRequest(requestType: requestType) else { return nil }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBodyObject, options: []) {
            request.httpBody = jsonData
        }
        
        return request
    }
        
    func createPOSTRequest<T: Codable>(requestType: TokenizationAPI,
                                       requestBody: T) -> URLRequest? {
        
        guard var request = createRequest(requestType: requestType) else { return nil }
        
        if let data = try? JSONEncoder().encode(requestBody) {
            request.httpBody = data
            #if DEBUG
            print("JSON ENCODE: \(String(data: data, encoding: .utf8) ?? "")")
            #endif
        }
        
        return request
    }
    
    func sendRequest<T:Codable>(responseModel: T.Type, request: URLRequest, completionHandler: @escaping (Result<T, REBaseErrorResponse>) -> ()) {
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if let error = error {
                completionHandler(.failure(REBaseErrorResponse(error: RETokenError(code: "sdk-internal \(error._code)", message: error.localizedDescription))))
                return
            }
            guard let data = data else {
                completionHandler(.failure(REBaseErrorResponse(error: RETokenError(code: "sdk-internal", message: "No data"))))
                return
            }
            
            let decoder = JSONDecoder()
            if let errorResponse = try? decoder.decode(REBaseErrorResponse.self, from: data) {
                completionHandler(.failure(errorResponse))
                return
            }
                
            do {
                let response = try decoder.decode(responseModel.self, from: data)
                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(REBaseErrorResponse(error: RETokenError(code: "sdk-internal",
                                                                                   message: "Internal Mapping Error",
                                                                                   details: []))))
            }
        }).resume()
    }
}
