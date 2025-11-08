import SwiftUI

struct TradeScreen: View {
    @EnvironmentObject private var productManager: ProductManager
    @EnvironmentObject private var authService: AuthService

    @State private var searchText: String = ""
    @State private var selectedCategory: Category = .all

    @State private var showingProposalSheet = false
    @State private var proposingForItem: Item? = nil

    init() {}
    var body: some View {
        NavigationView {  // keep NavigationView for iOS 15
            VStack(spacing: 0) {
                signInBanner
                searchBar
                categoryChips
                contentList
            }
            .navigationTitle("Trade")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingProposalSheet) {
            if let target = proposingForItem {
                TradeProposalSheet(
                    targetItem: target,
                    isPresented: $showingProposalSheet
                )
                .environmentObject(productManager)
                .environmentObject(authService)
            }
        }
        .onAppear { productManager.fetchUserProducts() }
    }
    // MARK: Sections
    private var signInBanner: some View {
        Group {
            if authService.currentUser == nil {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.exclam")
                        .imageScale(.large)
                    Text("Sign in to start trading").font(.subheadline)
                    Spacer()
                    NavigationLink(destination: AuthGate()) {
                        Text("Sign in").font(.subheadline).bold()
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding([.horizontal, .top])
            }
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
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").imageScale(.medium)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, authService.currentUser == nil ? 8 : 16)
    }
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // ensure .all appears first
                let cats: [Category] =
                    [.all] + Category.allCases.filter { $0 != .all }
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
                        ForEach(items) { item in
                            TradeItemCard(item: item) {
                                proposingForItem = item
                                showingProposalSheet = true
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 6)
                    }
                }
            }
        }
    }

    // MARK: Helpers
    private func filteredTradeItems() -> [Item] {
        productManager.items
            .filter { $0.itemType == .forTrade }
            .filter {
                selectedCategory == .all
                    ? true : $0.category == selectedCategory
            }
            .filter {
                guard !searchText.isEmpty else { return true }
                return $0.title.localizedCaseInsensitiveContains(searchText)
                    || $0.location.localizedCaseInsensitiveContains(searchText)
            }
    }
}

private struct EmptyStateView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox").imageScale(.large).font(
                .system(size: 28)
            )
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
            // Lightweight mocks for preview to avoid Firebase dependency
            let pm = ProductManager()
            pm.items = SampleData.items
            let auth = AuthService()
            return TradeScreen()
                .environmentObject(pm)
                .environmentObject(auth)
        }
    }
#endif
