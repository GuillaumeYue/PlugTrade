//
//  HomeScreen.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//

//
//  HomeView.swift
//  PlugTrade
//
//  Created by mac on 2025-10-28.
//



import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var productManager: ProductManager
    @State private var selectedCategory: Category?
    @State private var showProfile = false
    @State private var showNotifications = false
    @ObservedObject private var authManager = AuthService.shared
    @ObservedObject private var cartManager = FirebaseCartManager()
  
    
    
    var filteredItems: [Item] {
        if let category = selectedCategory, category != .all {
            return productManager.items.filter { $0.category == category }
        }
        return productManager.items
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    categoriesSection
                    productFeed
                }
                .padding(.bottom)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { showNotifications = true }) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                        }
                        
                        NavigationLink(destination: CartView()) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "cart.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(Color.blue)
                                
                                if cartManager.cartItems.count > 0 {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 16, height: 16)
                                        Text("\(cartManager.cartItems.count)")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                        }

                        NavigationLink(destination: ProfileScreen()) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 32, height: 32)

                                if let urlString = authManager.currentUser?.profilePictureURL,
                                   let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 32, height: 32)
                                    }
                                } else {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.blue)
                                }
                            }
                        }

                    }
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
    }
    
    var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    CategoryCircle(icon: "square.grid.2x2", name: "All", category: .all, selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "laptopcomputer", name: "Laptops", category: .laptop, selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "iphone", name: "Mobile", category: .mobile, selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "applewatch", name: "Watches", category: .watch, selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "headphones", name: "Headsets", category: .headsets, selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "ipad", name: "iPads", category: .ipad, selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "ellipsis.circle", name: "Other", category: .other, selectedCategory: $selectedCategory)
                }
                .padding(.horizontal)
            }
        }
    }
    
    var productFeed: some View {
        VStack(spacing: 16) {
            if productManager.isLoading {
                ProgressView()
                    .padding()
            } else if filteredItems.isEmpty {
                Text("No items available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(filteredItems.prefix(10)) { item in
                    ProductPost(item: item)
                }
            }
        }
    }
}

struct CategoryCircle: View {
    let icon: String
    let name: String
    let category: Category
    @Binding var selectedCategory: Category?
    
    var isSelected: Bool {
        selectedCategory == category || (selectedCategory == nil && category == .all)
    }
    
    var body: some View {
        Button(action: {
            selectedCategory = category == .all ? nil : category
        }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? Color.blue : Color.blue.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 28))
                            .foregroundColor(isSelected ? .white : .blue)
                    )
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
    }
}

struct ProductPost: View {
    let item: Item
    
    @ObservedObject private var authManager = AuthService.shared
    @State private var sellerImageURL: String?
    @State private var rotate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 32, height: 32)

                    if let urlString = sellerImageURL,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                                .frame(width: 32, height: 32)
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                }.onAppear {
                    authManager.fetchSeller(id: item.sellerID) { url in
                                   sellerImageURL = url
                               }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.sellerName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(item.location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            NavigationLink(destination: DetailView(item: item)) {
                AsyncImage(url: URL(string: item.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                            .overlay(Image(systemName: "photo"))
                    @unknown default:
                        EmptyView()
                    }
                }
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                            Spacer()
                        }
                        .padding()
                    }
                )
            }
            
            
            //MARK: BADGE
            HStack {
                if item.itemType == .forSale {
                    Text("$\(item.price ?? 0.0, specifier: "%.0f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }else{
                    
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.2.circlepath")
                            .font(.title3)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotate ? 360 : 0))
                            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotate)
                            .onAppear { rotate = true }

                        Text("For Trade")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green.gradient)
                            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
                    )

                  
                }
               
                
                Spacer()
                
                HStack(spacing: 16) {
                    Image(systemName: "heart")
                    Image(systemName: "message")
                    Image(systemName: "cart")
                }
                .font(.title3)
            }
            .padding(.horizontal)
            
            Divider()
        }
    }
}

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Text("No notifications yet")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .environmentObject(ProductManager.shared)
    }
}
