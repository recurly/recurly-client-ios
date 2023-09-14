//
//  Image+Extension.swift
//  RecurlySDK-iOS
//
//  Created by Andy Kelso on 09/15/2023.
//

import SwiftUI

extension Image {
    init(_ name: String) {
        self.init(name, bundle: Resource.getProjectBundle())
    }
}
