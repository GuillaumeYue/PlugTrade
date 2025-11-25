import Foundation
import FirebaseFirestore
import Combine

class FirebaseFavoritesManager: ObservableObject {
    static let shared = FirebaseFavoritesManager()
    
    @Published var favoriteItemIDs: Set<String> = []
    @Published var isListening: Bool = false
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        print(" FirebaseFavoritesManager initialized")
        startListening()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    private func createItemKey(for item: Item) -> String {
        let timestampString = String(item.timestamp.timeIntervalSince1970)
        let key = "\(item.sellerID)_\(item.title)_\(timestampString)"
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
        print(" Created key: \(key)")
        return key
    }
    
    func startListening() {
        guard let userID = AuthService.shared.currentUser?.id else {
            print("No user ID - cannot start listening")
            stopListening()
            return
        }
        
        print(" Starting listener for user: \(userID)")
        
        listenerRegistration?.remove()
        
        isListening = true

        listenerRegistration = db.collection("users")
            .document(userID)
            .collection("favorites")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print(" Listener error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print(" No documents in snapshot")
                    return
                }
                
                print(" Received \(documents.count) favorites")
                
                let newKeys = Set(documents.map { $0.documentID })
                
                DispatchQueue.main.async {
                    if self.favoriteItemIDs != newKeys {
                        self.favoriteItemIDs = newKeys
                        print(" Updated favorites: \(newKeys)")
                    }
                }
            }
    }
    
    func stopListening() {
        print(" Stopping listener")
        listenerRegistration?.remove()
        listenerRegistration = nil
        DispatchQueue.main.async {
            self.isListening = false
            self.favoriteItemIDs = []
        }
    }

    func toggleFavorite(item: Item) {
        print(" toggleFavorite called for: \(item.title)")
        
        guard let userID = AuthService.shared.currentUser?.id else {
            print(" No user ID in toggleFavorite")
            return
        }
        
        print(" User ID: \(userID)")
        
        let itemKey = createItemKey(for: item)
        let favoriteRef = db.collection("users")
            .document(userID)
            .collection("favorites")
            .document(itemKey)
        
        print("📍 Firebase path: users/\(userID)/favorites/\(itemKey)")
        
        if isFavorite(item: item) {
            print("🗑️ Removing from favorites")
            favoriteRef.delete { error in
                if let error = error {
                    print(" Delete error: \(error.localizedDescription)")
                } else {
                    print("Successfully deleted")
                }
            }
        } else {
            print("➕ Adding to favorites")
            let favoriteData: [String: Any] = [
                "title": item.title,
                "sellerID": item.sellerID,
                "timestamp": Timestamp(date: item.timestamp),
                "addedAt": Timestamp(date: Date())
            ]
            
            favoriteRef.setData(favoriteData) { error in
                if let error = error {
                    print(" Set error: \(error.localizedDescription)")
                } else {
                    print(" Successfully added")
                }
            }
        }
    }
    
    func isFavorite(item: Item) -> Bool {
        let itemKey = createItemKey(for: item)
        let result = favoriteItemIDs.contains(itemKey)
        print("🔍 isFavorite(\(item.title)): \(result)")
        return result
    }
}
