//
//  ContentView.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-24.
//

import FirebaseAuth
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthService
    @State private var isLoaded = false
    @EnvironmentObject var productManager: ProductManager
    var body: some View {
        NavigationView {
            Group {
                if !isLoaded {
                    ProgressView()
                        .onAppear {
                            authManager.fetchUser { _ in
                                isLoaded = true
                                //preheat listening
                                if Auth.auth().currentUser != nil {
                                    productManager.fetchUserProducts()
                                }
                            }
                        }
                        .environmentObject(NotificationService.shared)
                } else if authManager.currentUser == nil {
                    AuthGate()
                } else {
                    MainTabView()
                        // another at main page load listening
                        .onAppear {
                            productManager.fetchUserProducts()
                            NotificationService.shared.startListening()
                        }
                }
            }
        }
        // Log in/ out change listening
        .onChange(of: authManager.currentUser?.id) { _ in
            if Auth.auth().currentUser != nil {
                productManager.fetchUserProducts()
                NotificationService.shared.startListening()
            } else {
                productManager.stopUserProductsListener()
                NotificationService.shared.stopListening()
            }
        }
    }
}

#Preview {
    ContentView()

}
