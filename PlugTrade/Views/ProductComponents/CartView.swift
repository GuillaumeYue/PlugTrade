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
                        ForEach(cartManager.cartItems) { cartitem in
                            HStack(spacing: 12) {
                                
                                SDWebImageAsync(
                                    url: URL(string: cartitem.imageURL),
                                    placeholder: Image(systemName: "photo")
                                )
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(cartitem.title)
                                        .font(.headline)

                                    Text("$\(cartitem.price, specifier: "%.0f")")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)

                                    CartQuantityPicker(
                                        quantity: cartitem.quantity,
                                        maxQuantity: cartitem.stock,
                                        onIncrement: { cartManager.updateQuantity(cartItem: cartitem, amount: +1) },
                                        onDecrement: { cartManager.updateQuantity(cartItem: cartitem, amount: -1) }
                                    )
                                    .padding(.top, 4)
                                }

                                Spacer()

                                Button(action: {
                                    cartManager.removeFromCart(cartItem: cartitem)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.borderless)
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
                            cartManager.processAllPurchases{
                                success in
                                if success {
                                    cartManager.emptyCart()
                                    showCheckout = true
                                }else{
                                    print("Error")
                                }
                            }
                           
                           
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
                Text("Thank you for your purchase!")
            }
        }
    }



    
struct CartQuantityPicker: View {
    let quantity: Int
    let maxQuantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                if quantity > 1 {
                    onDecrement()
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.borderless)
            
            Text("\(quantity)")
                .font(.title3)
                .frame(width: 28)
            
            Button(action: {
                if quantity < maxQuantity {
                    onIncrement()
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.borderless)
        }
    }
}



struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(FirebaseCartManager.shared)
    }
}
