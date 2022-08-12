//
//  FontLoader.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 24/11/21.
//

import SwiftUI

class FontLoader {
    static public func loadFont(name: String, fileExtension: String) {
        if let fontUrl = Bundle(for: FontLoader.self).url(forResource: name, withExtension: fileExtension),
           let dataProvider = CGDataProvider(url: fontUrl as CFURL),
           let newFont = CGFont(dataProvider) {
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterGraphicsFont(newFont, &error){
                print("Loaded font")
            }
        } else {
            assertionFailure("Error loading font")
        }
    }
}
