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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product Image
                AsyncImage(url: URL(string: item.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(Image(systemName: "photo"))
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    // For Trade Badge
                    HStack {
                        Text("For Trade")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        // Category Badge
                        Text(item.category.rawValue.capitalized)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                    
                    // Title
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
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
                    
                    // Favorites Toggle
                    Toggle("Save to favorites", isOn: $isFavorite)
                        .tint(.green)
                    
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
        }
    }
}
#endif

