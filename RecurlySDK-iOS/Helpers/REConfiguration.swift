//
//  REConfiguration.swift
//  RecurlySDK-iOS
//

import Foundation

/// Main Configuration initializer containing the public key
public final class REConfiguration {
    public static let shared = REConfiguration()

    private let lock = NSLock()
    private var _apiPublicKey = ""
    private var _sessionId = UUID()

    /// The Recurly public API key.
    ///
    /// Whole-value assignment and compound mutation (e.g. `apiPublicKey += "suffix"`) are both
    /// atomic via the `_modify` accessor below. See the non-reentrancy caveat on
    /// `RETokenizationManager.cardData` — the same `NSLock` rules apply here.
    public var apiPublicKey: String {
        get { lock.lock(); defer { lock.unlock() }; return _apiPublicKey }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_apiPublicKey
        }
    }
    public var sessionId: UUID {
        get { lock.lock(); defer { lock.unlock() }; return _sessionId }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_sessionId
        }
    }

    internal init() {}

    public func initialize(publicKey: String) {
        self.apiPublicKey = publicKey
    }
}
