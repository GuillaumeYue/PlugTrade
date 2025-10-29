//
//  RegisterForm.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

struct RegisterForm: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var profileImage: String = ""
    @State private var joined: Timestamp? = nil
    @State private var showingImagePicker = false
    @State private var imageData: Data? = nil
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var firebaseManager = FirebaseViewModel.shared
    
    
    
    var body: some View {
        VStack {
            Text("PlugTrade")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            
            ZStack(alignment: .bottomTrailing) {
                if let url = URL(string: profileImage), !profileImage.isEmpty {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
                
                
                
                
                ZStack(alignment: .bottomTrailing) {
                    
                    if let data = imageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    } else if let url = URL(string: profileImage), !profileImage.isEmpty {
                        
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        } placeholder: {
                            ProgressView()
                                .frame(width: 120, height: 120)
                        }
                    } else {
                        
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    
                    
                    ImageUploadButton(selectedImageData: $imageData) { url in
                        profileImage = url
                    }
                    .offset(x: 5, y: 5)
                }
                .padding(.top)
                
            }
            .padding()
            
            TextField("Display Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                if password.isEmpty || email.isEmpty || name.isEmpty{
                    self.error = "Please fill in all fields"
                    return
                }
                
                authManager.register(email: email, password: password) { result in
                    switch result {
                    case .success(let user):
                        print("User Registered")
                        let newUser = User(
                            id: user.uid, // to the user in authentication
                            name: name,
                            email: email,
                            profilePictureURL: profileImage
                        )
                        firebaseManager.addUser(user: newUser)
                        
                        
                    case .failure(let error):
                        self.error = error.localizedDescription
                        print(error.localizedDescription)
                    }
                }
            }) {
                Text("Register")
                    .fontWeight(.bold)
                    .padding()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue.opacity(0.8))
                        
                    )
                
            }
            .padding(.horizontal)
            
            
            
            HStack {
                Text("Already have an account?")
                NavigationLink(destination: LoginForm()) {
                    Text("Login")
                        .foregroundStyle(.blue)
                }
            }
            
            
            
            
            
            
        }
        .padding(.horizontal)
    }
}

#Preview {
    RegisterForm()
}
