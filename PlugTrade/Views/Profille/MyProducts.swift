//
//  MyProducts.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-02.
//

import SwiftUI
import AuthenticationServices

enum ProductTab: String, CaseIterable{
    case Sale
    case Trade
    case Favorites
}

struct MyProducts: View {
    @State private var selectedTab: ProductTab = .Sale

    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Text("Products for sale").tag(ProductTab.Sale)
                Text("Products for trade").tag(ProductTab.Trade)
                Text("Favorites").tag(ProductTab.Favorites)
            }
            .pickerStyle(.segmented)
            .padding()

            switch selectedTab {
            case .Sale:
                ProductsForSale()
            case .Trade:
                ProductsForTrade()
            case .Favorites:
                UserFavoritesProducts()
            }
        }
    }
}

#Preview {
    MyProducts()
        .environmentObject(ProductManager.shared)
        .environmentObject(AuthService.shared)
}

