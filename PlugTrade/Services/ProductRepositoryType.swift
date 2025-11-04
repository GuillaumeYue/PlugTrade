//
//  ProductRepository.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-02.
//

import Foundation
import FirebaseFirestore


protocol ProductRepositoryType {
    func fetchTradeProducts(limit: Int, completion: @escaping (Result<[Product], Error>) -> Void)
}

final class ProductRepository: ProductRepositoryType {
    private let db = Firestore.firestore()
    private let collection = "products"
    
    func fetchTradeProducts(limit: Int = 50,
                            completion: @escaping (Result<[Product], Error>) -> Void) {
        db.collection(collection)
            .whereField("isForTrade", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments { snap, err in
                if let err = err { completion(.failure(err)); return }
                do {
                    let items = try snap?.documents.compactMap { doc in
                        try doc.data(as: Product.self)
                    } ?? []
                    completion(.success(items))
                } catch {
                    completion(.failure(error))
                }
            }
    }
}
