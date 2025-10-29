//
//  ContentView.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            if authManager.firebaseUser == nil {
                RegisterForm()
            }
            else {
                MainTabView()
            }
        }
       

    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
