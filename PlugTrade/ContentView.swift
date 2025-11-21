import FirebaseAuth
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthService
    @EnvironmentObject var productManager: ProductManager
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var cartManager: FirebaseCartManager  

    @State private var isLoaded = false

    var body: some View {
        NavigationView {
            Group {
                if !isLoaded {
                    ProgressView()
                        .onAppear {
                            authManager.fetchUser { _ in
                                isLoaded = true

                                if Auth.auth().currentUser != nil {
                                    productManager.fetchUserProducts()
                                    notificationService.startListening()

                                    
                                    FirebaseCartManager.shared.startListening()
                                }
                            }
                        }

                } else if authManager.currentUser == nil {
                    AuthGate()

                } else {
                    MainTabView()
                        .onAppear {
                            productManager.fetchUserProducts()
                            notificationService.startListening()

                         
                            FirebaseCartManager.shared.startListening()
                        }
                }
            }
        }
        .onChange(of: authManager.currentUser?.id) { _ in
            if Auth.auth().currentUser != nil {
                productManager.fetchUserProducts()
                notificationService.startListening()

           
                FirebaseCartManager.shared.startListening()

            } else {
                productManager.stopUserProductsListener()
                notificationService.stopListening()

               
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
        .environmentObject(ProductManager.shared)
        .environmentObject(NotificationService.shared)
        .environmentObject(FirebaseCartManager.shared)
}
