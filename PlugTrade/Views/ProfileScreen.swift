//
//  ProfileScreen.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

struct ProfileScreen: View {
    
    // User-related state variables
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var profileImage: URL? = nil
    @State private var userJoined: Timestamp = Timestamp(date: Date())
    
    // Navigation and authentication state variables
    @State private var profileedit: Bool = false
    @State private var loggedOut: Bool = false
    @State private var myproducts: Bool = false
    
    // Access to authentication manager
    @ObservedObject private var authManager = AuthService.shared
    
    var body: some View {
        
        VStack {
            
            // MARK: - User Info Section
            VStack {
                Spacer().frame(height: 100)
                
                // Use currentUser's profile image if available
                if let urlString = authManager.currentUser?.profilePictureURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                    } placeholder: {
                        ProgressView()
                            .frame(width: 120, height: 120)
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray.opacity(0.6))
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                }
                
                Text(authManager.currentUser?.name ?? "Anonymous")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 5)
                
                Text(authManager.currentUser?.email ?? "test@gmail.com")
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
         
            
            Spacer()
            
            // MARK: - Options Section
            VStack(spacing: 30) {
                
                // Navigation link to edit profile view
                VStack(spacing: 20) {
                    NavigationLink(destination: ProfileEditView(), isActive: $profileedit) { EmptyView() }
                    
                    // Edit Profile button
                    Button(action: {
                        print("Edit Profile tapped")
                        profileedit = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Profile")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(15)
                    }
                    
                   
                    
                    // Products Trade button
                    Button(action: {
                       myproducts = true
                    }) {
                        HStack {
                            NavigationLink(destination: MyProducts(), isActive: $myproducts) { EmptyView() }
                            
                            Image(systemName: "arrow.2.squarepath")
                            Text("My Products")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(15)
                    }
                    
                    // Sign Out button
                    Button( role: .destructive, action: {
                        authManager.signOut()
                    }) {
                        Text("Sign Out")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(15)
                }
                .padding()
                .cornerRadius(25)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
}

#Preview {
    ProfileScreen()
}
