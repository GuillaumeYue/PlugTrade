//
//  ProfileEditView.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-27.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

struct ProfileEditView: View {
    
    @StateObject private var firebaseManager = FirebaseViewModel.shared
    @EnvironmentObject var authManager: AuthManager
    
    @State private var currentUser: User? = nil
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var profileImage: URL? = nil
    @State private var showingImagePicker = false
    @State private var imageData: Data? = nil
    @State private var navigateToHome = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            
            //Profile Image with Upload Button
            ZStack(alignment: .bottomTrailing) {
                if let data = imageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                } else if let url = profileImage {
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

                // Upload Button Overlay
                ImageUploadButton(selectedImageData: $imageData) { url in
                    if let imageURL = URL(string: url) {
                        profileImage = imageURL
                    }
                }
                .offset(x: 10, y: 10)
            }
            .padding(.top, 30)

            //Text Fields
            VStack(alignment: .leading, spacing: 15) {
                TextField("Name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                TextField("Email", text: $userEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
            }
            .padding(.horizontal, 40)

            // Save Button
            Button(action: {
                Task{
                    guard let currentUID = Auth.auth().currentUser?.uid else {return}
                    
                    let updatedUser = appUser(id: currentUID, name: userName, email: userEmail)
                    
                    firebaseManager.updateUser(
                        user: updatedUser,
                        name: userName,
                        email: userEmail,
                        profilePictureURL: profileImage?.absoluteString ?? "")
                    
                    showSuccessAlert = true
                    
                }
            }) {
                Text("Save Changes")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)

            Spacer()
        }
        .alert("Profile updated successfully", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
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
    }

}
#Preview {
    ProfileEditView()
}
