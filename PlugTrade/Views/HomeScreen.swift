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
    
    var filteredItems: [Item] {
        if let category = selectedCategory, category != .all {
            return productManager.items.filter { $0.category == category }
        }
        return productManager.items
    }
    
    var body: some View {
        NavigationView {
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
                        
                        NavigationLink(destination: ProfileScreen()) {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(AuthService.shared.currentUser?.name.prefix(2).uppercased() ?? "U")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                )
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(item.sellerName.prefix(2).uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                    )
                
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
            
            HStack {
                Text("$\(item.price, specifier: "%.0f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
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
