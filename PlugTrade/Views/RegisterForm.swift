//
//  RegisterForm.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//

import SwiftUI

struct RegisterForm: View {
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @EnvironmentObject var authManager: AuthManager
    
    
    
    var body: some View {
        VStack {
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
                    return
                }

                authManager.register(email: email, password: password) { result in
                    switch result {
                    case .success(_):
                        print("User Registered")
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
