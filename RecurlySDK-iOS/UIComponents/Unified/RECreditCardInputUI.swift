//
//  RECreditCardInputUI.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 22/11/21.
//

import SwiftUI
import Combine

/// Recurly Custom Secure TextField for Card Input.
public struct RECreditCardInputUI: View {
    
    @StateObject private var viewModel = UnifiedViewModel()
    private var cardNumberPlaceholder: String
    private var expDatePlaceholder: String
    private var cvvPlaceholder: String
    private var textFieldFont: Font
    private var titleLabelFont: Font
    
    /// Creates a RECreditCardInputUI object
    /// - Parameters:
    ///   - cardNumberPlaceholder: The placeholder for the Card Number TextField
    ///   - expDatePlaceholder: The placeholder for the Exp Date TextField
    ///   - cvvPlaceholder: The placeholder for the CVV TextField
    ///   - textFieldFont: Optional Textfield Custom Font
    ///   - titleLabelFont: Optional Textfield Title Custom Font
    public init(cardNumberPlaceholder: String,
                expDatePlaceholder: String,
                cvvPlaceholder: String,
                textFieldFont: Font = Font.custom("Inter-Regular", size: 15),
                titleLabelFont: Font = Font.custom("Inter-Regular", size: 13)) {
        
        self.cardNumberPlaceholder = cardNumberPlaceholder
        self.expDatePlaceholder = expDatePlaceholder
        self.cvvPlaceholder = cvvPlaceholder
        self.textFieldFont = textFieldFont
        self.titleLabelFont = titleLabelFont
    }
    
    private func didOnEditingChanged(editingChanged: Bool) -> Void {
        if editingChanged {
            viewModel.lastCardStatus = .entering
        } else {
            viewModel.validateCreditCard()
            viewModel.lastCardStatus = viewModel.cardStatus
        }
    }
    
    public var body: some View {
        
        HStack(alignment: .center, spacing: 0){
            
            Image(viewModel.mainImageName, bundle: Bundle(identifier: "recurly.RecurlySDK-iOS"))
                .resizable()
                .frame(width: 40, height: 26, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .padding(.vertical, 12)
                .padding(.leading, 12)
                .rotation3DEffect(.degrees(viewModel.rotation), axis: (x: 1, y: 0, z: 0))
                .animation(.easeIn, value: viewModel.rotation)
            
            REPlaceholderTextField(placeholder: cardNumberPlaceholder,
                                   mainText: $viewModel.cardNumber,
                                   onEditingChanged: didOnEditingChanged(editingChanged:),
                                   textFieldFont: textFieldFont,
                                   titleLabelFont: titleLabelFont)
                .keyboardType(.numberPad)
                .frame(minWidth: 100, idealWidth: 190, alignment: .trailing)
                .foregroundColor(viewModel.lastCardStatus == .error ? .red : .black)
                .onReceive(Just(viewModel.cardNumber)) { out in
                    let filteredString = viewModel.cardNumber.removeNonNumericChars()
                    if viewModel.cardNumber != filteredString {
                        viewModel.cardNumber = filteredString
                    }
                    let ccValidator = CreditCardValidator(viewModel.cardNumber)
                    let cardLenght = ccValidator.type == .amex ? 17 : 19
                    if viewModel.cardNumber.count > cardLenght {
                        viewModel.cardNumber = String(viewModel.cardNumber.prefix(cardLenght))
                    }
                }
            
            REPlaceholderTextField(placeholder: expDatePlaceholder, mainText: $viewModel.expDate, textFieldFont: textFieldFont, titleLabelFont: titleLabelFont)
                .keyboardType(.numberPad)
                .frame(width: 70, alignment: .leading)
                .foregroundColor(viewModel.expDateError ? .red : .black)
                .onReceive(Just(viewModel.expDate), perform: { output in
                    let filteredString = viewModel.expDate.removeNonNumericChars(exceptions: "/")
                    if viewModel.expDate != filteredString {
                        viewModel.expDate = filteredString
                    }
                    if viewModel.expDate.count > 5 {
                        viewModel.expDate = String(viewModel.expDate.prefix(5))
                    }
                })
            
            REPlaceholderTextField(placeholder: cvvPlaceholder, mainText: $viewModel.cvv, onEditingChanged: { (editingChanged) in
                viewModel.cvvFocus = editingChanged
            }, textFieldFont: textFieldFont, titleLabelFont: titleLabelFont)
                .keyboardType(.numberPad)
                .frame(width: 50, alignment: .leading)
                .padding(.trailing, 5)
                .padding(.leading, -7)
                .onReceive(Just(viewModel.cvv), perform: { output in
                    let filteredString = viewModel.cvv.removeNonNumericChars()
                    if viewModel.cvv != filteredString {
                        viewModel.cvv = filteredString
                    }
                    let ccValidator = CreditCardValidator(viewModel.cardNumber)
                    let cvvLenght = ccValidator.type == .amex ? 4 : 3
                    if viewModel.cvv.count > cvvLenght {
                        viewModel.cvv = String(viewModel.cvv.prefix(cvvLenght))
                    }
                })
            
        }.frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: viewModel.lastCardStatus != .entering ? viewModel.lastTfBorderColor : .clear,
                            radius: viewModel.lastCardStatus != .entering ? 4 : 0, x: 0, y: 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(viewModel.lastTfBorderColor, lineWidth: viewModel.tfBorderWidth)
            )
            .padding(10)
    }
}

struct CreditCardInputUI_Previews: PreviewProvider {
    static var previews: some View {
        RECreditCardInputUI(cardNumberPlaceholder: "Card Number", expDatePlaceholder: "MM/YY", cvvPlaceholder: "CVV")
    }
}
