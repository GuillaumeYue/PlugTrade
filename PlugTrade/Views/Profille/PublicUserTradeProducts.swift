//
//  UserSalesProducts.swift
//  PlugTrade
//
// MARK:  Created by Shaquille O Neil on 2025-11-04.
//

import SwiftUI

struct PublicUserTradeProducts: View {
    
    @EnvironmentObject var productManager: ProductManager
    @EnvironmentObject var favoritesManager: FirebaseFavoritesManager
    let item: Item
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading){
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("For Trade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(item.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.compact.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation (.spring){
                   isExpanded.toggle()
                }
            }
            if isExpanded {
                NavigationLink(destination: TradeItemCard(item: item , onPropose: {})) {
                    SDWebImageAsync(
                        url: URL(string: item.imageURL),
                        placeholder: Image(systemName: "photo")
                    )
                    .frame(height: 250)
                    .clipped()
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(8)
                                Spacer()
                            }
                            .padding()
                        }
                    )
                }
                
                HStack {
                    Text("For Trade")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button(action: {
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
                        .contentShape(Rectangle())   // better tap area
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                
                Divider()
            }
            
           
        }
    }
}

#Preview {
    PublicUserTradeProducts(item: SampleData.items.first!)
        .environmentObject(ProductManager.shared)
        .environmentObject(FirebaseFavoritesManager.shared)
}
