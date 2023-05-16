//
//  CardNumberTextField.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 29/11/21.
//

import SwiftUI
import Combine

/// Recurly Custom Secure TextField for Card Number Input.
public struct RECardNumberTextField: View {
    
    @StateObject private var viewModel = IndividualViewModel()
    private var placeholder: String
    private var onEditingChanged: (Bool) -> Void
    private var textFieldFont: Font
    @Binding var isButtonClicked: Bool
    
    /// Creates a RECardNumberTextField object
    /// - Parameters:
    ///   - placeholder: The placeholder for the Card Number TextField
    ///   - textFieldFont: Optional Textfield Custom Font, Default its ("Inter-Regular", size: 17)
    public init(placeholder: String,
                isButtonClicked: Binding<Bool>,
                onEditingChanged: @escaping (Bool) -> Void = { _ in },
                textFieldFont: Font = Font.custom("Inter-Regular", size: 17)){
        
        self._isButtonClicked = isButtonClicked
        self.placeholder = placeholder
        self.onEditingChanged = onEditingChanged
        self.textFieldFont = textFieldFont
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
        ZStack {
            VStack {
                HStack {
                    Image(viewModel.mainImageName, bundle: Bundle(identifier: "recurly.RecurlySDK-iOS"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 26, alignment: .center)
                        .padding(.leading, 6)

                    TextField("", text: $viewModel.cardNumber, onEditingChanged: didOnEditingChanged(editingChanged:))
                        .placeholder(when: viewModel.cardNumber.isEmpty) {
                            if(viewModel.cardNumber.isEmpty && isButtonClicked){
                                Text(placeholder).foregroundColor(.red)
                            }else{
                                Text(placeholder).foregroundColor(.gray)
                            }
                            
                        }
                        .keyboardType(.numberPad)
                        .foregroundColor(viewModel.lastCardStatus == .error ? .red : .black)
                        .modifier(TextFieldClearButton(text: $viewModel.cardNumber))
                        .font(textFieldFont)
                        .padding(.leading, 0)
                        .onReceive(Just(viewModel.cardNumber)) { _ in
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
                }
                
                Divider()
                    .frame(height: 0.7)
                    .padding(.horizontal, 0)
                    .background(viewModel.cardNumber.isEmpty && isButtonClicked ? Color.red : viewModel.lastTfBorderColor)
            }
        }
        
    }
}
