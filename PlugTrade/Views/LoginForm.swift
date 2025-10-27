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
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack{
            Text("PlugTrade")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
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
                if email.isEmpty || password.isEmpty {
                    self.error = "Please fill in all fields"
                }
                
                
                authManager.login(email: email, password: password){
                    result in
                    switch result {
                    case .success(let success):
                        print("User Registered")
                    case .failure(let error):
                        self.error = error.localizedDescription
                        print("\(error.localizedDescription)")
                    }
                }
            }) {
                Text("Login")
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
                Text("Don't have an account?")
                NavigationLink(destination: RegisterForm()) {
                    Text("Sign Up")
                        .foregroundStyle(.blue)
                }
            }
            
            
        }
        .padding(.horizontal)
        
      
        
    }
}

#Preview {
    LoginForm()
}
