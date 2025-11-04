import SwiftUI

/// TradeScreen
/// A simple marketplace screen that lists products from Firestore (ProductManager)
/// with category chips, search, and Add-to-Cart using FirebaseCartManager.
/// No extra view models used.

struct TradeScreen: View {
    @StateObject private var productManager = ProductManager.shared
    @StateObject private var cartManager = FirebaseCartManager()

    @State private var searchText: String = ""
    @State private var selectedCategory: Category = .all

    // Grid layout for cards
    private let columns = [
        GridItem(.flexible(minimum: 140), spacing: 12),
        GridItem(.flexible(minimum: 140), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Auth guard banner
                if AuthService.shared.currentUser == nil {
                    authBanner
                }

                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Category.allCases, id: \.self) { cat in
                            CategoryChip(
                                title: cat.rawValue.capitalized,
                                isSelected: selectedCategory == cat
                            ) {
                                withAnimation { selectedCategory = cat }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                    TextField("Search by title or city…", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    if !searchText.isEmpty {
                        Button("Clear") { searchText = "" }
                            .font(.footnote)
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Product grid
                Group {
                    if productManager.isLoading {
                        ProgressView("Loading products…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredItems.isEmpty {
                        ContentEmptyState()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(filteredItems) { item in
                                    NavigationLink(destination: ItemDetailView(item: item, cartManager: cartManager)) {
                                        ItemCard(item: item, isInCart: cartManager.isInCart(item: item)) {
                                            toggleCart(item)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .animation(.easeInOut, value: productManager.isLoading)
                .animation(.easeInOut, value: productManager.items.count)
                // Cart summary bar (only when has items)
                if !cartManager.cartItems.isEmpty {
                    CartSummaryBar(total: cartManager.totalPrice, count: cartManager.cartItems.count)
                }
            }
            .navigationTitle("Trade")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        CartView()
                            .environmentObject(cartManager)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "cart")
                            if cartManager.cartItems.count > 0 {
                                Text("\(cartManager.cartItems.count)")
                                    .font(.footnote).bold()
                            }
                        }
                    }
                }
            }
        }
    }

    private var filteredItems: [Item] {
        productManager.items.filter { item in
            let byCat = (selectedCategory == .all) || (item.category == selectedCategory)
            let bySearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
                || item.location.localizedCaseInsensitiveContains(searchText)
            return byCat && bySearch
        }
    }

    private func toggleCart(_ item: Item) {
        if cartManager.isInCart(item: item) {
            cartManager.removeFromCart(item: item)
        } else {
            cartManager.addToCart(item: item)
        }
    }

    private var authBanner: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "person.crop.circle.badge.exclam")
                .imageScale(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text("Sign in to trade")
                    .font(.headline)
                Text("List items for sale and sync your cart across devices.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            // Hook this to your Login screen when ready
            NavigationLink("Login") {
                LoginPlaceholderView()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Item Card
struct ItemCard: View {
    let item: Item
    let isInCart: Bool
    var onCartTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: item.imageURL)) { phase in
                switch phase {
                case .empty:
                    ZStack { Color(.tertiarySystemFill) ; ProgressView() }
                case .success(let img):
                    img
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ZStack { Color(.tertiarySystemFill) ; Image(systemName: "photo") }
                @unknown default:
                    Color(.tertiarySystemFill)
                }
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(item.title)
                .font(.subheadline)
                .lineLimit(2)
            Text("$\(String(format: "%.2f", item.price))")
                .font(.headline)
            Text(item.location)
                .font(.caption)
                .foregroundStyle(.secondary)

            Button(action: onCartTap) {
                HStack {
                    Image(systemName: isInCart ? "checkmark" : "cart.badge.plus")
                    Text(isInCart ? "In Cart" : "Add to Cart")
                        .bold()
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isInCart ? .green : .accentColor)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .accentColor : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty State
struct ContentEmptyState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .padding(.bottom, 4)
            Text("No items match your filters")
                .font(.headline)
            Text("Try a different category or search keyword.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
    }
}

// MARK: - Item Detail
struct ItemDetailView: View {
    let item: Item
    @ObservedObject var cartManager: FirebaseCartManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: item.imageURL)) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    ZStack { Color(.tertiarySystemFill) ; ProgressView() }
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.title3).bold()
                    HStack {
                        Text("$\(String(format: "%.2f", item.price))").font(.title3)
                        Spacer()
                        Text(item.category.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                    Text("Location: \(item.location)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Divider()
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("Seller: \(item.sellerName)")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Button {
                    if cartManager.isInCart(item: item) {
                        cartManager.removeFromCart(item: item)
                    } else {
                        cartManager.addToCart(item: item)
                    }
                } label: {
                    HStack {
                        Image(systemName: cartManager.isInCart(item: item) ? "checkmark" : "cart.badge.plus")
                        Text(cartManager.isInCart(item: item) ? "In Cart" : "Add to Cart")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(cartManager.isInCart(item: item) ? .green : .accentColor)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Cart Summary Bar
struct CartSummaryBar: View {
    let total: Double
    let count: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(count) item\(count == 1 ? "" : "s")")
                    .font(.subheadline)
                Text("Total: $\(String(format: "%.2f", total))")
                    .bold()
            }
            Spacer()
            Button("Checkout") { /* TODO: navigate to checkout */ }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Placeholder Login Screen
struct LoginPlaceholderView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMsg: String?

    var body: some View {
        Form {
            Section("Credentials") {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
            }
            if let errorMsg { Text(errorMsg).foregroundStyle(.red) }
            Button("Login") {
                AuthService.shared.login(email: email, password: password) { res in
                    switch res {
                    case .success:
                        break // Pop automatically by user
                    case .failure(let err):
                        errorMsg = err.localizedDescription
                    }
                }
            }
        }
        .navigationTitle("Login")
    }
}

// MARK: - Preview
#Preview {
    TradeScreen()
}
