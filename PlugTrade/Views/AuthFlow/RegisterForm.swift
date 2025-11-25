import SwiftUI
import PhotosUI

struct RegisterForm: View {
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data? = nil
    @State private var isRegistering = false
    @State private var showSuccessAlert = false
    
    @StateObject private var authManager = AuthService.shared
    
    var body: some View {
            
            VStack {
                Spacer()
                    .frame(height: 10)
                Image("back3")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 150, height: 150)
                
                Form {
                    Section(header:
                                HStack{
                        Spacer()
                        Image(systemName: "archivebox")
                        Text("REGISTER")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                            
                    }) {
                        // MARK: Profile Image Picker
                        HStack {
                            Spacer()
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                if let data = imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .onChange(of: selectedImage) { newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    imageData = data
                                }
                            }
                        }
                        
                        // MARK: Name Field
                        TextField("Display Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                        
                        // MARK: Email Field
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress)
                        
                        // MARK: Password Field
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // MARK: Error message
                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                    }
                    
                    // MARK: Register Button
                    Section{
                        Button(action: registerUser) {
                            if isRegistering {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 200)
                            } else {
                                Text("Register")
                                    .frame(width: 200)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                        }
                        .disabled(email.isEmpty || password.isEmpty || name.isEmpty || isRegistering)
                        .padding(.horizontal)
                        .disabled(email.isEmpty || password.isEmpty)
                        .font(.headline)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .listRowBackground(Color.clear)
                    }
                    
                }
                .frame(width: 350, height: 550)
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
            .alert("Registration Successful!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            }
        
        
        
        
    }
    
    // MARK: - Register function
    private func registerUser() {
        error = nil
        
        guard Validators.isValidEmail(email) else {
            error = "Invalid email format"
            return
        }
        
        guard Validators.isValidPassword(password) else {
            error = "Password must be at least 8 characters long"
            return
        }
        
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "Please enter a display name"
            return
        }
        
        isRegistering = true
        
        authManager.register(name: name, email: email, password: password, profileImageData: imageData) { result in
            isRegistering = false
            switch result {
            case .success:
                showSuccessAlert = true
                clearForm()
            case .failure(let failure):
                error = failure.localizedDescription
            }
        }
    }
    
    private func clearForm() {
        name = ""
        email = ""
        password = ""
        selectedImage = nil
        imageData = nil
    }
}

#Preview {
    RegisterForm()
}
