//
//  HomeScreen.swift
//  PlugTrade
//
// MARK:   Created by Shaquille O Neil on 2025-10-26.
//

//
//  HomeView.swift
//  PlugTrade
//
// MARK:   Created by Evelyne mac on 2025-10-28.
//



import SwiftUI
import SDWebImage   // not strictly required here, but ok to keep

struct HomeScreen: View {
    @EnvironmentObject var productManager: ProductManager
    @EnvironmentObject var notificationService: NotificationService
    @State private var selectedCategory: Category?
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

                        // Notifications
                        Button(action: { showNotifications = true }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                                
                                if notificationService.unreadCount > 0 {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 16, height: 16)
                                        Text("\(notificationService.unreadCount)")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                        }

                        // Cart
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

                        // Profile avatar
                        NavigationLink(destination: ProfileScreen()) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 32, height: 32)

                                if let urlString = authManager.currentUser?.profilePictureURL,
                                   let url = URL(string: urlString) {

                                    SDWebImageAsync(
                                        url: url,
                                        placeholder: Image(systemName: "person.fill")
                                    )
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .contentShape(Circle())

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
                    .environmentObject(notificationService)
            }
        }
    }

    // MARK: - Categories

    var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    CategoryCircle(icon: "square.grid.2x2", name: "All",      category: .all,      selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "laptopcomputer",   name: "Laptops",  category: .laptop,   selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "iphone",           name: "Mobile",   category: .mobile,   selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "applewatch",       name: "Watches",  category: .watch,    selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "headphones",       name: "Headsets", category: .headsets, selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "ipad",             name: "iPads",    category: .ipad,     selectedCategory: $selectedCategory)
                    CategoryCircle(icon: "ellipsis.circle",  name: "Other",    category: .other,    selectedCategory: $selectedCategory)
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Product Feed

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

// MARK: - Product Card

struct ProductPost: View {
    let item: Item

    @ObservedObject private var authManager = AuthService.shared
    @State private var sellerImageURL: String?
    @State private var rotate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Seller row
            NavigationLink(destination: PublicProfileView(userID: item.sellerID)) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 32, height: 32)

                        if let sellerImageURL = sellerImageURL,
                           let url = URL(string: sellerImageURL) {

                            // FIXED — use GeometryReader to give UIKit the correct size
                            GeometryReader { geo in
                                SDWebImageAsync(
                                    url: url,
                                    placeholder: Image(systemName: "person.fill")
                                )
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipShape(Circle())
                            }
                            .frame(width: 32, height: 32) // <- final SwiftUI size

                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: 32, height: 32) // <- ensures stable container
                    .onAppear {
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
            }


            // Product image
            NavigationLink(destination: {
                if item.itemType == .forTrade {
                    TradeItemCard(item: item, onPropose: {})
                } else {
                    DetailView(item: item)
                }
            }) {
                SDWebImageAsync(
                    url: URL(string: item.imageURL),
                    placeholder: Image(systemName: "photo")
                )
                .frame(maxWidth: 420)
                .frame(height: 250)
                .clipped()
                .contentShape(Rectangle())
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

            // Price / trade badge
            HStack {
                if item.itemType == .forSale {
                    Text("$\(item.price ?? 0.0, specifier: "%.0f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                } else {
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

// MARK: - Category Circle

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

// MARK: - Notifications

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var notificationService: NotificationService
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var productManager: ProductManager
    
    @State private var selectedNotification: AppNotification?
    @State private var showDetailSheet = false

    var body: some View {
        NavigationView {
            Group {
                if notificationService.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No notifications yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(notificationService.notifications) { notification in
                            NotificationRow(notification: notification)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedNotification = notification
                                    showDetailSheet = true
                                    
                                    // Mark as read when tapped
                                    if !notification.isRead, let id = notification.id {
                                        notificationService.markAsRead(id)
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !notificationService.notifications.isEmpty {
                        Button("Mark All Read") {
                            notificationService.markAllAsRead()
                        }
                        .font(.subheadline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showDetailSheet) {
                if let notification = selectedNotification {
                    NotificationDetailSheet(
                        notification: notification,
                        isPresented: $showDetailSheet
                    )
                    .environmentObject(authService)
                    .environmentObject(productManager)
                    .environmentObject(notificationService)
                }
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon based on type
            Image(systemName: iconForType(notification.type))
                .font(.title3)
                .foregroundColor(colorForType(notification.type))
                .frame(width: 40, height: 40)
                .background(colorForType(notification.type).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(notification.isRead ? .secondary : .primary)
                
                Text(notification.body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func iconForType(_ type: NotificationType) -> String {
        switch type {
        case .tradeProposal:
            return "arrow.triangle.swap"
        case .tradeAccepted:
            return "checkmark.circle.fill"
        case .tradeRejected:
            return "xmark.circle.fill"
        case .message:
            return "message.fill"
        case .other:
            return "bell.fill"
        }
    }
    
    private func colorForType(_ type: NotificationType) -> Color {
        switch type {
        case .tradeProposal:
            return .blue
        case .tradeAccepted:
            return .green
        case .tradeRejected:
            return .red
        case .message:
            return .purple
        case .other:
            return .gray
        }
    }
}

// MARK: - Preview

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeScreen()
                .environmentObject(ProductManager.shared)
        }
    }
}

