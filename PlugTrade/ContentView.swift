//
//  ContentView.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authManager = AuthService.shared
    @State private var isLoaded = false
    var body: some View {
        NavigationView {
            Group {
                if !isLoaded {
                    ProgressView()
                        .onAppear {
                            authManager.fetchUser { _ in
                                isLoaded = true
                            }
                        }
                } else  if authManager.currentUser == nil{
                    AuthGate()
                }else{
                    MainTabView()
                }
            }
        }
       
        
       

    }
}

#Preview {
    ContentView()
       
}
