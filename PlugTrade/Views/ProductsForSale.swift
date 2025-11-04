import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProductsForSale: View {
    @EnvironmentObject var productManager: ProductManager
    @State private var expandedItemID: String? = nil // Track which item is expanded

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(productManager.userProducts) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("$\(item.price, specifier: "%.2f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(item.timestamp, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Image(systemName: expandedItemID == item.id ? "chevron.compact.up" : "chevron.compact.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) {
                                expandedItemID = (expandedItemID == item.id ? nil : item.id)
                            }
                        }

                        
                        if expandedItemID == item.id {
                            VStack(alignment: .leading, spacing: 10) {
                                NavigationLink(destination: DetailView(item: item)) {
                                    AsyncImage(url: URL(string: item.imageURL)) { phase in
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
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .padding(.bottom, 10)
                        }

                        Divider()
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.top)
            
         

        }
        .navigationTitle("My Products")
        .onAppear{
            print("Current user ID: \(Auth.auth().currentUser?.uid ?? "none")")
        productManager.fetchUserProducts()
    }
      
    }
}



#Preview {
    ProductsForSale()
        .environmentObject(ProductManager.shared)
}
