//
//  FontLoader.swift
//  RecurlySDK-iOS
//

import SwiftUI

class FontLoader {
    /// Registers the bundled card-field fonts. A `static let` runs its initializer at
    /// most once, so repeated access never re-registers and never re-logs a spurious error.
    static let registerBundledFonts: Void = {
        loadFont(name: "Inter-Regular", fileExtension: "ttf")
    }()

    static public func loadFont(name: String, fileExtension: String) {
        if let fontUrl = Resource.getProjectBundle().url(forResource: name, withExtension: fileExtension),
           let dataProvider = CGDataProvider(url: fontUrl as CFURL),
           let newFont = CGFont(dataProvider) {
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(newFont, &error) {
                let reason = error.map { String(describing: $0.takeRetainedValue()) } ?? "unknown"
                NSLog("RecurlySDK: Error registering font \(name).\(fileExtension): \(reason)")
            }
        } else {
            NSLog("RecurlySDK: Error loading font \(name).\(fileExtension)")
        }
    }
}