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
    
    // Shared Firebase view model instance
    @StateObject private var firebaseManager = FirebaseViewModel.shared
    
    // User-related state variables
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var profileImage: URL? = nil
    @State private var userJoined: Timestamp = Timestamp(date: Date())
    
    // Navigation and authentication state variables
    @State private var profileedit: Bool = false
    @State private var loggedOut: Bool = false
    
    // Access to authentication manager
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        
        VStack {
            
            // MARK: - User Info Section
            VStack {
                Spacer()
                    .frame(height: 100)
                
                // Placeholder profile image (can be replaced with user's image)
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.2))
                    )
                
                // Display user's name, email, and join date
                Text("Name : \(userName)")
                Text("Email : \(userEmail)")
                
            }
            // Fetch current user details when the view appears
            .onAppear {
                if let currentUID = Auth.auth().currentUser?.uid {
                    Task {
                        firebaseManager.fetchUser(id: currentUID) { user in
                            if let user = user {
                                userName = user.name
                                userEmail = user.email
                             
                            }
                        }
                    }
                }
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
                       
                    }) {
                        HStack {
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
