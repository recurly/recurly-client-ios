//
//  Request.swift
//  RecurlySDK-iOS
//

import Foundation

protocol BaseRequest {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var parameters: [URLQueryItem]? { get }
    var method: String { get }
    var absoluteString: String { get }
    var userAgent: String { get }
}
