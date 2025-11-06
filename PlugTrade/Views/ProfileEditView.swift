import SwiftUI
import PhotosUI

struct ProfileEditView: View {

    @StateObject private var authManager = AuthService.shared

    @State private var userName: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showSuccessAlert = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Profile")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)

            // MARK: Profile Image
            PhotosPicker(selection: $selectedImage, matching: .images) {
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(8)
                } else if let urlString = authManager.currentUser?.profilePictureURL,
                          let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(8)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                                .overlay(Image(systemName: "person.crop.circle.fill"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Tap to select image")
                            .foregroundColor(.gray)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 40)
            .clipShape(Circle())
            .onChange(of: selectedImage) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }

            // MARK: Name Field
            TextField("Name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)

            // MARK: Save Button
            Button(action: saveProfile) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 200)
                } else {
                    Text("Save")
                        .frame(width: 200)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }
            .disabled(userName.isEmpty || isSaving)
            .padding(.top, 10)

            // MARK: Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .onAppear {
            if let user = authManager.currentUser {
                userName = user.name
            }
        }
        .alert("Profile updated successfully", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    // MARK: Save Profile using AuthService
    private func saveProfile() {
        guard !userName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSaving = true
        errorMessage = nil

        authManager.saveProfile(name: userName, imageData: imageData) { result in
            isSaving = false
            switch result {
            case .success:
                showSuccessAlert = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ProfileEditView()
}
