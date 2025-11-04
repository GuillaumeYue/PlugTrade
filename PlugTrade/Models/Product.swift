


//
//  Product.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-02.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var detail: String?
    var price: Double?
    var imageURL: String?
    var isForTrade: Bool
    var ownerId: String?
    var createdAt: Date?
    
    init(id: String? = nil,
         title: String = "",
         detail: String? = nil,
         price: Double? = nil,
         imageURL: String? = nil,
         isForTrade: Bool = false,
         ownerId: String? = nil,
         createdAt: Date? = nil) {
        self.id = id
        self.title = title
        self.detail = detail
        self.price = price
        self.imageURL = imageURL
        self.isForTrade = isForTrade
        self.ownerId = ownerId
        self.createdAt = createdAt
    }
}

