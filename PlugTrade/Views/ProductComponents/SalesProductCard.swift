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
    @EnvironmentObject var cartManager: FirebaseCartManager
    @EnvironmentObject var favoritesManager: FirebaseFavoritesManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            productImageSection
            titleSection
            sellerSection
            priceSection
        }
        .padding(18)
        .background(cardBackground)
        .shadow(color: Color.blue.opacity(0.4), radius: 20)
        .onAppear { loadSellerAvatar() }
    }
}

private extension SalesProductCard {

    var productImageSection: some View {
        SDWebImageAsync(
            url: URL(string: item.imageURL),
            placeholder: Image(systemName: "photo")
        )
        .frame(height: 180)
        .clipped()
        .cornerRadius(16)
        .overlay(alignment: .bottomTrailing) {
            if item.itemType == .forSale {
                cartButton
            }
        }
    }

    var titleSection: some View {
        Text(item.title)
            .font(.headline)
            .lineLimit(2)
    }

    var sellerSection: some View {
        HStack(spacing: 10) {
            NavigationLink(destination: PublicProfileView(userID: item.sellerID)) {
                AvatarThumb(url: sellerAvatarURL)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.sellerName)
                        .font(.subheadline)
                    Text(item.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 6) {
                Chip(text: "For Sale")
                Chip(text: item.category.rawValue.capitalized)
            }
        }
    }

    var priceSection: some View {
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

    var cartButton: some View {
        Button(action: {
            print("❤️ BUTTON TAPPED!")
            print("User: \(AuthService.shared.currentUser?.id ?? "NO USER")")
            print("Item: \(item.title)")
            favoritesManager.toggleFavorite(item: item)
        }) {
            VStack {
                Image(systemName: favoritesManager.isFavorite(item: item) ? "heart.fill" : "heart")
                    .font(.system(size: 28))
                    .foregroundColor(favoritesManager.isFavorite(item: item) ? .red : .gray)
                Text(favoritesManager.isFavorite(item: item) ? "Saved" : "Save")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(width: 80, height: 60)
            .background(Color.green.opacity(0)) // Visible tap area
        }
        .buttonStyle(PlainButtonStyle())
    }

    var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.25))
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
    }

    func loadSellerAvatar() {
        authService.fetchSeller(id: item.sellerID) { url in
            sellerAvatarURL = url
        }
    }
}

#if DEBUG
struct SalesProductCard_Previews: PreviewProvider {
    static var previews: some View {
        let i = SampleData.items.first { $0.itemType == .forSale }
            ?? SampleData.items[0]

        return SalesProductCard(item: i)
            .environmentObject(AuthService.shared)
            .padding()
            .previewLayout(.sizeThatFits)
            .environmentObject(ProductManager.shared)
            .environmentObject(FirebaseCartManager.shared)
            .environmentObject(FirebaseFavoritesManager())
            
    }
}
#endif
