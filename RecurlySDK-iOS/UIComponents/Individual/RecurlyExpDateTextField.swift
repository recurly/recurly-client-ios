//
//  ExpDateTextField.swift
//  RecurlySDK-iOS
//

import SwiftUI

/// Recurly Custom Secure TextField for ExpDate Input.
public struct RecurlyExpDateTextField: View {

    @ObservedObject private var session: RecurlyCardSession
    @State private var isEditing = false
    private var placeholder: String
    private var onEditingChanged: (Bool) -> Void
    private var textFieldFont: Font

    // Blur-gated: red only once the user leaves the field, unless validateData() ran.
    private var isInvalid: Bool { session.expDateError && (!isEditing || session.didAttemptValidation) }

    /// Creates a RecurlyExpDateTextField object
    /// - Parameters:
    ///   - session: The `RecurlyCardSession` this field reads from and writes to. Share one
    ///     session across every field belonging to the same card.
    ///   - placeholder: The placeholder for the Card Number TextField
    ///   - textFieldFont: Optional Textfield Custom Font, Default its ("Inter-Regular", size: 17)
    public init(session: RecurlyCardSession,
                placeholder: String,
                onEditingChanged: @escaping (Bool) -> Void = { _ in },
                textFieldFont: Font = Font.custom("Inter-Regular", size: 17)){

        FontLoader.registerBundledFonts
        self.session = session
        self.placeholder = placeholder
        self.onEditingChanged = onEditingChanged
        self.textFieldFont = textFieldFont
    }

    public var body: some View {
        ZStack {
            VStack {

                TextField("", text: $session.expDate, onEditingChanged: { editing in
                    isEditing = editing
                    onEditingChanged(editing)
                })
                    .placeholder(when: session.expDate.isEmpty) {
                        Text(placeholder).foregroundColor(.gray)
                    }
                    .keyboardType(.numberPad)
                    .foregroundColor(.cardFieldText(isInvalid: isInvalid))
                    .modifier(TextFieldClearButton(text: $session.expDate))
                    .font(textFieldFont)
                    .padding(.leading, 0)

                Divider()
                    .frame(height: 0.7)
                    .background(Color.cardFieldDivider(isInvalid: isInvalid))
            }
        }
    }
}
