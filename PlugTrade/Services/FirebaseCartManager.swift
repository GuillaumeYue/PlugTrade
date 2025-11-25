import Foundation
import FirebaseFirestore
import Combine

class FirebaseCartManager: ObservableObject {
    static let shared = FirebaseCartManager()

    @Published var cartItems: [CartItem] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private init() {}

    func startListening() {
        listener?.remove()

        guard let userID = AuthService.shared.currentUser?.id else { return }

        listener = db.collection("users")
            .document(userID)
            .collection("cart")
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("Cart listener error:", error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                print("Cart updated — \(documents.count) items")

                self.cartItems = documents.compactMap { doc in
                    try? doc.data(as: CartItem.self)
                }
            }
    }

    // MARK: ADD TO CART — USES Item (not CartItem)
    func addToCart(item: Item, quantity: Int) {
        guard let userID = AuthService.shared.currentUser?.id,
              let itemID = item.id else { return }
        
        let cartRef = db.collection("users")
            .document(userID)
            .collection("cart")
            .document(itemID)
        
        cartRef.getDocument { snapshot, error in
            if let error = error {
                print("Error checking cart:", error)
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                print("Item already in cart, increasing quantity by \(quantity)")
                
                cartRef.updateData([
                    "quantity": FieldValue.increment(Int64(quantity))
                ]) { error in
                    if let error = error {
                        print("Failed to update quantity:", error)
                    } else {
                        print("Quantity updated successfully")
                    }
                }
                
            } else {
                print("Adding NEW item to cart with quantity \(quantity)")
                
                let data: [String: Any] = [
                    "category": item.category.rawValue,
                    "imageURL": item.imageURL,
                    "location": item.location,
                    "price": item.price ?? 0,
                    "sellerID": item.sellerID,
                    "sellerName": item.sellerName,
                    "timestamp": Timestamp(date: item.timestamp),
                    "title": item.title,
                    "quantity": quantity,
                    "stock": item.quantity
                ]
                
                cartRef.setData(data) { error in
                    if let error = error {
                        print("Error adding item to cart:", error)
                    } else {
                        print("Item added to cart")
                    }
                }
            }
        }
    }

    func processPurchase(
        cartItem: CartItem,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let itemID = cartItem.id else {
            completion(.failure(NSError(domain: "MissingItemID", code: -1)))
            return
        }

  
        let productRef = Firestore.firestore()
            .collection("products")
            .document(itemID)

        productRef.updateData([
            "quantity": FieldValue.increment(Int64(-cartItem.quantity))
        ]) { error in
            
            if let error = error {
                print("❌ Failed to update stock: \(error)")
                completion(.failure(error))
                return
            }

            print(" Stock updated for seller.")

            NotificationService.shared.createNotification(
                userId: cartItem.sellerID,
                title: "New Purchase",
                body: "A customer bought \(cartItem.quantity) of \"\(cartItem.title)\".",
                type: .purchase,
                relatedItemId: itemID
            )

            completion(.success(()))
        }
    }


    
    func processAllPurchases(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var allSuccess = true

        for cartItem in cartItems {
            group.enter()

            processPurchase(cartItem: cartItem) { result in
                switch result {
                case .success:
                    print("Processed purchase for \(cartItem.title)")
                case .failure(let error):
                    print("Failed processing \(cartItem.title): \(error.localizedDescription)")
                    allSuccess = false
                }

                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(allSuccess)
        }
    }





    // MARK: - Remove using Item (used in DetailView)
    func removeFromCart(item: Item) {
        guard let userID = AuthService.shared.currentUser?.id,
              let itemID = item.id else { return }

        db.collection("users")
            .document(userID)
            .collection("cart")
            .document(itemID)
            .delete()
    }

    // MARK: - Remove using CartItem (used in CartView)
    func removeFromCart(cartItem: CartItem) {
        guard let userID = AuthService.shared.currentUser?.id,
              let itemID = cartItem.id else { return }

        db.collection("users")
            .document(userID)
            .collection("cart")
            .document(itemID)
            .delete()
    }
    
    func updateQuantity(cartItem: CartItem, amount: Int) {
        guard let userID = AuthService.shared.currentUser?.id,
              let itemID = cartItem.id else { return }
        
        db.collection("users")
            .document(userID)
            .collection("cart")
            .document(itemID)
            .updateData([
                "quantity": FieldValue.increment(Int64(amount))
            ])
    }


    func emptyCart() {
        guard let userID = AuthService.shared.currentUser?.id else { return }
        
        let cartRef = db.collection("users")
            .document(userID)
            .collection("cart")
        
        cartRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching cart items: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("Cart already empty")
                return
            }
            
            let batch = self.db.batch()
            
            for doc in documents {
                batch.deleteDocument(doc.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error deleting cart: \(error)")
                } else {
                    print("Cart successfully emptied.")
                }
            }
        }
    }

    func isInCart(item: Item) -> Bool {
        cartItems.contains { $0.id == item.id }
    }

    var totalPrice: Double {
        cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}
