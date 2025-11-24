//
//  TradeDetailView.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-17.
//

import SwiftUI

struct TradeDetailView: View {
    let item: Item
    @State private var isFavorite = false
    @State private var showProposalSheet = false
    
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var productManager: ProductManager
    @EnvironmentObject private var notificationService: NotificationService
    @EnvironmentObject var favoritesManager: FirebaseFavoritesManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product Image
                SDWebImageAsync(
                    url: URL(string: item.imageURL),
                    placeholder: Image(systemName: "photo")
                )
                .frame(height: 300)
                .clipped()

                
                VStack(alignment: .leading, spacing: 12) {
                    // For Trade Badge
                    HStack {
                        Text("For Trade")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
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
                    
                    // Title
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(item.category.rawValue.capitalized)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                    
                    Divider()
                    
                    // Seller Info
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("Traded by \(item.sellerName)")
                    }
                    .foregroundColor(.gray)
                    
                    // Location
                    HStack {
                        Image(systemName: "location.fill")
                        Text(item.location)
                    }
                    .foregroundColor(.gray)
                    
                    Divider()
                    
                    // Send Request Button
                    let isOwnItem = item.sellerID == authService.currentUser?.id
                    
                    Button(action: {
                        if !isOwnItem {
                            showProposalSheet = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text(isOwnItem ? "Your Own Item" : "Send Trade Request")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isOwnItem ? Color.gray : Color.green)
                        .cornerRadius(12)
                    }
                    .disabled(isOwnItem)
                    .opacity(isOwnItem ? 0.6 : 1.0)
                    
                    if isOwnItem {
                        Text("You cannot send a trade request to your own item")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showProposalSheet) {
            TradeProposalSheet(targetItem: item, isPresented: $showProposalSheet)
                .environmentObject(authService)
                .environmentObject(productManager)
                .environmentObject(notificationService)
        }
    }
}

#if DEBUG
struct TradeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TradeDetailView(item: SampleData.items.first { $0.itemType == .forTrade } ?? SampleData.items[0])
                .environmentObject(AuthService.shared)
                .environmentObject(ProductManager.shared)
                .environmentObject(NotificationService.shared)
                .environmentObject(FirebaseFavoritesManager.shared)
        }
    }
}
#endif

