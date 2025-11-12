//
//  LoginForm.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//

import SwiftUI

struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @StateObject var authManager = AuthService.shared
    
    var body: some View {
        VStack{
            Text("PlugTrade")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Form{
                Section("Login"){
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
                
                
                Button("Login"){
                    
                    guard Validators.isValidEmail(email) else {
                        self.error = "Invalid email format"
                        return
                    }
                    
                    guard Validators.isValidPassword(password) else {
                        self.error = "Password must be at least 8 characters long"
                        return
                    }
                    
                    authManager.login(email: email, password: password){
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
                .disabled(email.isEmpty || password.isEmpty)
                
                    
                
                
            }
            
            
        }
        .padding(.horizontal)
        
      
        
    }
}

#Preview {
    LoginForm()
}
