//
//  REPlaceholderTextView.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 22/11/21.
//

import SwiftUI

struct REPlaceholderTextField: View {
    
    @Binding public var mainText: String
    private var placeholder: String
    private var onEditingChanged: (Bool) -> Void
    private var textFieldFont: Font
    private var titleLabelFont: Font

    init(placeholder: String,
         mainText: Binding<String>,
         onEditingChanged: @escaping (Bool) -> Void = { _ in },
         textFieldFont: Font, 
         titleLabelFont: Font){
        
        self._mainText = mainText
        self.placeholder = placeholder
        self.onEditingChanged = onEditingChanged
        self.textFieldFont = textFieldFont
        self.titleLabelFont = titleLabelFont
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !mainText.isEmpty {
                Text(placeholder)
                    .font(titleLabelFont)
                    .foregroundColor(Color.gray)
                    .padding(10)
                    .padding(.bottom, -15)
            }
            
            TextField("", text: _mainText, onEditingChanged: onEditingChanged)
                .placeholder(when: mainText.isEmpty) {
                        Text(placeholder).foregroundColor(.gray)
                }
                .font(textFieldFont)
                .padding(.leading, 10)
                .truncationMode(.tail)
                .padding(.bottom, mainText.isEmpty ? 0 : 10)
        }
    }
}
