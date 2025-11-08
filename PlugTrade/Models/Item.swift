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

enum ItemTypeEnum: String, CaseIterable, Codable {
    case forSale = "For Sale"
    case forTrade = "For Trade"
}

struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let price: Double?
    let location: String
    let category: Category
    let imageURL: String
    let sellerID: String
    let sellerName: String
    let timestamp: Date
    let quantity: Int
    let itemType: ItemTypeEnum
    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case title
//        case price
//        case location
//        case category
//        case imageURL
//        case sellerID
//        case sellerName
//        case timestamp
//    }
}

struct SampleData {
    static let items: [Item] = [
        Item(id: UUID().uuidString, title: "iPhone 15 Pro", price: 1199, location: "Montreal", category: .mobile, imageURL: "https://via.placeholder.com/300", sellerID: "sample", sellerName: "Eve Lyne", timestamp: Date(),quantity: 3,
        itemType: .forSale),
        Item(id: UUID().uuidString, title: "Samsung Galaxy S24", price: nil, location: "Laval", category: .mobile, imageURL: "https://via.placeholder.com/300", sellerID: "sample", sellerName: "Eve Lyne", timestamp: Date(),quantity: 3,
             itemType: .forTrade),
        Item(id: UUID().uuidString, title: "MacBook Pro 16\"", price: 2499, location: "Montreal", category: .laptop, imageURL: "https://via.placeholder.com/300", sellerID: "sample", sellerName: "Eve Lyne", timestamp: Date(),quantity: 3,
             itemType: .forSale),
        Item(id: UUID().uuidString, title: "Dell XPS 13", price: nil, location: "Longueuil", category: .laptop, imageURL: "https://via.placeholder.com/300", sellerID: "sample", sellerName: "Eve Lyne", timestamp: Date(),quantity: 3,
             itemType: .forTrade),
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
        cartItems
            .filter { $0.itemType == .forSale }   // keep only sale items
            .reduce(0) { total, item in
                total + (item.price ?? 0)         // add price or 0 if nil
            }

        
        
    }
    
    
}
