import SwiftUI
import FirebaseFirestore



struct TradeScreen: View {
    @State private var allTrades: [Product] = []
    @State private var searchText: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var filtered: [Product] {
        let key = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return allTrades }
        return allTrades.filter { $0.title.localizedCaseInsensitiveContains(key) }
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText, placeholder: "Search trades…")
                .padding(.horizontal)
                .padding(.top, 8)

            if isLoading {
                ProgressView().padding(.top, 24)
            } else if let msg = errorMessage {
                VStack(spacing: 8) {
                    Text("Failed to load trades").foregroundColor(.secondary)
                    Text(msg).font(.footnote).foregroundColor(.secondary)
                    Button("Retry") { loadTrades() }
                }.padding(.top, 24)
            } else if filtered.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "shippingbox").font(.largeTitle)
                    Text("No trade products found").foregroundColor(.secondary)
                }.padding(.top, 24)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filtered) { p in
                            TradeCard(product: p)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle("Trade")
        .onAppear { loadTrades() }
    }

    private func loadTrades(limit: Int = 100) {
        isLoading = true
        errorMessage = nil
        let db = Firestore.firestore()
        db.collection("products")
            .whereField("isForTrade", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments { snap, err in
                isLoading = false
                if let err = err { errorMessage = err.localizedDescription; return }
                let docs = snap?.documents ?? []
                allTrades = docs.map { d in
                    let data = d.data()
                    return Product(
                        id: d.documentID,
                        title: data["title"] as? String ?? "",
                        detail: data["detail"] as? String,
                        price: data["price"] as? Double,
                        imageURL: data["imageURL"] as? String,
                        isForTrade: data["isForTrade"] as? Bool ?? false,
                        ownerId: data["ownerId"] as? String,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
                    )
                }
            }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search"

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}


struct TradeCard: View {
    let product: Product
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                if let u = product.imageURL, let url = URL(string: u) {
                    AsyncImage(url: url) { img in
                        img.resizable().scaledToFill()
                    } placeholder: { ProgressView() }
                    .clipped()
                    .cornerRadius(12)
                } else {
                    Image(systemName: "photo").font(.largeTitle).foregroundColor(.secondary)
                }
            }.frame(height: 130)

            Text(product.title).font(.headline).lineLimit(1)

            if let price = product.price {
                Text(String(format: "$ %.2f", price)).font(.subheadline).foregroundColor(.secondary)
            } else {
                Text("Trade only").font(.subheadline).foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}


#Preview {
    TradeScreen()
}
