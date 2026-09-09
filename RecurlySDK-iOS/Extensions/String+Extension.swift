//
//  String+Extension.swift
//  RecurlySDK-iOS
//

import Foundation

public extension String {
    /// Keeps ASCII digits, the space character, and any characters in `exceptions`.
    /// Removes everything else.
    /// - Parameter exceptions: Extra characters to keep. Each character is matched
    ///   literally, so regex metacharacters are safe to pass.
    /// - Returns: The filtered string.
    func removeNonNumericChars(exceptions: String = "") -> String {
        var allowed = CharacterSet(charactersIn: "0123456789 ")
        allowed.insert(charactersIn: exceptions)
        return components(separatedBy: allowed.inverted).joined()
    }
}

extension String {
    /// The receiver with every character removed that is not a Unicode decimal
    /// digit. Digits outside ASCII, such as Arabic-Indic, are kept.
    var digitsOnly: String {
        let set = CharacterSet.decimalDigits.inverted
        let numbers = components(separatedBy: set)
        return numbers.joined(separator: "")
    }
}
