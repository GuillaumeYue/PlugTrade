//
//  DetailView.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-03.
//

//
//  DetailView.swift
//  PlugTrade
//
// MARK:   Created by Evelyne mac on 2025-10-28.
//



import SwiftUI

struct DetailView: View {
    let item: Item
    @State private var isFavorite = false
    @EnvironmentObject var cartManager: FirebaseCartManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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
                    Text("$\(item.price ?? 0.0, specifier: "%.0f")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(item.category.rawValue.capitalized)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("Sold by \(item.sellerName)")
                    }
                    .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "location.fill")
                        Text(item.location)
                    }
                    .foregroundColor(.gray)
                    
                    Divider()
                    
                    Toggle("Save to favorites", isOn: $isFavorite)
                        .tint(.blue)
                    
                    Button(action: {
                        if cartManager.isInCart(item: item) {
                            cartManager.removeFromCart(item: item)
                        } else {
                            cartManager.addToCart(item: item)
                        }
                    }) {
                        HStack {
                            Image(systemName: cartManager.isInCart(item: item) ? "cart.fill" : "cart")
                            Text(cartManager.isInCart(item: item) ? "Remove from Cart" : "Add to Cart")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cartManager.isInCart(item: item) ? Color.red : Color.blue)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(item: SampleData.items[0])
            .environmentObject(FirebaseCartManager())
    }
}
