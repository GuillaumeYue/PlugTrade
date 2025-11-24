//
// MARK: Created by S.Neil Created by Shaquille O Neil on 2025-10-26.
//
import SwiftUI
import FirebaseAuth

struct ProfileScreen: View {

    @ObservedObject private var authManager = AuthService.shared
    
    @State private var profileedit: Bool = false
    @State private var myproducts: Bool = false
    @State private var loggedOut: Bool = false
    @State private var showFull = false

    @Environment(\.dismiss) var dismiss


    var body: some View {
        ZStack{
            VStack {
                // MARK: - User Info Section
                VStack {
                    Spacer().frame(height: 100)
                    NavigationLink(destination: AuthGate(), isActive: $loggedOut) {
                        EmptyView()
                    }

                    
                    if let urlString = authManager.currentUser?.profilePictureURL,
                       let url = URL(string: urlString) {

                        SDWebImageAsync(
                            url: url,
                            placeholder: Image(systemName: "person.fill")
                        )
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .onTapGesture {showFull.toggle()}
                        .fullScreenCover(isPresented: $showFull) {
                            ZStack {
                                   Color.black.ignoresSafeArea()

                                   SDWebImageAsync(
                                       url: url,
                                       placeholder: Image(systemName: "photo")
                                   )
                                   .scaledToFit()
                                   .onTapGesture { showFull = false }
                               }
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    }else {
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
                    VStack(spacing: 20) {
                        
                        NavigationLink(destination: ProfileEditView(), isActive: $profileedit) { EmptyView() }
                        NavigationLink(destination: MyProducts(), isActive: $myproducts) { EmptyView() }

                        // Edit Profile Button
                        Button(action: { profileedit = true }) {
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
                        
                        // My Products Button
                        Button(action: { myproducts = true }) {
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
                        
                        // Sign Out Button
                        Button(role: .destructive, action: {
                            _ = authManager.signOut()
                            loggedOut = true
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
            .padding(.horizontal)
            .onAppear {
                // Ensure we fetch the latest user when screen appears
                authManager.fetchUser { _ in }
            }
            
        }
        
        
    }
}

#Preview {
    ProfileScreen()
}
