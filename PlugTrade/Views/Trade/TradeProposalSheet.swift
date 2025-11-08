//
//  TradeProposalSheet.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-09.
//

import FirebaseFirestore
import SwiftUI

struct TradeProposalSheet: View {
    let targetItem: Item
    @Binding var isPresented: Bool

    @EnvironmentObject private var productManager: ProductManager
    @EnvironmentObject private var authService: AuthService

    @State private var selectedIDs: Set<String> = []
    @State private var note: String = ""
    @State private var isSubmitting = false
    @State private var toast: (message: String, show: Bool) = ("", false)

    init(targetItem: Item, isPresented: Binding<Bool>) {
        self.targetItem = targetItem
        self._isPresented = isPresented
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header
                Divider()
                contentList
                submitArea
            }
            .navigationTitle("发起交换")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toast(isPresented: $toast.show, message: toast.message)
        .onAppear { productManager.fetchUserProducts() }
    }
    // MARK: Sections
    private var header: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: targetItem.imageURL)) { phase in
                if case .success(let img) = phase {
                    img.resizable().scaledToFill()
                } else {
                    Color(.secondarySystemBackground)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(targetItem.title).font(.subheadline).lineLimit(2)
                Text("来自：\(targetItem.sellerName)").font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
    }
    private var contentList: some View {
        Group {
            if productManager.userProducts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "shippingbox").imageScale(.large)
                    Text("你还没有发布物品").font(.subheadline)
                    Text("先去上架一个，再回来发起交换吧。").font(.caption).foregroundColor(
                        .secondary
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section(header: Text("选择用于交换的物品")) {
                        ForEach(productManager.userProducts) { item in
                            OfferSelectableRow(
                                item: item,
                                isSelected: selectedIDs.contains(item.id ?? ""),
                                onToggle: { toggleSelection(id: item.id) }
                            )
                        }
                    }
                    Section(header: Text("备注（可选）")) {
                        TextEditor(text: $note).frame(minHeight: 80)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    private var submitArea: some View {
        VStack(spacing: 10) {
            Button {
                submitProposal()
            } label: {
                if isSubmitting { ProgressView() } else { Text("发送提议") }
            }
            .buttonStyle(.borderedProminent)
            .disabled(
                isSubmitting || selectedIDs.isEmpty
                    || authService.currentUser == nil
            )

            Button("取消") { isPresented = false }
                .padding(.top, 2)
        }
        .padding()
    }
    // MARK: Helpers
    private func toggleSelection(id: String?) {
        guard let id = id else { return }
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func submitProposal() {
        guard let buyerID = authService.currentUser?.id else { return }
        guard let productID = targetItem.id else { return }
        guard !selectedIDs.isEmpty else { return }

        isSubmitting = true
        let payload: [String: Any] = [
            "productID": productID,
            "sellerID": targetItem.sellerID,
            "buyerID": buyerID,
            "offeredItemIDs": Array(selectedIDs),
            "note": note,
            "status": "pending",
            "timestamp": Timestamp(date: Date()),
        ]

        Firestore.firestore().collection("trade_proposals").addDocument(
            data: payload
        ) { error in
            isSubmitting = false
            if let error = error {
                toast = ("发送失败：\(error.localizedDescription)", true)
            } else {
                toast = ("已发送交换提议", true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    isPresented = false
                }
            }
        }
    }
}
struct OfferSelectableRow: View {
    let item: Item
    let isSelected: Bool
    var onToggle: () -> Void

    init(item: Item, isSelected: Bool, onToggle: @escaping () -> Void) {
        self.item = item
        self.isSelected = isSelected
        self.onToggle = onToggle
    }
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: item.imageURL)) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        Color(.secondarySystemBackground)
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title).font(.subheadline).foregroundColor(
                        .primary
                    ).lineLimit(2)
                    Text(item.category.rawValue.capitalized).font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(
                    systemName: isSelected ? "checkmark.circle.fill" : "circle"
                ).imageScale(.large)
            }
        }
    }
}
#if DEBUG
    struct TradeProposalSheet_Previews: PreviewProvider {
        static var previews: some View {
            let pm = ProductManager()
            pm.userProducts = SampleData.items
            let auth = AuthService()
            let item =
                SampleData.items.first { $0.itemType == .forTrade }
                ?? SampleData.items[0]
            return TradeProposalSheet(
                targetItem: item,
                isPresented: .constant(true)
            )
            .environmentObject(pm)
            .environmentObject(auth)
        }
    }
#endif
