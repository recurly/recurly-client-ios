//
//  Image+Extension.swift
//  RecurlySDK-iOS
//

import SwiftUI

extension Image {
    init(_ name: String) {
        self.init(name, bundle: Resource.getProjectBundle())
    }
}
