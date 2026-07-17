//
//  TokenizationAPI.swift
//  RecurlySDK-iOS
//

import SwiftUI

enum TokenizationAPI {
    case getTokenID
    case getApplePayTokenID
}

extension TokenizationAPI: BaseRequest {
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var baseURL: String {
        switch self {
        default:
            return RecurlyConfiguration.shared.apiPublicKey.hasPrefix("fra-")
                ? "api.eu.recurly.com/js/v1"
                : "api.recurly.com/js/v1"
        }
    }
    
    var path: String {
        switch self {
        case .getTokenID:
            return "/tokens"
        case .getApplePayTokenID:
            return "/apple_pay/token"
        }
    }
    
    var parameters: [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
    
    var method: String {
        switch self {
        case .getTokenID, .getApplePayTokenID:
            return "POST"
        }
    }
    
    var absoluteString: String {
        switch self {
        default:
            return self.scheme + "://" + self.baseURL + self.path
        }
    }
    
    var userAgent: String {
        return """
                recurly-ios/\(RecurlySDK.version);
                device/\(UIDevice.modelName);
                os/\(UIDevice.current.systemVersion);
                appName/\(Bundle.main.bundleIdentifier ?? "");
                """
    }
    
}
