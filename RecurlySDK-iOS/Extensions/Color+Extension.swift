//
//  Color+Extension.swift
//  RecurlySDK-iOS
//

import SwiftUI

extension Color {
    static func cardFieldText(isInvalid: Bool) -> Color {
        isInvalid ? .red : .black
    }

    static func cardFieldDivider(isInvalid: Bool) -> Color {
        isInvalid ? .red : .gray
    }
}
