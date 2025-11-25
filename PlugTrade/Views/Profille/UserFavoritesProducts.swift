//
//  UserFavoritesProducts.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-23.
//

import SwiftUI

struct UserFavoritesProducts: View {
    @EnvironmentObject var productManager: ProductManager
    @EnvironmentObject var favoritesManager: FirebaseFavoritesManager

    @State private var expandedItemID: String? = nil

    private func createItemKey(for item: Item) -> String {
        let ts = String(item.timestamp.timeIntervalSince1970)
        return "\(item.sellerID)_\(item.title)_\(ts)"
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
    }

    private var favoriteItems: [Item] {
        productManager.items.filter { item in
            favoritesManager.favoriteItemIDs.contains(createItemKey(for: item))
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {

                ForEach(favoriteItems) { item in
                    FavoriteCard(
                        item: item,
                        expandedItemID: $expandedItemID
                    )
                }
            }
            .padding(.top)
        }
        .navigationTitle("Favorites")
        .onAppear {
            productManager.fetchProducts()
            favoritesManager.startListening()
        }
    }
}

private struct FavoriteCard: View {
    let item: Item
    @Binding var expandedItemID: String?

    var isExpanded: Bool { expandedItemID == item.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            header
                .padding(.horizontal)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring()) {
                        expandedItemID = isExpanded ? nil : item.id
                    }
                }

            if isExpanded {
                ExpandedContent(item: item)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.bottom, 10)
            }

            Divider()
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)

                if item.itemType == .forSale {
                    Text("$\(String(format: "%.2f", item.price ?? 0))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("For Trade")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
            }

            Spacer()

            Text(item.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)

            Image(systemName: isExpanded ? "chevron.compact.up" : "chevron.compact.down")
                .font(.caption)
        }
    }
}

private struct ExpandedContent: View {
    @EnvironmentObject var productManager: ProductManager
    @EnvironmentObject var favoritesManager: FirebaseFavoritesManager
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            if item.itemType == .forSale {
                NavigationLink(destination: DetailView(item: item)) {
                    ProductImage(urlString: item.imageURL)
                }
            }else {
                NavigationLink(destination: TradeDetailView(item: item)) {
                    ProductImage(urlString: item.imageURL)
                }
            }
           

            HStack {
                if item.itemType == .forSale {
                    Text("$\(String(format: "%.0f", item.price ?? 0))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                } else {
                    Text("For Trade")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }

                Spacer()
                
                // Favorite Button
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
            .padding(.horizontal)
        }
    }
}

private struct ProductImage: View {
    let urlString: String

    var body: some View {
        SDWebImageAsync(
            url: URL(string: urlString),
            placeholder: Image(systemName: "photo")
        )
        .frame(height: 200)
        .clipped()
        .cornerRadius(8)

    }
}

#Preview {
    UserFavoritesProducts()
        .environmentObject(ProductManager.shared)
        .environmentObject(FirebaseFavoritesManager.shared)
}
