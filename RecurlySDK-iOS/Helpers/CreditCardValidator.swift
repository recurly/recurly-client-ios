//
//  CreditCardValidator.swift
//  RecurlySDK-iOS
//

import Foundation

enum CreditCardType: String {
    case amex = "^3[47].*$"
    case visa = "^4.*$"
    case masterCard = "^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720).*$"
    case maestro = "^(?:5[0678]\\d\\d|6304|6390|67\\d\\d)\\d{8,15}$"
    case dinersClub = "^(30[0-5]|309|36|3[89]|54|55|2014|2149).*$"
    case jcb = "^35[2-8].*$"
    case discover = "^6(?:011|4[4-9][0-9]|5[0-9]{2})[0-9]{3,}$"
    case unionPay = "^62[0-5]\\d{13,16}$"
    case mir = "^2[0-9]{6,}$"
    
    /// Possible C/C number lengths for each C/C type
    /// reference: https://en.wikipedia.org/wiki/Payment_card_number
    var validNumberLength: IndexSet {
        switch self {
        case .visa:
            return IndexSet([13, 16, 19])
        case .amex:
            return IndexSet(integer: 15)
        case .maestro:
            return IndexSet(integersIn: 12...19)
        case .dinersClub:
            return IndexSet(integersIn: 14...19)
        case .jcb, .discover, .unionPay, .mir:
            return IndexSet(integersIn: 16...19)
        default:
            return IndexSet(integer: 16)
        }
    }
    
    var ccImage: String {
        switch self {
        default:
            return "\(String(describing: self) + "CCIcon")"
        }
    }
}

class CreditCardValidator {
    
    /// Available credit card types
    private let types: [CreditCardType] = [
        .amex,
        .visa,
        .masterCard,
        .maestro,
        .dinersClub,
        .jcb,
        .discover,
        .unionPay,
        .mir
    ]
    
    private let string: String
    
    /// Create validation value
    /// - Parameter string: credit card number
    init(_ string: String) {
        self.string = string.digitsOnly
    }
    
    /// Get card type
    /// Card number validation is not perfroms here
    var type: CreditCardType? {
        types.first { type in
            NSPredicate(format: "SELF MATCHES %@", type.rawValue)
                .evaluate(
                    with: string.digitsOnly
                )
        }
    }
    
    /// Calculation structure
    private struct Calculation {
        let odd, even: Int
        func result() -> Bool {
            (odd + even) % 10 == 0
        }
    }
    
    /// Validate credit card number
    var isValid: Bool {
        guard let type = type else { return false }
        let isValidLength = type.validNumberLength.contains(string.count)
        return isValidLength && isValid(for: string)
    }
    
    /// Validate card number string for type
    /// - Parameters:
    ///   - string: card number string
    ///   - type: credit card type
    /// - Returns: bool value
    func isValid(for type: CreditCardType) -> Bool {
        isValid && self.type == type
    }
    
    /// Validate string for credit card type
    /// - Parameters:
    ///   - string: card number string
    /// - Returns: bool value
    private func isValid(for string: String) -> Bool {
        string
            .reversed()
            .compactMap({ Int(String($0)) })
            .enumerated()
            .reduce(Calculation(odd: 0, even: 0), { value, iterator in
                return .init(
                    odd: odd(value: value, iterator: iterator),
                    even: even(value: value, iterator: iterator)
                )
            })
            .result()
    }
    
    private func odd(value: Calculation, iterator: EnumeratedSequence<[Int]>.Element) -> Int {
        iterator.offset % 2 != 0 ? value.odd + (iterator.element / 5 + (2 * iterator.element) % 10) : value.odd
    }
    
    private func even(value: Calculation, iterator: EnumeratedSequence<[Int]>.Element) -> Int {
        iterator.offset % 2 == 0 ? value.even + iterator.element : value.even
    }
    
