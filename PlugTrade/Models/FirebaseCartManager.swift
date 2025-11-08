//
//  FirebaseCartManager.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-03.
//


import Foundation
import FirebaseFirestore
import Combine

class FirebaseCartManager: ObservableObject {
    @Published var cartItems: [Item] = []
    
    private let db = Firestore.firestore()
    
    init() {
        fetchCart()
    }
    
    func fetchCart() {
        guard let userID = AuthService.shared.currentUser?.id else { return }
        
        db.collection("users").document(userID).collection("cart")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching cart: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.cartItems = documents.compactMap { doc in
                    try? doc.data(as: Item.self)
                }
            }
    }
    
    func addToCart(item: Item) {
        guard let userID = AuthService.shared.currentUser?.id,
              let itemID = item.id else { return }
        
        if !cartItems.contains(where: { $0.id == item.id }) {
            do {
                try db.collection("users").document(userID).collection("cart").document(itemID).setData(from: item)
            } catch {
                print("Error adding to cart: \(error.localizedDescription)")
            }
        }
    }
    
    func removeFromCart(item: Item) {
        guard let userID = AuthService.shared.currentUser?.id,
              let itemID = item.id else { return }
        
        db.collection("users").document(userID).collection("cart").document(itemID).delete()
    }
    
    func isInCart(item: Item) -> Bool {
        cartItems.contains { $0.id == item.id }
    }
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + ($1.price ?? 0.0 )}
           
    }
}

