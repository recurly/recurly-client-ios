//
//  String+Extension.swift
//  RecurlySDK-iOS
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

extension String {
    /// The receiver with every non-digit character removed.
    var digitsOnly: String {
        let set = CharacterSet.decimalDigits.inverted
        let numbers = components(separatedBy: set)
        return numbers.joined(separator: "")
    }
}
