//
//  CartItem.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-21.
//

import Foundation
import FirebaseFirestore

struct CartItem: Identifiable, Codable {
    @DocumentID var id: String?
    
    var title: String
    var price: Double
    var location: String
    var category: String
    var imageURL: String
    var sellerID: String
    var sellerName: String
    var timestamp: Timestamp?
    
    var quantity: Int
    var stock: Int
}

