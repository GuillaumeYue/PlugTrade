//
//  ProductManager.swift
//  PlugTrade
//
// MARK:  Created Evelyne on 2025-11-03.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine
import FirebaseAuth
import SDWebImage

class ProductManager: ObservableObject {
    static let shared = ProductManager()
    
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var userProducts: [Item] = []
    @Published var MyProducts: [Item] = []
    @Published var userProductsLoaded = false
    @Published var userProductsLoading = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var userProductsListener: ListenerRegistration?
    
    init() {
        fetchProducts()
    }
    
    // MARK: Created by S.Neil
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
                
                self.preloadImages()
                
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
    
    
    
    
    func fetchMyProducts() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let query = db.collection("products").whereField("sellerID", isEqualTo: uid)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            
            guard let documents = snapshot?.documents else {
                self.MyProducts = []
                return
            }
            self.MyProducts = documents.compactMap { try? $0.data(as: Item.self) }
        }
    }
    // MARK: end of creation
    
    
    // MARK: Created by Han

    func stopUserProductsListener() {
        userProductsListener?.remove()
        userProductsListener = nil
        DispatchQueue.main.async {
            self.userProducts = []
            self.userProductsLoading = false
            self.userProductsLoaded = false
        }
    }
    // MARK: end of creation by Han

    func addProduct(
        title: String,
        price: Double?,
        location: String,
        category: Category,
        image: Data?,
        quantity: Int,
    lookingFor: [String]?,
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
                sellerID: uid,          // 与查询使用同一 UID
                sellerName: name,
                quantity: quantity,
                lookingFor: lookingFor,
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
            save("")
        }
    }
    
    
    // MARK: Created by S.Neil
    func fetchSellerProducts(for sellerID: String) {
        isLoading = true
        db.collection("products")
            .whereField("sellerID", isEqualTo: sellerID)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        print("Error fetching seller products: \(error.localizedDescription)")
                        return
                    }
                    self.userProducts = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Item.self)
                    } ?? []
                }
            }
    }
    
    // MARK: end of creation by S.Neil


    
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
                    // update the product.imageurl in the firestore database.
                    completion(.success(urlString))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get image URL"])))
                }
            }
        }
    }
    
    private func saveProduct(title: String, price: Double?, location: String, category: Category, imageURL: String, sellerID: String, sellerName: String, quantity: Int, lookingFor: [String]?,itemType: ItemTypeEnum, completion: @escaping (Result<Void, Error>) -> Void) {
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
            lookingfor: lookingFor,
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
    
    
    func preloadImages() {
        for item in items {
            let urlString = item.imageURL
            guard let url = URL(string: urlString) else { continue }

            
            if ImageCache.shared.get(urlString) != nil { continue }

            
            SDWebImageDownloader.shared.downloadImage(with: url) { img, _, _, _ in
                if let img = img {
                    ImageCache.shared.set(urlString, img)
                }
            }
        }
    }


}

