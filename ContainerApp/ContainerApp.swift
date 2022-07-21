//
//  ContainerApp.swift
//  ContainerApp
//
//  Created by David Figueroa on 22/11/21.
//

import SwiftUI
import RecurlySDK_iOS

@main
struct ContainerApp: App {
    
    // MARK: - Initializers
    
    init() {
        // Initialization of Recurly SDK
        REConfiguration.shared.initialize(publicKey: "ewr1-ulY3A5cxeTUlcZv44awb6U")
    }
    
    var body: some Scene {

        // Main Container View
        WindowGroup {
            ContentView()
        }
    }
}
