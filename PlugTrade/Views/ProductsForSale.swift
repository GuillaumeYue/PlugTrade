import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProductsForSale: View {
    @EnvironmentObject var productManager: ProductManager
    @State private var expandedItemID: String? = nil

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(productManager.userProducts.filter{ $0.itemType == .forSale}) { item in
                    ProductCard(
                        item: item,
                        expandedItemID: $expandedItemID
                    )
                }
            }
            .padding(.top)
        }
        .navigationTitle("My Products")
        .onAppear {
            print("Current user ID: \(Auth.auth().currentUser?.uid ?? "none")")
            productManager.fetchUserProducts()
        }
    }
}

// MARK: - Product Card
private struct ProductCard: View {
    let item: Item
    @Binding var expandedItemID: String?

    var isExpanded: Bool { expandedItemID == item.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
                .padding(.horizontal)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring()) {
                        expandedItemID = isExpanded ? nil : item.id
                    }
                }

            if isExpanded {
                ExpandedContent(item: item)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.bottom, 10)
            }

            Divider()
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                if item.itemType == .forSale {
                    Text("$\(String(format: "%.2f", item.price ?? 0))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }else{
                    Text("For Trade")
                           .font(.caption)
                           .foregroundColor(.orange)
                           .fontWeight(.semibold)
                }
                
            }

            Spacer()

            Text(item.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)

            Image(systemName: isExpanded ? "chevron.compact.up" : "chevron.compact.down")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Expanded Content
private struct ExpandedContent: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(destination: DetailView(item: item)) {
                ProductImage(urlString: item.imageURL)
            }

            HStack {
                Text("$\(String(format: "%.0f", item.price ?? 0))")
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
        }
    }
}

// MARK: - Product Image
private struct ProductImage: View {
    let urlString: String

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(ProgressView())
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
            case .failure:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(Image(systemName: "photo"))
            @unknown default:
                EmptyView()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProductsForSale()
        .environmentObject(ProductManager.shared)
}
