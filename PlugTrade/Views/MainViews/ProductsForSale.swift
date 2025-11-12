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
                .zIndex(1)

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
    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    @State private var deleteError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 点图进详情
       
            // MARK: SNeil
                ProductImage(urlString: item.imageURL)
            // MARK: end

            HStack {
                // 左侧价格（出售一定有价格，空则显示 0）
                Text("$\(String(format: "%.0f", item.price ?? 0))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Spacer()

                // 右侧操作：编辑 / 删除
                HStack(spacing: 18) {
                    Button {
                        showEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                            .imageScale(.large)
                            .accessibilityLabel("Edit")
                    }

                    Button {
                        showDeleteConfirm = true
                    } label: {
                        if isDeleting {
                            ProgressView()
                        } else {
                            Image(systemName: "trash")
                                .imageScale(.large)
                        }
                    }
                    .tint(.red)
                    .accessibilityLabel("Delete")
                    .confirmationDialog(
                        "Delete this item?",
                        isPresented: $showDeleteConfirm,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) { deleteItem() }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("This action cannot be undone.")
                    }
                }
                .font(.title3)
            }
            .padding(.horizontal)

            if let deleteError {
                Text(deleteError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditSaleSheet(item: item)
                .presentationDetents([.medium, .large])
        }
    }

    private func deleteItem() {
        guard let id = item.id else { return }
        isDeleting = true
        deleteError = nil
        Firestore.firestore().collection("products").document(id).delete { err in
            isDeleting = false
            if let err = err {
                deleteError = "Delete failed: \(err.localizedDescription)"
            }
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

// MARK: - Inline Edit Sheet for Sale Items
private struct EditSaleSheet: View {
    let item: Item
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var priceString: String
    @State private var location: String
    @State private var category: Category
    @State private var quantity: Int
    @State private var isSaving = false
    @State private var errorText: String?

    init(item: Item) {
        self.item = item
        _title = State(initialValue: item.title)
        _priceString = State(initialValue: String(format: "%.2f", item.price ?? 0))
        _location = State(initialValue: item.location)
        _category = State(initialValue: item.category)
        _quantity = State(initialValue: item.quantity)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Basic") {
                    TextField("Title", text: $title)

                    TextField("Price", text: $priceString)
                        .keyboardType(.decimalPad)

                    TextField("Location", text: $location)

                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { c in
                            Text(c.rawValue.capitalized).tag(c)
                        }
                    }

                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)
                }

                if let errorText {
                    Text(errorText)
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving…" : "Save") {
                        save()
                    }.disabled(isSaving)
                }
            }
        }
    }

    private func save() {
        guard let id = item.id else { return }
        isSaving = true
        errorText = nil

        // 解析价格；失败则沿用旧值或置 0
        let newPrice = Double(priceString.replacingOccurrences(of: ",", with: ".")) ?? (item.price ?? 0)

        let data: [String: Any] = [
            "title": title,
            "price": newPrice,
            "location": location,
            "category": category.rawValue,
            "quantity": quantity,
            "timestamp": Timestamp(date: Date()) // 更新排序时间
        ]

        Firestore.firestore()
            .collection("products")
            .document(id)
            .updateData(data) { err in
                isSaving = false
                if let err = err {
                    errorText = err.localizedDescription
                } else {
                    dismiss()
                }
            }
    }
}


// MARK: - Preview
#Preview {
    ProductsForSale()
        .environmentObject(ProductManager.shared)
}
