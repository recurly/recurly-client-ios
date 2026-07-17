//
//  FontLoader.swift
//  RecurlySDK-iOS
//

import SwiftUI

class FontLoader {
    static public func loadFont(name: String, fileExtension: String) {
        if let fontUrl = Resource.getProjectBundle().url(forResource: name, withExtension: fileExtension),
           let dataProvider = CGDataProvider(url: fontUrl as CFURL),
           let newFont = CGFont(dataProvider) {
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(newFont, &error) {
                NSLog("RecurlySDK: Error registering font \(name).\(fileExtension)")
            }
        } else {
            NSLog("RecurlySDK: Error loading font \(name).\(fileExtension)")
        }
    }
}