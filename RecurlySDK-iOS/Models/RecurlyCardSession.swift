//
//  RecurlyCardSession.swift
//  RecurlySDK-iOS
//

import SwiftUI

/// Owns the card data a Recurly card input component writes to, and the sole source
/// `RecurlyTokenizationManager` reads from at tokenization time.
///
/// Create one instance per checkout screen with `@StateObject` and pass it to every
/// Recurly card input component that shares a card. `RecurlyCardData` is derived from
/// this session fresh on every access — it is never cached — so there is no copy of the
/// card data that can fall out of sync with what's on screen.
///
/// The card number and CVV are not exposed publicly: reading them requires passing the
/// session to a Recurly input component or to `RecurlyTokenizationManager`.
@MainActor
public final class RecurlyCardSession: ObservableObject {

    @Published internal var number: String = "" {
        didSet {
            // The re-entrant set below terminates because the sanitizer is idempotent.
            let sanitized = CreditCardValidator.formatCCfrom(string: number)
            if sanitized != number { number = sanitized; return }
            cardNumberError = cardNumberIsInvalid(treatEmptyAsInvalid: didAttemptValidation)

            // The brand — and therefore the required CVV length — may have just changed.
            // `cvv`'s own didSet always truncates to the CURRENT `cvvLength`, so
            // `cvv.count > cvvLength` here can only mean the brand just shrank the
            // requirement after the CVV was entered (e.g. Amex "1234" -> Visa). That
            // stale digit is a wrong-but-valid-looking prefix if kept, so clear rather
            // than truncate. A CVV that already fits (including a brand INCREASE,
            // which never makes `cvv` too long) just gets re-flagged, not cleared —
            // this also means backspacing a card number never wipes a still-valid CVV.
            if cvv.count > cvvLength {
                cvv = ""
            } else {
                cvvError = cvvIsInvalid(treatEmptyAsInvalid: didAttemptValidation)
            }
        }
    }

    @Published internal var expDate: String = "" {
        didSet {
            let sanitized = CreditCardValidator.sanitizedExpDate(from: expDate)
            if sanitized != expDate { expDate = sanitized; return }
            expDateError = expDateIsInvalid(treatEmptyAsInvalid: didAttemptValidation)
        }
    }

    @Published internal var cvv: String = "" {
        didSet {
            let sanitized = CreditCardValidator.sanitizedCVV(from: cvv, maxLength: cvvLength)
            if sanitized != cvv { cvv = sanitized; return }
            cvvError = cvvIsInvalid(treatEmptyAsInvalid: didAttemptValidation)
        }
    }

    /// Whether the card number typed so far is invalid. `false` while the field is
    /// empty and `validateData()` has not run yet — an untouched field is not yet an
    /// error. Once `validateData()` runs, an empty field counts as invalid until the
    /// next `reset()`.
    @Published public internal(set) var cardNumberError = false
    /// Whether the expiration date typed so far is invalid. `false` while the field is
    /// empty and `validateData()` has not run yet — an untouched field is not yet an
    /// error. Once `validateData()` runs, an empty field counts as invalid until the
    /// next `reset()`.
    @Published public internal(set) var expDateError = false
    /// Whether the CVV typed so far is invalid. `false` while the field is empty and
    /// `validateData()` has not run yet — an untouched field is not yet an error. Once
    /// `validateData()` runs, an empty field counts as invalid until the next `reset()`.
    @Published public internal(set) var cvvError = false

    /// Latched by `validateData()`, cleared by `reset()`. Switches every field's empty
    /// state from "not yet an error" to "an error" so a submit-time validation failure
    /// stays flagged (and visible past the merchant's blur-gated UI) instead of being
    /// silently cleared by an edit to an unrelated field.
    @Published internal var didAttemptValidation = false

    public nonisolated init() {}

    /// The detected card brand, or `nil` before enough digits have been entered to tell.
    internal var brand: CreditCardType? { CreditCardValidator(number).type }


    /// The asset name for the detected brand, or a placeholder before one is known.
    internal var brandImageName: String { brand?.ccImage ?? "placeholderCCIcon" }

    /// The CVV length required for the brand entered so far (4 for Amex, 3 otherwise).
    internal var cvvLength: Int { brand == .amex ? 4 : 3 }

    private func cardNumberIsInvalid(treatEmptyAsInvalid: Bool) -> Bool {
        number.isEmpty ? treatEmptyAsInvalid : !CreditCardValidator(number).isValid
    }

    private func expDateIsInvalid(treatEmptyAsInvalid: Bool) -> Bool {
        expDate.isEmpty ? treatEmptyAsInvalid : CreditCardValidator.expDateIsInvalid(expDate)
    }

    private func cvvIsInvalid(treatEmptyAsInvalid: Bool) -> Bool {
        cvv.isEmpty ? treatEmptyAsInvalid : cvv.count != cvvLength
    }

    /// Whether every field currently holds a valid, complete value. Unlike
    /// `validateData()`, this never mutates the error flags or the UI they drive — safe
    /// to read on every keystroke, e.g. to enable/disable a Submit button reactively.
    public var isComplete: Bool {
        !cardNumberIsInvalid(treatEmptyAsInvalid: true)
            && !expDateIsInvalid(treatEmptyAsInvalid: true)
            && !cvvIsInvalid(treatEmptyAsInvalid: true)
    }

    /// Validates every field and updates `cardNumberError`/`expDateError`/`cvvError` to
    /// match — unlike the live per-keystroke flags above, an empty field counts as
    /// invalid here, and every field keeps that stricter rule until the next `reset()`.
    /// Call before requesting a token to confirm the card is complete rather than
    /// relying solely on the server-side check.
    @discardableResult
    public func validateData() -> Bool {
        didAttemptValidation = true
        cardNumberError = cardNumberIsInvalid(treatEmptyAsInvalid: true)
        expDateError = expDateIsInvalid(treatEmptyAsInvalid: true)
        cvvError = cvvIsInvalid(treatEmptyAsInvalid: true)
        return isComplete
    }

    /// Blanks every field and clears the `validateData()` latch, matching a freshly
    /// created session.
    public func reset() {
        didAttemptValidation = false
        number = ""
        expDate = ""
        cvv = ""
    }

    /// `RecurlyCardData` derived from the current field values. Computed fresh on every
    /// access — never cached — so it can't diverge from what's on screen.
    internal var cardData: RecurlyCardData {
        guard let components = CreditCardValidator.expDateComponents(expDate) else {
            return RecurlyCardData(number: number.digitsOnly, month: "", year: "", cvv: cvv)
        }
        return RecurlyCardData(number: number.digitsOnly, month: String(components.month), year: String(components.year), cvv: cvv)
    }
}
