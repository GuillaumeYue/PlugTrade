//
//  PublicProductsForSale.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-12.
//

import SwiftUI

struct PublicProductsForTrade: View {
    @ObservedObject var fetcher: PublicSellerProducts
    let sellerID: String
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(fetcher.tradeItems) { item in
                    PublicUserTradeProducts(item: item)
                }
            }
            .padding()
        }
        .onAppear {
            fetcher.load(for: sellerID)
        }
    }
}



#Preview {
    PublicProductsForTrade(
        fetcher: PublicSellerProducts(),
        sellerID: "iYje6iZ2snZ9ILWzxhPeGBxAp1F2"
    )
}

