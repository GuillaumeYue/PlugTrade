import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

struct ProfileEditView: View {
    
    @StateObject private var authManager = AuthService.shared
    
    @State private var currentUser: appUser? = nil
    @State private var userName: String = ""
    @State private var profileImage: URL? = nil
    @State private var imageData: Data? = nil
    @State private var errorMessage: String? = nil
    @State private var showSuccessAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Edit Profile")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            // MARK: Form
            Form {
                Section("Profile") {
                    
                    HStack {
                        Spacer()
                        
                        ZStack(alignment: .bottomTrailing) {
                            if let data = imageData, let uiImage = UIImage(data: data) {
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
                            
                            ImageUploadButton(selectedImageData: $imageData) { url in
                                if let imageURL = URL(string: url) {
                                    profileImage = imageURL
                                }
                            }
                            .offset(x: 10, y: 10)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    
                    TextField("Name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding(.vertical, 5)
                }
            }
            .padding(.horizontal, 20)
            
            // MARK: Save Button immediately under form
            Button("Save") {
                guard !userName.trimmingCharacters(in: .whitespaces).isEmpty else {
                    self.errorMessage = "Name is required"
                    return
                }
                authManager.updateUser(name: userName, profilePictureURL: profileImage?.absoluteString) { result in
                    switch result {
                    case .success:
                        userName = ""
                        self.errorMessage = ""
                    case .failure(let failure):
                        self.errorMessage = failure.localizedDescription
                    }
                }
                
                showSuccessAlert = true
            }
            .disabled(userName.isEmpty)
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .frame(width: 200)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(15)
            
            // MARK: Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                    .padding(.horizontal, 40)
            }
            
            Spacer() // optional, keep form and button at top
        }
        .alert("Profile updated successfully", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

#Preview {
    ProfileEditView()
}
