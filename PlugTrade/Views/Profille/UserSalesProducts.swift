//
//  UserSalesProducts.swift
//  PlugTrade
//
// MARK:  Created by Shaquille O Neil on 2025-11-04.
//

import SwiftUI

struct UserSalesProducts: View {
    
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
                    
                    Text("$\(item.price ?? 0, specifier: "%.2f")")
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
                NavigationLink(destination: DetailView(item: item)) {
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
                    Text("$\(item.price ?? 0, specifier: "%.0f")")
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
    UserSalesProducts(item: SampleData.items.first!)
        .environmentObject(ProductManager.shared)
}
