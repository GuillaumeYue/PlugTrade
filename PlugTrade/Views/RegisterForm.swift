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
    @State private var showingImagePicker = false
    @State private var imageData: Data? = nil
    @StateObject private var authManager = AuthService.shared
    
    
    
    var body: some View {
        VStack {
          
            Text("PlugTrade")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Form{
                Section("Create Account"){
                   
                    HStack{
                        Spacer()
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
                            
                        
                        }
                        .padding()
                        Spacer()
                    }
                   
                    
                    TextField("Display Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                
                
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                
                Button("Register"){
                    
                    guard Validators.isValidEmail(email) else {
                        self.error = "Invalid email format"
                        return
                    }
                    
                    guard Validators.isValidPassword(password) else {
                        self.error = "Password must be at least 8 characters long"
                        return
                    }
                    
                    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                        self.error = "Please enter a display name"
                        return
                    }
                    
                    authManager.register(name: name, email: email, password: password, profilePictureURL: profileImage){
                        result in
                        switch result {
                        case .success:
                            self.error = nil
                        case .failure(let failure):
                            self.error = failure.localizedDescription
                    }
                  
                        
                    }
                    
                }
                .padding(.horizontal)
                .disabled(email.isEmpty || password.isEmpty || name.isEmpty)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(15)
                .foregroundStyle(Color.white)
                
              
            
            }
 
            
            
        }
        .padding(.horizontal)
    }
}

#Preview {
    RegisterForm()
}
