//
//  String+Extension.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 16/12/21.
//

import Foundation

public extension String {
    func removeNonNumericChars(exceptions: String = "") -> String {
        if self.range(of: "[^0-9 \(exceptions)]+", options: .regularExpression) != nil {
            return self.replacingOccurrences(of: "[^0-9 ]+", with: "", options: .regularExpression)
        }
        return self
    }
}
