//
//  Item.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-03.
//


import Foundation
import FirebaseFirestore

enum Category: String, CaseIterable, Codable {
    case all = "All"
    case mobile = "mobile"
    case laptop = "laptop"
    case watch = "watch"
    case headsets = "headsets"
    case ipad = "ipad"
    case other = "other"
}

struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let price: Double
    let location: String
    let category: Category
    let imageURL: String
    let sellerID: String
    let sellerName: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case price
        case location
        case category
        case imageURL
        case sellerID
        case sellerName
        case timestamp
    }
}

struct SampleData {
    static let items: [Item] = [
        Item(id: UUID().uuidString, title: "iPhone 15 Pro", price: 1199, location: "Montreal", category: .mobile, imageURL: "https://via.placeholder.com/300", sellerID: "sample", sellerName: "Eve Lyne", timestamp: Date()),
        Item(id: UUID().uuidString, title: "Samsung Galaxy S24", price: 999, location: "Laval", category: .mobile, imageURL: "https://via.placeholder.com/300", sellerID: "sample", sellerName: "Eve Lyne", timestamp: Date()),
        Item(id: UUID().uuidString, title: "MacBook Pro 16\"", price: 2499, location: "Montreal", category: .laptop, imageURL: "https://via.placeholder.com/300", sellerID: "sample", sellerName: "Eve Lyne", timestamp: Date()),
        Item(id: UUID().uuidString, title: "Dell XPS 13", price: 1499, location: "Longueuil", category: .laptop, imageURL: "https://via.placeholder.com/300", sellerID: "sample", sellerName: "Eve Lyne", timestamp: Date()),
    ]
}

class CartManager: ObservableObject {
    @Published var cartItems: [Item] = []
    
    func addToCart(item: Item) {
        if !cartItems.contains(where: { $0.id == item.id }) {
            cartItems.append(item)
        }
    }
    
    func removeFromCart(item: Item) {
        cartItems.removeAll { $0.id == item.id }
    }
    
    func isInCart(item: Item) -> Bool {
        cartItems.contains { $0.id == item.id }
    }
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.price }
        
        
    }
    
    
}
