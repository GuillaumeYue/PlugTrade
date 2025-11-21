//
//  TabView.swift
//  PlugTrade
//
// MARK: Created by S.Neil Created by Shaquille O Neil on 2025-10-26.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject private var cartManager: FirebaseCartManager
    @EnvironmentObject private var productManager: ProductManager
    
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
//            SearchScreen()
//                .tabItem {
//                    Image(systemName: "magnifyingglass")
//                    Text("Search")
//                }
            SalesItemScreen()
                .tabItem {
                    Image(systemName: "dollarsign")
                    Text("Sales")
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

//#Preview {
//    MainTabView()
//        
//       
//}
