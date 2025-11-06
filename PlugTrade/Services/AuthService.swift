//
//  AuthService.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-31.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published var currentUser: appUser?
    @Published var isLoading = false
    @Published var profilePictureURL: String?
    
    private let db = Firestore.firestore()
    
    // MARK: - REGISTER
    func register(name: String, email: String, password: String, profileImageData: Data?, completion: @escaping (Result<appUser, Error>) -> Void) {
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                
                if let error = error {
                    return completion(.failure(error))
                }
                
                guard let user = result?.user else {
                    return completion(.failure(SimpleError("Unable to create user")))
                }
                
                let uid = user.uid
                
                // Function to create appUser and save to Firestore
                func saveUser(profileURL: String?) {
                    let appUser = appUser(
                        id: uid,
                        name: name,
                        email: email,
                        profilePictureURL: profileURL ?? "https://via.placeholder.com/150"
                    )
                    
                    do {
                        try self.db.collection("users").document(uid).setData(from: appUser) { error in
                            if let error = error {
                                return completion(.failure(error))
                            }
                            DispatchQueue.main.async {
                                self.currentUser = appUser
                            }
                            completion(.success(appUser))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                
                // If an image is provided, upload first
                if let data = profileImageData {
                    self.uploadProfileImage(uid: uid, data: data) { result in
                        switch result {
                        case .success(let urlString):
                            saveUser(profileURL: urlString)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    // No image, save directly
                    saveUser(profileURL: nil)
                }
            }
        }
    
    // MARK: - LOGIN
    func login(email: String, password: String, completion: @escaping (Result<appUser, Error>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(SimpleError("User not found")))
                return
            }
            
            self.fetchUser { fetchResult in
                switch fetchResult {
                case .success(let userObj):
                    if let appUser = userObj {
                        completion(.success(appUser))
                    } else {
                        // Create default appUser if not in Firestore
                        let appUser = appUser(
                            id: user.uid,
                            name: user.displayName ?? "User",
                            email: user.email ?? "user@example.com",
                            profilePictureURL: user.photoURL?.absoluteString ?? "https://via.placeholder.com/150"
                        )
                        do {
                            try self.db.collection("users").document(user.uid).setData(from: appUser) { error in
                                if let error = error {
                                    completion(.failure(error))
                                    return
                                }
                                DispatchQueue.main.async { self.currentUser = appUser }
                                completion(.success(appUser))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - FETCH CURRENT USER
    func fetchUser(completion: @escaping (Result<appUser?, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async { self.currentUser = nil }
            completion(.success(nil))
            return
        }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.success(nil))
                return
            }
            
            do {
                let user = try snapshot.data(as: appUser.self)
                DispatchQueue.main.async { self.currentUser = user }
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - SAVE PROFILE (name + optional profile image)
    func saveProfile(name: String, imageData: Data?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(SimpleError("User not logged in")))
            return
        }
        
        if let data = imageData {
            // Upload new image
            uploadProfileImage(uid: uid, data: data) { result in
                switch result {
                case .success(let urlString):
                    self.updateUser(name: name, profilePictureURL: urlString, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // No new image, just update name
            updateUser(name: name, profilePictureURL: currentUser?.profilePictureURL, completion: completion)
        }
    }
    
    // MARK: - UPLOAD PROFILE IMAGE
    private func uploadProfileImage(uid: String, data: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = Storage.storage().reference().child("profileImages/\(uid)/\(UUID().uuidString).jpg")
        ref.putData(data, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            ref.downloadURL { url, error in
                if let url = url {
                    completion(.success(url.absoluteString))
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - UPDATE USER IN FIRESTORE
    private func updateUser(name: String, profilePictureURL: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(SimpleError("User not logged in")))
            return
        }
        
        var data: [String: Any] = ["name": name]
        if let profilePictureURL = profilePictureURL {
            data["profilePictureURL"] = profilePictureURL
        }
        
        db.collection("users").document(uid).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.fetchUser { _ in
                completion(.success(()))
            }
        }
    }
    
    // MARK: - SIGN OUT
    func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async { self.currentUser = nil }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    
    //MARK: Fetch seller of item
    func fetchSeller(id: String, completion: @escaping (String?) -> Void) {
        guard !id.isEmpty else {
            completion(nil)
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(id).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let url = data["profilePictureURL"] as? String {
                completion(url)
            } else {
                completion(nil)
            }
        }
    }

}

