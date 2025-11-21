import Foundation
import FirebaseFirestore
import Combine

class FirebaseCartManager: ObservableObject {
    static let shared = FirebaseCartManager()

    @Published var cartItems: [Item] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private init() {
    }

    func startListening() {
        listener?.remove()

        guard let userID = AuthService.shared.currentUser?.id else { return }

        listener = db.collection("users")
            .document(userID)
            .collection("cart")
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("❌ Cart listener error:", error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                print("🛒 Cart updated — \(documents.count) items")

                self.cartItems = documents.compactMap { doc in
                    try? doc.data(as: Item.self)
                }
            }
    }

    func addToCart(item: Item) {
        guard let userID = AuthService.shared.currentUser?.id,
              let itemID = item.id else { return }
        
        print("🔥 ADDING TO CART at path: users/\(userID)/cart/\(itemID)")
        do {
            try db.collection("users")
                .document(userID)
                .collection("cart")
                .document(itemID)
                .setData(from: item)

            print("🔥 Successfully wrote to Firestore")
        } catch {
            print("🔥 Firestore error:", error)
        }

    }

    func removeFromCart(item: Item) {
        guard let userID = AuthService.shared.currentUser?.id,
              let itemID = item.id else { return }

        db.collection("users")
            .document(userID)
            .collection("cart")
            .document(itemID)
            .delete()
    }

    func isInCart(item: Item) -> Bool {
        cartItems.contains { $0.id == item.id }
    }

    var totalPrice: Double {
        cartItems.reduce(0) { $0 + ($1.price ?? 0.0)}
    }
}
