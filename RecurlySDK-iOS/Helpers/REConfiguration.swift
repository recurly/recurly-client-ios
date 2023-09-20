//
//  REConfiguration.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 7/12/21.
//

import Foundation

/// Main Configuration initializer containing the public key
public struct REConfiguration {
    public var apiPublicKey = ""
    public var sessionId = UUID()
    public static var shared = REConfiguration()

    public mutating func initialize(publicKey: String) {
        self.apiPublicKey = publicKey
    }
}
