//
//  FavoritesView.swift
//  PlugTrade
//created by eve

import SwiftUI

struct FavoritesView: View {
    
    @EnvironmentObject var productManager: ProductManager
    @EnvironmentObject var favoritesManager: FirebaseFavoritesManager
    @EnvironmentObject var cartManager: FirebaseCartManager

    private func createItemKey(for item: Item) -> String {
        let timestampString = String(item.timestamp.timeIntervalSince1970)
        return "\(item.sellerID)_\(item.title)_\(timestampString)"
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
    }

    var favoritedItems: [Item] {
        productManager.items.filter { item in
            let itemKey = createItemKey(for: item)
            return favoritesManager.favoriteItemIDs.contains(itemKey)
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if productManager.isLoading {
                    ProgressView("Loading products...")
                } else if favoritedItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Tap the heart icon on any product to save it here.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(favoritedItems) { item in
                                ProductPost(item: item)
                                    .environmentObject(favoritesManager)
                                    .environmentObject(cartManager)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                productManager.fetchProducts()
                favoritesManager.startListening()
            }
        }
    }
}

//preview
#Preview {
    FavoritesView()
        .environmentObject(ProductManager())
        .environmentObject(FirebaseFavoritesManager())
}
