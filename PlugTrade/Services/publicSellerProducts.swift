//
//  publicSellerProducts.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-24.
//

import Foundation
import FirebaseFirestore

class PublicSellerProducts: ObservableObject {
    @Published var saleItems: [Item] = []
    @Published var tradeItems: [Item] = []

    private let db = Firestore.firestore()

    func load(for sellerID: String) {
        db.collection("products")
            .whereField("sellerID", isEqualTo: sellerID)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in

                let items = snapshot?.documents.compactMap {
                    try? $0.data(as: Item.self)
                } ?? []

                DispatchQueue.main.async {
                    self.saleItems  = items.filter { $0.itemType == .forSale }
                    self.tradeItems = items.filter { $0.itemType == .forTrade }
                }
            }
    }
}

