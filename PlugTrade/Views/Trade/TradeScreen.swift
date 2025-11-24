import SwiftUI

struct TradeScreen: View {
    @EnvironmentObject private var productManager: ProductManager
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var cartManager: FirebaseCartManager
    @State private var searchText: String = ""
    @State private var selectedCategory: Category = .all
    @State private var showNotifications = false

    private struct ProposalWrapper: Identifiable {
        let id = UUID()
        let item: Item
    }
    @State private var sheetWrapper: ProposalWrapper?

    init() {}
    var body: some View {
        let circleBackgroundLayout: [(Color, CGFloat, CGFloat, CGFloat)] = [
            (.green.opacity(0.55), 260, -210, -490),
            (.purple.opacity(0.20), 160,  140, -280),
            (.blue.opacity(0.18),   120, -140, -120),
            (.red.opacity(0.15),   100, -180,  180),
            (.green.opacity(0.18),  150,  160,  280),
            (.orange.opacity(0.15), 130, -100,  300)
        ]
        NavigationView {
            ZStack{
                LinearGradient(
                       colors: [Color.white, Color.gray.opacity(0.05)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing
                   )
                   .ignoresSafeArea()

                  
                   ForEach(0..<circleBackgroundLayout.count, id: \.self) { i in
                       let circle = circleBackgroundLayout[i]
                       Circle()
                           .fill(circle.0)
                           .frame(width: circle.1, height: circle.1)
                           .offset(x: circle.2, y: circle.3)
                   }
                
                VStack(spacing: 0) {
                    searchBar
                    categoryChips
                    contentList
                }
                .navigationTitle("Trade")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {

                            // NOTIFICATIONS — merged + unread badge
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

                            // CART — merged full version
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

                            // PROFILE IMAGE
                            NavigationLink(destination: ProfileScreen()) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: 32, height: 32)

                                    if let urlString = authService.currentUser?.profilePictureURL,
                                       let url = URL(string: urlString) {
                                        SDWebImageAsync(
                                            url: url,
                                            placeholder: Image(systemName: "person.fill")
                                        )
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())

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
        .sheet(item: $sheetWrapper) { wrapper in
            TradeProposalSheet(
                targetItem: wrapper.item,
                isPresented: .constant(true)
            )
            .environmentObject(productManager)
            .environmentObject(authService)
            .background(Color(UIColor.systemBackground))
            .ifAvailableiOS16 { $0.presentationDetents([.medium, .large]) }
        }
        .onAppear {
            productManager.fetchUserProducts()
        }
    }


    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            TextField("Search trade items", text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").imageScale(.medium)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(12)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
        .frame(width: 390)
        .padding(.top, authService.currentUser == nil ? 8 : 16)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                let cats: [Category] = [.all] + Category.allCases.filter { $0 != .all }
                ForEach(cats, id: \.self) { cat in
                    CategoryChip(
                        title: cat.rawValue.capitalized,
                        isSelected: selectedCategory == cat,
                        onTap: { selectedCategory = cat }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var contentList: some View {
        let items = filteredTradeItems()
        return Group {
            if items.isEmpty {
                EmptyStateView(
                    title: "No trade items",
                    subtitle: "Try another category or keyword."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(items.filter{$0.sellerID != authService.currentUser!.id}) { item in
                            TradeItemCard(item: item) {
                                productManager.fetchUserProducts()
                                sheetWrapper = ProposalWrapper(item: item)
                            }
                        }
                        .padding(.horizontal)
                    
                    }
                }
            }
        }
    }


    // MARK: Helpers
    private func filteredTradeItems() -> [Item] {
        productManager.items
            .filter { $0.itemType == .forTrade }
            .filter { selectedCategory == .all ? true : $0.category == selectedCategory }
            .filter {
                guard !searchText.isEmpty else { return true }
                return $0.title.localizedCaseInsensitiveContains(searchText)
                    || $0.location.localizedCaseInsensitiveContains(searchText)
            }
    }
}


// iOS16 可选 detents helper
private extension View {
    @ViewBuilder
    func ifAvailableiOS16<Content: View>(_ transform: (Self) -> Content) -> some View {
        if #available(iOS 16.0, *) { transform(self) } else { self }
    }
}

private struct EmptyStateView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox").imageScale(.large).font(.system(size: 28))
            Text(title).font(.headline)
            Text(subtitle).foregroundColor(.secondary).font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#if DEBUG
struct TradeScreen_Previews: PreviewProvider {
    static var previews: some View {
        let pm = ProductManager()
        pm.items = SampleData.items
        
        return TradeScreen()
            .environmentObject(ProductManager.shared)
            .environmentObject(AuthService.shared)
            .environmentObject(NotificationService.shared)
            .environmentObject(FirebaseCartManager.shared)


    }
}
#endif
