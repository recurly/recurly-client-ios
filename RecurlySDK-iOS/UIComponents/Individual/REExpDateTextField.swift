//
//  ExpDateTextField.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 29/11/21.
//

import SwiftUI
import Combine

/// Recurly Custom Secure TextField for ExpDate Input.
public struct REExpDateTextField: View {
    
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
    
    public var body: some View {
        ZStack {
            VStack {
                
                TextField("", text: $viewModel.expDate, onEditingChanged: onEditingChanged)
                    .placeholder(when: viewModel.expDate.isEmpty) {
                        if(viewModel.expDate.isEmpty && isButtonClicked){
                            Text(placeholder).foregroundColor(.red)
                        }else{
                            Text(placeholder).foregroundColor(.gray)
                        }
                        
                    }
                    .keyboardType(.numberPad)
                    .foregroundColor(viewModel.expDateError ? .red : .black)
                    .modifier(TextFieldClearButton(text: $viewModel.expDate))
                    .font(textFieldFont)
                    .padding(.leading, 0)
                    .onReceive(Just(viewModel.expDate)) { _ in
                        let filteredString = viewModel.expDate.removeNonNumericChars(exceptions: "/")
                        if viewModel.expDate != filteredString {
                            viewModel.expDate = filteredString
                        }
                        if viewModel.expDate.count > 5 {
                            viewModel.expDate = String(viewModel.expDate.prefix(5))
                        }
                    }
                
                Divider()
                    .frame(height: 0.7)
                    .background(viewModel.expDate.isEmpty && isButtonClicked ? Color.red : viewModel.lastTfBorderColor)
            }
        }
    }
}
