//
//  CVVTextField.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 29/11/21.
//

import SwiftUI
import Combine

/// Recurly Custom Secure TextField for CVV Input.
public struct RECVVTextField: View {
    
    @StateObject private var viewModel = IndividualViewModel()
    private var placeholder: String
    private var onEditingChanged: (Bool) -> Void
    private var textFieldFont: Font
    
    /// Creates a RECardNumberTextField object
    /// - Parameters:
    ///   - placeholder: The placeholder for the Card Number TextField
    ///   - textFieldFont: Optional Textfield Custom Font, Default its ("Inter-Regular", size: 17)
    public init(placeholder: String,
                onEditingChanged: @escaping (Bool) -> Void = { _ in },
                textFieldFont: Font = Font.custom("Inter-Regular", size: 17)){
        
        self.placeholder = placeholder
        self.onEditingChanged = onEditingChanged
        self.textFieldFont = textFieldFont
    }
    
    public var body: some View {
        ZStack {
            VStack {
                
                TextField("", text: $viewModel.cvv, onEditingChanged: onEditingChanged)
                    .placeholder(when: viewModel.cvv.isEmpty) {
                        Text(placeholder).foregroundColor(.gray)
                    }
                    .keyboardType(.numberPad)
                    .foregroundColor(viewModel.cardStatus == .error ? .red : .black)
                    .modifier(TextFieldClearButton(text: $viewModel.cvv))
                    .font(textFieldFont)
                    .padding(.leading, 0)
                    .onReceive(Just(viewModel.cvv)) { _ in
                        let filteredString = viewModel.cvv.removeNonNumericChars()
                        if viewModel.cvv != filteredString {
                            viewModel.cvv = filteredString
                        }
                        let ccValidator = CreditCardValidator(RETokenizationManager.shared.cardData.number)
                        let cvvLenght = ccValidator.type == .amex ? 4 : 3
                        if viewModel.cvv.count > cvvLenght {
                            viewModel.cvv = String(viewModel.cvv.prefix(cvvLenght))
                        }
                    }
                
                Divider()
                    .frame(height: 0.7)
                    .background(viewModel.tfBorderColor)
            }
        }
    }
}
