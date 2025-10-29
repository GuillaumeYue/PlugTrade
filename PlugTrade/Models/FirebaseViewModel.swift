//
//  FirebaseViewModel.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-27.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class FirebaseViewModel: ObservableObject {
    @Published var currentAppUser: AppUser?
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func loadCurrentAppUser() {
        guard let authUser = Auth.auth().currentUser else { currentAppUser = nil; return }
        db.collection("users").document(authUser.uid).getDocument { snap, _ in
            if let data = snap?.data(),
               let email = data["email"] as? String {
                self.currentAppUser = AppUser(uid: authUser.uid,
                                              email: email,
                                              displayName: data["displayName"] as? String,
                                              avatarURL: data["avatarURL"] as? String,
                                              createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date())
            } else {
                // 首次登录可自动建档
                let new = AppUser(uid: authUser.uid, email: authUser.email ?? "")
                self.currentAppUser = new
                try? self.db.collection("users").document(authUser.uid).setData(from: new)
            }
        }
    }

    // TODO: 后续加：upload user icon、upload product、search product......
}
