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
            if authManager.user != nil {
               //HomeView
                MainTabView()
           }
           else {
               //show login or register view
               RegisterForm()
           }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
