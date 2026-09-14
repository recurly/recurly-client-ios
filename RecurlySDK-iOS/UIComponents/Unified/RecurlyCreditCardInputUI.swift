//
//  RecurlyCreditCardInputUI.swift
//  RecurlySDK-iOS
//

import SwiftUI

/// Recurly Custom Secure TextField for Card Input.
public struct RecurlyCreditCardInputUI: View {
    @ObservedObject private var session: RecurlyCardSession
    @State private var numberEditing = false
    @State private var expDateEditing = false
    @State private var cvvFocused = false
    private var cardNumberPlaceholder: String
    private var expDatePlaceholder: String
    private var cvvPlaceholder: String
    private var textFieldFont: Font
    private var titleLabelFont: Font

    // Blur-gated: red only once the user leaves the field, unless validateData() ran.
    // `@MainActor` is explicit here since `hasError` reads these outside `body`, which
    // would otherwise infer no isolation.
    @MainActor private var cardNumberIsInvalid: Bool { session.cardNumberError && (!numberEditing || session.didAttemptValidation) }
    @MainActor private var expDateIsInvalid: Bool { session.expDateError && (!expDateEditing || session.didAttemptValidation) }
    @MainActor private var cvvIsInvalid: Bool { session.cvvError && (!cvvFocused || session.didAttemptValidation) }
    @MainActor private var hasError: Bool { cardNumberIsInvalid || expDateIsInvalid || cvvIsInvalid }

    private func setNumberEditing(_ editing: Bool) { numberEditing = editing }
    private func setExpDateEditing(_ editing: Bool) { expDateEditing = editing }
    private func setCVVFocused(_ editing: Bool) { cvvFocused = editing }

    /// Creates a RecurlyCreditCardInputUI object
    /// - Parameters:
    ///   - session: The `RecurlyCardSession` this view reads from and writes to. Call
    ///     `session.validateData()` before requesting a token to confirm the card is complete.
    ///   - cardNumberPlaceholder: The placeholder for the Card Number TextField
    ///   - expDatePlaceholder: The placeholder for the Exp Date TextField
    ///   - cvvPlaceholder: The placeholder for the CVV TextField
    ///   - textFieldFont: Optional Textfield Custom Font
    ///   - titleLabelFont: Optional Textfield Title Custom Font
    public init(session: RecurlyCardSession,
                cardNumberPlaceholder: String,
                expDatePlaceholder: String,
                cvvPlaceholder: String,
                textFieldFont: Font = Font.custom("Inter-Regular", size: 15),
                titleLabelFont: Font = Font.custom("Inter-Regular", size: 13)) {

        FontLoader.registerBundledFonts
        self.session = session
        self.cardNumberPlaceholder = cardNumberPlaceholder
        self.expDatePlaceholder = expDatePlaceholder
        self.cvvPlaceholder = cvvPlaceholder
        self.textFieldFont = textFieldFont
        self.titleLabelFont = titleLabelFont
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 0){

            Image(cvvFocused ? (session.brand == .amex ? "amexCVVcardIcon" : "cvvCardIcon") : session.brandImageName)
                .resizable()
                .frame(width: 40, height: 26, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .padding(.vertical, 12)
                .padding(.leading, 12)
                // Amex prints its CVV on the card FRONT, so flipping to a back-of-card
                // graphic would be wrong for that brand — skip the rotation for it.
                .rotation3DEffect(.degrees(cvvFocused && session.brand != .amex ? 360 : 0), axis: (x: 1, y: 0, z: 0))
                .animation(.easeIn, value: cvvFocused)


            RecurlyPlaceholderTextField(placeholder: cardNumberPlaceholder,
                                   mainText: $session.number,
                                   onEditingChanged: setNumberEditing,
                                   textFieldFont: textFieldFont,
                                   titleLabelFont: titleLabelFont)
                .keyboardType(.numberPad)
                .frame(minWidth: 100, idealWidth: 190, alignment: .trailing)
                .foregroundColor(.cardFieldText(isInvalid: cardNumberIsInvalid))

            RecurlyPlaceholderTextField(placeholder: expDatePlaceholder,
                                   mainText: $session.expDate,
                                   onEditingChanged: setExpDateEditing,
                                   textFieldFont: textFieldFont,
                                   titleLabelFont: titleLabelFont)
                .keyboardType(.numberPad)
                .frame(width: 70, alignment: .leading)
                .foregroundColor(.cardFieldText(isInvalid: expDateIsInvalid))

            RecurlyPlaceholderTextField(placeholder: cvvPlaceholder, mainText: $session.cvv, onEditingChanged: setCVVFocused, textFieldFont: textFieldFont, titleLabelFont: titleLabelFont)
                .keyboardType(.numberPad)
                .frame(width: 50, alignment: .leading)
                .foregroundColor(.cardFieldText(isInvalid: cvvIsInvalid))
                .padding(.trailing, 5)
                .padding(.leading, -7)

        }.frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: hasError ? .red : .clear, radius: hasError ? 4 : 0, x: 0, y: 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(hasError ? Color.red : Color.gray, lineWidth: hasError ? 1 : 0.5)
            )
            .padding(10)
    }
}

struct CreditCardInputUI_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    // `@StateObject` needs a `View`'s storage — a preview's own inline
    // `RecurlyCardSession()` would be the copy-paste source of the exact bug
    // this type exists to avoid (see the README's `@StateObject` guidance).
    private struct PreviewWrapper: View {
        @StateObject private var session = RecurlyCardSession()

        var body: some View {
            RecurlyCreditCardInputUI(session: session, cardNumberPlaceholder: "Card Number", expDatePlaceholder: "MM/YY", cvvPlaceholder: "CVV")
        }
    }
}

