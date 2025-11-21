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
        ZStack{
            Image("background3")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                Spacer()
                    .frame(height: 40)
                
                Image("back3")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 300, height: 300)
                
                Form{
                    Section(header:
                                HStack {
                        Spacer()
                                    Image(systemName: "person.fill")
                                    Text("LOGIN")
                                        .font(.title3)
                                        .fontWeight(.bold)
                        Spacer()
                                }){
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
                    
                    
                    Section{
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
                        .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .listRowBackground(Color.clear)
                            
                    }
                    
                        
                    
                    
                }
                .frame(width: 350, height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .scrollContentBackground(.hidden)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        )
                
                Spacer()
                
            }
            .padding(.horizontal)
        }
       
        
      
        
    }
}

#Preview {
    LoginForm()
}
