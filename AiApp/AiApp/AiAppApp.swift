//
//  AiAppApp.swift
//  AiApp
//
//  Created by Nguyen, Sydney on 4/9/25.
//

import SwiftUI

@main
struct AiAppApp: App {
    @StateObject private var settings = AppSettings() // Initialize the AppSettings object here

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings) // Pass settings to the root view
                .onAppear {
                    print("App has launched and settings are initialized.")
                }
        }
    }
}

