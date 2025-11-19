//
//  PlugTradeApp.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct PlugTradeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // CREATE THE GLOBALS HERE
    @StateObject private var authService = AuthService.shared
    @StateObject private var productManager = ProductManager.shared
    @StateObject private var firebaseCart = FirebaseCartManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(productManager)
                .environmentObject(firebaseCart)
                .onAppear {
                    productManager.fetchUserProducts()
                }
        }
    }
}

