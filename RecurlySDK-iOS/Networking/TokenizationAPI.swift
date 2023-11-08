//
//  TokenizationAPI.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 1/12/21.
//

import SwiftUI
import CoreTelephony

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
        let defaultURL = "api.recurly.com/js/v1"
        let defaultURLEU = "api.eu.recurly.com/js/v1"
        
        switch self {
        default:
            if REConfiguration.shared.apiPublicKey.starts(with: "fra-") {
                return defaultURLEU
            }
            return defaultURL
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
        let carrier = CTCarrier()
        return """
                recurly-ios/v1.0.0;
                device/\(UIDevice.modelName);
                os/\(UIDevice.current.systemVersion);
                carrierName/\(carrier.carrierName ?? "");
                isoCountryCode/\(carrier.isoCountryCode ?? "");
                mobileCountryCode/\(carrier.mobileCountryCode ?? "");
                mobileNetworkCode/\(carrier.mobileNetworkCode ?? "");
                appName/\(Bundle.main.bundleIdentifier ?? "");
                """
    }
    
}
