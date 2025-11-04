//
//  ProductManager.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-03.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine
import FirebaseAuth

class ProductManager: ObservableObject {
    static let shared = ProductManager()
    
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var userProducts: [Item] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        fetchProducts()
    }
    
    func fetchProducts() {
        isLoading = true
        db.collection("products")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                self.isLoading = false
                
                if let error = error {
                    print("Error fetching products: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No products found")
                    return
                }
                
                self.items = documents.compactMap { doc in
                    try? doc.data(as: Item.self)
                }
                
                print("Fetched \(self.items.count) products from Firebase")
            }
    }
    
    func fetchUserProducts() {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("No user logged in.")
                return
            }

            db.collection("products")
                .whereField("sellerID", isEqualTo: userID)
//                .order(by: "timestamp", descending: true)
                .getDocuments { [weak self] snapshot, error in
                    if let error = error {
                        print("Error fetching user products: \(error)")
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("No products found.")
                        return
                    }

                    do {
                        self?.userProducts = try documents.map { doc in
                            try doc.data(as: Item.self)
                        }
                    } catch {
                        print("Error decoding items: \(error)")
                    }
                }
        }

    
    
    func addProduct(title: String, price: Double, location: String, category: Category, image: Data?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = AuthService.shared.currentUser?.id,
              let userName = AuthService.shared.currentUser?.name else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        if let imageData = image {
            uploadImage(imageData) { result in
                switch result {
                case .success(let imageURL):
                    self.saveProduct(title: title, price: price, location: location, category: category, imageURL: imageURL, sellerID: userID, sellerName: userName, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            saveProduct(title: title, price: price, location: location, category: category, imageURL: "https://via.placeholder.com/300", sellerID: userID, sellerName: userName, completion: completion)
        }
    }
    
    private func uploadImage(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let imageName = UUID().uuidString
        let imageRef = storage.reference().child("product_images/\(imageName).jpg")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get image URL"])))
                }
            }
        }
    }
    
    private func saveProduct(title: String, price: Double, location: String, category: Category, imageURL: String, sellerID: String, sellerName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let product = Item(
            id: nil,
            title: title,
            price: price,
            location: location,
            category: category,
            imageURL: imageURL,
            sellerID: sellerID,
            sellerName: sellerName,
            timestamp: Date()
        )
        
        do {
            try db.collection("products").addDocument(from: product) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print("Product added successfully!")
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

