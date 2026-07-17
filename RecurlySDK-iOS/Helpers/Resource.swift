//
//  Resource.swift
//  RecurlySDK-iOS
//

import SwiftUI

class Resource {
    static public func getProjectBundle() -> Bundle {
        return Bundle(for: Resource.self)
    }
}
