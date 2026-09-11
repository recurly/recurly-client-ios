//
//  CardNumberTextField.swift
//  RecurlySDK-iOS
//

import SwiftUI

/// Recurly Custom Secure TextField for Card Number Input.
public struct RecurlyCardNumberTextField: View {
    @ObservedObject private var session: RecurlyCardSession
    @State private var isEditing = false
    private var placeholder: String
    private var onEditingChanged: (Bool) -> Void
    private var textFieldFont: Font

    // Blur-gated: red only once the user leaves the field, unless validateData() ran.
    private var isInvalid: Bool { session.cardNumberError && (!isEditing || session.didAttemptValidation) }

    /// Creates a RecurlyCardNumberTextField object
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
                HStack {
                    Image(session.brandImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 26, alignment: .center)
                        .padding(.leading, 6)

                    TextField("", text: $session.number, onEditingChanged: { editing in
                        isEditing = editing
                        onEditingChanged(editing)
                    })
                        .placeholder(when: session.number.isEmpty) {
                            Text(placeholder).foregroundColor(.gray)
                        }
                        .keyboardType(.numberPad)
                        .foregroundColor(.cardFieldText(isInvalid: isInvalid))
                        .modifier(TextFieldClearButton(text: $session.number))
                        .font(textFieldFont)
                        .padding(.leading, 0)
                }

                Divider()
                    .frame(height: 0.7)
                    .padding(.horizontal, 0)
                    .background(Color.cardFieldDivider(isInvalid: isInvalid))
            }
        }
    }
}
