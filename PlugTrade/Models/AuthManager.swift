//
//  AuthManager.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var isProfileComplete: Bool = false
        //published states if this variable changes, rerender the ui
    
    init(){
        self.firebaseUser = Auth.auth().currentUser // saves the user
    }
    
    
    
    //register function
    func register(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User, Error>) ->Void){
        
        
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                
            }else if let user = result?.user {
                self.firebaseUser = user
                completion(.success(user))
            }
            
        }
    }
    
    
    
    //login function
    
    func login(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if let error = error {
                completion(.failure(error))
            }else if let user = result?.user {
                completion(.success(user))
                self.firebaseUser = user
            }
        }
    }
    
    
    
    
   //sign out function
    func signOut(){
        do {
            try Auth.auth().signOut()
            self.firebaseUser = nil
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

