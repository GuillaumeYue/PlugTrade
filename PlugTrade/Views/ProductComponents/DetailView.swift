

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
    @EnvironmentObject var favoritesManager: FirebaseFavoritesManager
    @State private var quantity = 1
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                SDWebImageAsync(
                    url: URL(string: item.imageURL),
                    placeholder: Image(systemName: "photo")
                )
                .scaledToFill()
                .frame(height: 300)
                .clipped()

                VStack(alignment: .leading, spacing: 12) {

                    HStack {
                        Text("$\(item.price ?? 0.0, specifier: "%.0f")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)

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
                            .background(Color.green.opacity(0))
                        }
                        .buttonStyle(.plain)
                    }

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

                    HStack {
                        Text("Quantity:")
                        QuantityPicker(quantity: $quantity, maxQuantity: item.quantity)
                    }

                    Button(action: {
                        if cartManager.isInCart(item: item) {
                            cartManager.removeFromCart(item: item)
                        } else {
                            cartManager.addToCart(item: item, quantity: quantity)
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

struct QuantityPicker: View {
    @Binding var quantity: Int
    let maxQuantity: Int
    
    var body: some View {
        HStack {
            Button(action: {
                if self.quantity > 1 {
                    self.quantity -= 1
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(Color.blue)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("\(quantity)")
                .font(.title2)
            
            Button(action: {
                if self.quantity < self.maxQuantity {
                    self.quantity += 1
                }
            }) {
                Image(systemName: "plus.circle.fill")
            }
        }.padding(.vertical)
    }
    
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(item: SampleData.items[0])
            .environmentObject(FirebaseCartManager.shared)
            .environmentObject(FirebaseFavoritesManager())

    }
}