    /// Groups a raw digit string for display, capped at the detected brand's max valid
    /// length. Grouping is 4/6/5 for Amex and short Diners, fours otherwise.
    static func formatCCfrom(string: String) -> String {
        let digitsOnly = string.digitsOnly
        let cardType = CreditCardValidator(string).type
        let maxDigits = cardType?.validNumberLength.max() ?? 19
        let digits = String(digitsOnly.prefix(maxDigits))

        let groupSizes: [Int]
        if cardType == .amex || (cardType == .dinersClub && digits.count <= 15) {
            groupSizes = [4, 6, 5]
        } else {
            groupSizes = Array(repeating: 4, count: (digits.count + 3) / 4)
        }

        var result = ""
        var index = digits.startIndex
        for (position, size) in groupSizes.enumerated() {
            guard index < digits.endIndex else { break }
            let end = digits.index(index, offsetBy: size, limitedBy: digits.endIndex) ?? digits.endIndex
            if position > 0 { result.append(" ") }
            result += digits[index..<end]
            index = end
        }
        return result
    }
    
    static func getExpDateFrom(string : String) -> String {
        let trimmedString = string
            .components(separatedBy: .whitespaces).joined()
            .components(separatedBy: "/").joined()
        
        let arrOfCharacters = Array(trimmedString)
        var modifiedCreditCardString = ""
        
        if(arrOfCharacters.count > 0) {
            for i in 0...arrOfCharacters.count-1 {
                modifiedCreditCardString.append(arrOfCharacters[i])
                if((i+1) % 2 == 0 && i+1 != arrOfCharacters.count){
                    modifiedCreditCardString.append("/")
                }
            }
        }
        return modifiedCreditCardString
    }

    // MARK: - Session field normalization
    //
    // `RecurlyCardSession` calls each of these once per field, so there is a single place
    // that decides what a field's stored value looks like.

    /// Digits-and-slash only, "MM/YY" formatted, capped at 5 characters. A single leading
    /// "2"-"9" is zero-padded, since it can only be the start of a two-digit month.
    static func sanitizedExpDate(from raw: String) -> String {
        var digitsOnly = raw.removeNonNumericChars(exceptions: "/")
        if digitsOnly.count == 1 && digitsOnly != "0" && digitsOnly != "1" {
            digitsOnly = "0" + digitsOnly
        }
        let formatted = getExpDateFrom(string: digitsOnly)
        return String(formatted.prefix(5))
    }

    /// Digits-only (no spaces — unlike `removeNonNumericChars`), capped at `maxLength`
    /// (the caller passes the CVV length required by the detected brand: 4 for Amex, 3
    /// otherwise).
    static func sanitizedCVV(from raw: String, maxLength: Int) -> String {
        let digitsOnly = raw.digitsOnly
        return String(digitsOnly.prefix(maxLength))
    }

    /// Parses "MM/YY" into a month and a four-digit year. `nil` if the month or year
    /// is missing or the month is out of range.
    static func expDateComponents(_ expDate: String) -> (month: Int, year: Int)? {
        let parts = expDate.components(separatedBy: "/")
        guard parts.count == 2,
              parts[1].count == 2,
              let month = Int(parts[0]),
              let year = Int(parts[1]),
              (1...12).contains(month) else {
            return nil
        }
        return (month, 2000 + year)
    }

    /// Whether a "MM/YY" expiration string is unusable for tokenization: incomplete,
    /// non-numeric, an out-of-range month, or a month/year that has already passed. An
    /// empty string is not an error — that's an untouched field, not an invalid one.
    static func expDateIsInvalid(_ expDate: String) -> Bool {
        guard !expDate.isEmpty else { return false }
        guard let components = expDateComponents(expDate) else { return true }
        let current = Calendar.current.dateComponents([.year, .month], from: Date())
        let currentYear = current.year ?? 0
        let currentMonth = current.month ?? 0
        if currentYear == components.year { return components.month < currentMonth }
        return components.year <= currentYear
    }
}
