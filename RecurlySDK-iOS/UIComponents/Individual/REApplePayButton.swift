//
//  REApplePayButton.swift
//  RecurlySDK-iOS
//
//  Created by Carlos Landaverde on 14/1/22.
//

import SwiftUI
import PassKit

public struct REApplePayButton: View {
    var action: () -> Void
    
    var height: Double {
        #if os(macOS)
        return 30
        #else
        return 45
        #endif
    }
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Representable(action: action)
            .frame(minWidth: 100, maxWidth: 400)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .accessibility(label: Text("Buy with Apple Pay", comment: "Accessibility label for Buy with Apple Pay button"))
    }
}

extension REApplePayButton {
    #if os(iOS)
    typealias ViewRepresentable = UIViewRepresentable
    #else
    typealias ViewRepresentable = NSViewRepresentable
    #endif
    
    public struct Representable: ViewRepresentable {
        var action: () -> Void
        
        public func makeCoordinator() -> Coordinator {
            Coordinator(action: action)
        }
        
        #if os(iOS)
        public func makeUIView(context: Context) -> UIView {
            context.coordinator.button
        }
        
        public func updateUIView(_ rootView: UIView, context: Context) {
            context.coordinator.action = action
        }
        #else
        public func makeNSView(context: Context) -> NSView {
            context.coordinator.button
        }
        
        public func updateNSView(_ rootView: NSView, context: Context) {
            context.coordinator.action = action
        }
        #endif
    }
    
    open class Coordinator: NSObject {
        var action: () -> Void
        var button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        
        public init(action: @escaping () -> Void) {
            self.action = action
            super.init()
            
            #if os(iOS)
            button.addTarget(self, action: #selector(callback(_:)), for: .touchUpInside)
            #else
            button.action = #selector(callback(_:))
            button.target = self
            #endif
        }
        
        @objc
        func callback(_ sender: Any) {
            action()
        }
    }
    
}

struct PaymentButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            REApplePayButton(action: {})
                .padding()
                .preferredColorScheme(.light)
            REApplePayButton(action: {})
                .padding()
                .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
