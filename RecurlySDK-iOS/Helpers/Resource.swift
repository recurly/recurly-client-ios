//
//  Resource.swift
//  RecurlySDK-iOS
//
//  Created by Andy Kelso on 9/15/23.
//

import SwiftUI

class Resource {
    static public func getProjectBundle() -> Bundle {
        return Bundle(for: Resource.self)
    }
}
