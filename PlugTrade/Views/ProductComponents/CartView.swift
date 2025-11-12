//
//  CartView.swift
//  PlugTrade
//
// MARK:   Created by Evelyne mac on 2025-10-28.
//


import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: FirebaseCartManager
    @State private var showCheckout = false
    
    var body: some View {
        NavigationView {
            VStack {
                if cartManager.cartItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("Your cart is empty")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Add items to get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(cartManager.cartItems) { item in
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: item.imageURL)) { phase in
                                    switch phase {
                                    case .empty:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                            .overlay(ProgressView())
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                    case .failure:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                            .overlay(Image(systemName: "photo"))
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.headline)
                                    Text("$\(item.price ?? 0.0, specifier: "%.0f" )")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    cartManager.removeFromCart(item: item)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 16) {
                        Divider()
                        
                        HStack {
                            Text("Total:")
                                .font(.headline)
                            Spacer()
                            Text("$\(cartManager.totalPrice, specifier: "%.0f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            showCheckout = true
                        }) {
                            Text("Checkout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Cart")
            .alert("Checkout", isPresented: $showCheckout) {
                Button("OK") {}
            } message: {
                Text("Checkout functionality coming soon!")
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(FirebaseCartManager())
    }
}
