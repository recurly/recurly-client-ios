//
//  RecurlySDK.swift
//  RecurlySDK-iOS
//

/// SDK-wide metadata.
enum RecurlySDK {

    /// Hard-coded so the value stays correct under static linking (a bundle lookup
    /// would resolve to the host app, not the SDK, in that configuration).
    /// Generated from /VERSION by scripts/update_version.sh — do not edit.
    static let version = "3.0.0"
}
