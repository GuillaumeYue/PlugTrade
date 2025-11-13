//
//  PublicProductsForSale.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-12.
//

import SwiftUI

struct PublicProductsForSale: View {
    @EnvironmentObject var productManager: ProductManager
    let sellerID: String
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(productManager.items.filter {
                    $0.sellerID == sellerID && $0.itemType == .forSale
                }) { item in
                    UserSalesProducts(item: item)
                }
            }
            .padding(.top)
        }
        .onAppear {
            productManager.fetchSellerProducts(for: sellerID)
        }
    }
}


#Preview {
    PublicProductsForSale(sellerID: "iYje6iZ2snZ9ILWzxhPeGBxAp1F2")
        .environmentObject(ProductManager.shared)
}
