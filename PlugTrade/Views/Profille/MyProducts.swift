//
//  MyProducts.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-02.
//

import SwiftUI
import AuthenticationServices

struct MyProducts: View {
    @State private var showsaleproducts: Bool = true

    var body: some View {
        VStack {
            Picker("", selection: $showsaleproducts) {
                Text("Products for sale").tag(true)
                Text("Products for trade").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()

            if showsaleproducts {
                ProductsForSale()
                    .environmentObject(ProductManager())
            } else {
                ProductsForTrade()
                    .environmentObject(ProductManager())
            }
        }
    }
}

#Preview {
    MyProducts()
        .environmentObject(ProductManager.shared)
        .environmentObject(AuthService.shared)
}

