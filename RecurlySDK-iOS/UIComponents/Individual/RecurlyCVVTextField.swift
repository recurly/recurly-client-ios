//
//  CVVTextField.swift
//  RecurlySDK-iOS
//

import SwiftUI

/// Recurly Custom Secure TextField for CVV Input.
public struct RecurlyCVVTextField: View {
    
    @ObservedObject private var session: RecurlyCardSession
    @State private var isEditing = false
    private var placeholder: String
    private var onEditingChanged: (Bool) -> Void
    private var textFieldFont: Font

    // Blur-gated: red only once the user leaves the field, unless validateData() ran.
    private var isInvalid: Bool { session.cvvError && (!isEditing || session.didAttemptValidation) }

    /// Creates a RecurlyCVVTextField object
    /// - Parameters:
    ///   - session: The `RecurlyCardSession` this field reads from and writes to. Share one
    ///     session across every field belonging to the same card — the CVV field derives
    ///     its required length from the card number entered in another field via this session.
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
                
                TextField("", text: $session.cvv, onEditingChanged: { editing in
                    isEditing = editing
                    onEditingChanged(editing)
                })
                    .placeholder(when: session.cvv.isEmpty) {
                        Text(placeholder).foregroundColor(.gray)
                    }
                    .keyboardType(.numberPad)
                    .foregroundColor(.cardFieldText(isInvalid: isInvalid))
                    .modifier(TextFieldClearButton(text: $session.cvv))
                    .font(textFieldFont)
                    .padding(.leading, 0)
                
                Divider()
                    .frame(height: 0.7)
                    .background(Color.cardFieldDivider(isInvalid: isInvalid))
            }
        }
    }
}
