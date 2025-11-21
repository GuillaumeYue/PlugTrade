//
//  TradeItemCard.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-09.
//

import SwiftUI

struct SalesProductCard: View {
    let item: Item

    @State private var sellerAvatarURL: String? = nil
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SDWebImageAsync(
                url: URL(string: item.imageURL),
                placeholder: Image(systemName: "photo")
            )
            .frame(height: 180)
            .clipped()
            .cornerRadius(16)

            Text(item.title)
                .font(.headline)
                .lineLimit(2)

            
            HStack(spacing: 10) {
                NavigationLink(destination: PublicProfileView(userID: item.sellerID)){
                    
                    AvatarThumb(url: sellerAvatarURL)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.sellerName).font(.subheadline)
                        Text(item.location).font(.caption).foregroundColor(
                            .secondary
                        )
                    }
                }
                Spacer()
                HStack(spacing: 6) {
                    Chip(text: "For Sale")
                    Chip(text: item.category.rawValue.capitalized)
                }
            }
            
            HStack(spacing: 6) {
                Image(systemName: "cart.badge.plus.fill")
                    .font(.title3)
                    .foregroundColor(.white)

                Text("$\(item.price ?? 0.0, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.gradient)
            )
            
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.25))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.blue.opacity(0.4), radius: 20)
        .onAppear {
            
                authService.fetchSeller(id: item.sellerID) { url in
                    sellerAvatarURL = url
                }
//            }
//
            
        }
    }
}

#if DEBUG
    struct SalesProductCard_Previews: PreviewProvider {
        static var previews: some View {
            let i =
                SampleData.items.first { $0.itemType == .forSale }
                ?? SampleData.items[0]
            return SalesProductCard(item: i)
                .environmentObject(AuthService.shared)
                .padding()
                .previewLayout(.sizeThatFits)
                .environmentObject(ProductManager.shared)
        }
    }
#endif

