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
            return "api.recurly.com/js/v1"
        }
    }
    
    var path: String {
        switch self {
        case .getTokenID:
            return "/tokens"
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
        case .getTokenID:
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
