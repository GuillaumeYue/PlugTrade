//
//  ProductsForTrade.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-02.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProductsForTrade: View {
    @EnvironmentObject var productManager: ProductManager
    @State private var expandedItemID: String? = nil

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(productManager.userProducts.filter{ $0.itemType == .forTrade}) { item in
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
    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    @State private var deleteError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 点图进详情
        
                ProductImage(urlString: item.imageURL)
            

            HStack {
                // 左侧价格/标签（Trade 显示“For Trade”）
                if item.itemType == .forSale {
                    Text("$\(String(format: "%.0f", item.price ?? 0))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                } else {
                    Text("For Trade")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }

                Spacer()

                // 右侧操作：编辑 / 删除
                HStack(spacing: 18) {
                    // 编辑：弹出内置编辑表单
                    Button {
                        showEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                            .imageScale(.large)
                            .accessibilityLabel("Edit")
                    }

                    // 删除：确认后删除 Firestore 文档
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

            // 删除错误信息
            if let deleteError {
                Text(deleteError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
        // 内置编辑表单
        .sheet(isPresented: $showEditSheet) {
            EditTradeSheet(item: item)
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
    @State private var imageIsLoading: Bool = false
    let urlString: String

    var body: some View {
        SDWebImageAsync(
            url: URL(string: urlString),
            placeholder: Image(systemName: "photo")
        )
        .frame(height: 200)
        .clipped()
        .cornerRadius(8)
        .overlay(
            Group {
                if imageIsLoading {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                }
            }
        )

    }
}

// MARK: - Inline Edit Sheet for Trade Items
private struct EditTradeSheet: View {
    let item: Item
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var location: String
    @State private var category: Category
    @State private var quantity: Int
    @State private var isSaving = false
    @State private var errorText: String?
    @State private var lookingfor = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    init(item: Item) {
        self.item = item
        _title = State(initialValue: item.title)
        _location = State(initialValue: item.location)
        _category = State(initialValue: item.category)
        _quantity = State(initialValue: item.quantity)
        _lookingfor = State(initialValue: (item.lookingfor ?? []).joined(separator: ","))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Basic") {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)

                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { c in
                            Text(c.rawValue.capitalized).tag(c)
                        }
                    }

                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)
                    TextField("Looking For (comma separated)", text: $lookingfor)
                        .onChange(of: lookingfor) { newValue in
                            let parts = newValue.split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces)}
                                .filter { !$0.isEmpty }
                            
                            if parts.count > 3 {
                                let limit = parts.prefix(3).joined(separator: ", ")
                                lookingfor = limit
                                alertMessage = "Please enter no more than 3 items"
                                showingAlert = true
                                
                            }
                        }
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
        
        var lookingForArray = lookingfor
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        if lookingForArray.count > 3 {
            lookingForArray = Array(lookingForArray.prefix(3))
            alertMessage = "You can only add up to 3 items in 'Looking For'. Extra items were removed."
            showingAlert = true
        }
        
        isSaving = true
        errorText = nil

        // For Trade 不涉及 price；只更新常用字段
        let data: [String: Any] = [
            "title": title,
            "location": location,
            "category": category.rawValue,
            "quantity": quantity,
            "lookingfor": lookingForArray,
            "timestamp": Timestamp(date: Date()) // 可选：更新排序时间
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


#Preview {
    ProductsForTrade()
        .environmentObject(ProductManager.shared)
}
