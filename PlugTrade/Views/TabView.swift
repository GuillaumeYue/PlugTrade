//
//  TabView.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//

import SwiftUI

struct MainTabView: View {
    
    @StateObject private var cartManager = FirebaseCartManager()
    @StateObject private var productManager = ProductManager.shared
    
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            SearchScreen()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            ListProductScreen()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("List")
                }
            TradeScreen()
                .tabItem {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                    Text("Trade")
                }
            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
            
           
        }
        .environmentObject(cartManager)
        .environmentObject(productManager)
    }
}

#Preview {
    MainTabView()
       
}
