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



class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published var currentUser: appUser?
    
    private let db = Firestore.firestore()
    
    //MARK: REGISTER
    func register(name: String, email: String, password: String, profilePictureURL: String?, completion: @escaping (Result<appUser, Error>) -> Void) {

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let user = result?.user else {
                return completion(.failure(SimpleError("Unable to create user")))
            }
            
            let uid = user.uid
            let appUser = appUser(
                id: uid,
                name: name,
                email: email,
                profilePictureURL: profilePictureURL ?? "https://via.placeholder.com/150"
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
    }


    
    
    //MARK: - LOGIN
    func login(email: String, password: String, completion: @escaping (Result<appUser?, Error>) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }else if let user = result?.user {
                
                let uid = user.uid
                
                //fetch the user from firestore
                self.fetchUser { res in
                switch res {
                case .success(let appUserobj):
                    if let appUser = appUserobj {
                        completion(.success(appUser))
                    }else{
                        //dummy data to prevent crash
                        let name =  result?.user.displayName ?? "Dummy"
                        let email =  result?.user.email ?? "Dummy@gmail.com"
                        let profilepic = result?.user.photoURL?.absoluteString ?? "https://via.placeholder.com/150"
                        let appUser = appUser(id: uid, name: name, email: email, profilePictureURL: profilepic)
                        
                        //update the empty record
                        do{
                            try self.db.collection("users").document(uid).setData(from: appUser){
                                error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    completion(.failure(error)  )
                                }
                                DispatchQueue.main.async {
                                    self.currentUser = appUser
                                }
                                completion(.success(appUser))
                            }
                        }catch {
                            print(error.localizedDescription)
                            completion(.failure(error))
                        }
                        
                        
                    }
                case .failure(let failuer):
                    completion(.failure(failuer))
                    }
                    
                    
                }
                
            }
            
        }
    }
    
    
    
    //MARK: FETCH CURRENT USER
    func fetchUser(completion: @escaping (Result<appUser?, Error>) -> Void) {
        
        //uid from FireBASEaUTH
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            return completion(.success(nil))
        }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let snapshot = snapshot else {
                return completion(.success(nil))
            }
            
            do{
                let user = try snapshot.data(as: appUser.self)
                
                DispatchQueue.main.async {
                    self.currentUser = user
                }
                completion(.success(user))
            }catch{
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    
    
    //MARK: UPDATE PROFILE
    func updateUser(name: String, profilePictureURL: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.success(()))
        }
        
        var data: [String: Any] = ["name": name]
        if let profilePictureURL = profilePictureURL {
            data["profilePictureURL"] = profilePictureURL
        }
        
        db.collection("users").document(uid).updateData(data) { error in
            if let error = error {
                return completion(.failure(error))
            }
            self.fetchUser { _ in
                completion(.success(()))
            }
        }
    }

    
    
    
    //MARK: SIGN OUT
    func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            return .success(())
        } catch {
            print(error.localizedDescription)
            return .failure(error)
        }
    }
    
    
    
    //end of file
}



