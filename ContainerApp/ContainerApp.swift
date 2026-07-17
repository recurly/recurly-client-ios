//
//  ContainerApp.swift
//  ContainerApp
//

import SwiftUI
import RecurlySDK_iOS

@main
struct ContainerApp: App {
    
    // MARK: - Initializers
    
    init() {
        // Initialization of Recurly SDK
        REConfiguration.shared.initialize(publicKey: "YOUR-PUBLIC-KEY")
    }
    
    var body: some Scene {

        // Main Container View
        WindowGroup {
            ContentView()
        }
    }
}
