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
    @Published var userProductsLoaded = false
    @Published var userProductsLoading = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var userProductsListener: ListenerRegistration?
    
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
        guard let uid = Auth.auth().currentUser?.uid else {
            stopUserProductsListener()
            return
        }
        if userProductsListener != nil { return }  

        userProductsLoading = true
        userProductsLoaded  = false

        userProductsListener = db.collection("products")
            .whereField("sellerID", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("User products listener error:", err.localizedDescription)
                    DispatchQueue.main.async {
                        self.userProducts = []
                        self.userProductsLoading = false
                        self.userProductsLoaded  = true
                    }
                    return
                }
                let items = snap?.documents.compactMap { try? $0.data(as: Item.self) } ?? []
                DispatchQueue.main.async {
                    self.userProducts = items
                    self.userProductsLoading = false
                    self.userProductsLoaded  = true
                }
            }
    }

    func stopUserProductsListener() {
        userProductsListener?.remove()
        userProductsListener = nil
        DispatchQueue.main.async {
            self.userProducts = []
            self.userProductsLoading = false
            self.userProductsLoaded = false
        }
    }



    
    
    func addProduct(
        title: String,
        price: Double?,
        location: String,
        category: Category,
        image: Data?,
        quantity: Int,
        itemType: ItemTypeEnum,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        let name = AuthService.shared.currentUser?.name ?? "User"

        let save: (String) -> Void = { [weak self] imageURL in
            guard let self = self else { return }
            self.saveProduct(
                title: title,
                // 以物易物不存价格；出售正常存价格
                price: (itemType == .forTrade) ? nil : price,
                location: location,
                category: category,
                imageURL: imageURL,
                sellerID: uid,          // ✅ 与查询使用同一 UID
                sellerName: name,
                quantity: quantity,
                itemType: itemType,
                completion: completion
            )
        }

        if let imageData = image {
            uploadImage(imageData) { result in
                switch result {
                case .success(let url): save(url)
                case .failure(let err): completion(.failure(err))
                }
            }
        } else {
            save("https://via.placeholder.com/300")
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
    
    private func saveProduct(title: String, price: Double?, location: String, category: Category, imageURL: String, sellerID: String, sellerName: String, quantity: Int,itemType: ItemTypeEnum, completion: @escaping (Result<Void, Error>) -> Void) {
        let product = Item(
            id: nil,
            title: title,
            price: price,
            location: location,
            category: category,
            imageURL: imageURL,
            sellerID: sellerID,
            sellerName: sellerName,
            timestamp: Date(),
            quantity: quantity,
            itemType: itemType
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

