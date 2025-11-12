//
//  UserSalesProducts.swift
//  PlugTrade
//
// MARK:  Created by Shaquille O Neil on 2025-11-04.
//

import SwiftUI

struct PublicUserTradeProducts: View {
    
    @EnvironmentObject var productManager: ProductManager
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
                    AsyncImage(url: URL(string: item.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                                .overlay(Image(systemName: "photo"))
                        @unknown default:
                            EmptyView()
                        }
                    }
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
                    
                    HStack(spacing: 16) {
                        Image(systemName: "heart")
                        Image(systemName: "message")
                        Image(systemName: "cart")
                    }
                    .font(.title3)
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
}
