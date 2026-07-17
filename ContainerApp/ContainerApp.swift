//
//  ContainerApp.swift
//  ContainerApp
//

import SwiftUI
import RecurlySDK

@main
struct ContainerApp: App {
    
    // MARK: - Initializers
    
    init() {
        // Initialization of Recurly SDK
        RecurlyConfiguration.shared.initialize(publicKey: "YOUR-PUBLIC-KEY")
    }
    
    var body: some Scene {

        // Main Container View
        WindowGroup {
            ContentView()
        }
    }
}
