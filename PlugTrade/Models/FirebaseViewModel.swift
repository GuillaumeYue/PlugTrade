//
//  FirebaseViewModel.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-27.
//

import Foundation
import FirebaseFirestore
import Combine


class FirebaseViewModel: ObservableObject {
    
    
    static let shared = FirebaseViewModel()
    
    private let db = Firestore.firestore()
    
    @Published var user: [appUser] = []
    
    
    
    init() {
        fetchUsers()
    }
    
    
    //fetch users
    func fetchUsers() {
        db.collection("users").addSnapshotListener{querySnapshot, error in
           if let error = error {
                
               print("\(error.localizedDescription)")
            }
            self.user = querySnapshot?.documents.compactMap({document in
                try? document.data(as: appUser.self)
            }) ?? []
            
            
        }
    }
    
    
    func fetchUser(id: String, completion: @escaping (appUser?) -> Void) {
        db.collection("users").document(id).getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("User not found")
                completion(nil)
                return
            }
            
            do {
                let user = try document.data(as: appUser.self)
                completion(user)
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    
    //save user
    func addUser(user: appUser){
        let newUser = appUser(id: user.id,name: user.name, email: user.email, profilePictureURL: user.profilePictureURL ?? "")
        do{
            try db.collection("users").document(user.id).setData(from: newUser)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    //update user
    func updateUser(user: appUser, name: String, email: String, profilePictureURL: String?){
        let userID = user.id
        db.collection( "users" ).document( userID ).updateData(["name": name, "email": email, "profilePictureURL": profilePictureURL])
    }
    
    //function delete user
    func deleteUser(user: appUser){
    let userID = user.id
        db.collection( "users" ).document( userID ).delete{
            error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
