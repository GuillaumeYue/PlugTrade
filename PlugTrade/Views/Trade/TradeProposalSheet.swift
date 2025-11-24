//
//  TradeProposalSheet.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-09.
//

import FirebaseFirestore
import SwiftUI
import Foundation

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
            .navigationTitle("Send Proposal")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toast(isPresented: $toast.show, message: toast.message)
        .onAppear { productManager.fetchMyProducts() }
    }
    // MARK: Sections
    private var header: some View {
        HStack(spacing: 12) {
            SDWebImageAsync(
                url: URL(string: targetItem.imageURL),
                placeholder: Image(systemName: "photo")
            )
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))


            VStack(alignment: .leading) {
                Text(targetItem.title).font(.subheadline).lineLimit(2)
                Text("From:\(targetItem.sellerName)").font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
    }
    
    private var contentList: some View {
        Group {
            if (productManager.userProductsLoaded == false && productManager.MyProducts.isEmpty) {
                VStack(spacing: 10) {
                    ProgressView()
                    Text("Loading my Post")
                        .font(.caption).foregroundColor(.secondary)
                    Button("Reload") { productManager.fetchMyProducts() } // id
                        .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if productManager.userProductsLoaded == true && productManager.MyProducts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "shippingbox").imageScale(.large)
                    Text("You haven't listed any items yet.").font(.subheadline)
                    Text("Post an item now to start trading!")
                        .font(.caption).foregroundColor(.secondary)
                }
            } else {
                List {
                    Section(header: Text("Choose an item to trade")) {
                        ForEach(productManager.MyProducts.filter{$0.itemType == .forTrade}) { item in
                            OfferSelectableRow(
                                item: item,
                                isSelected: selectedIDs.contains(item.id ?? ""),
                                onToggle: { toggleSelection(id: item.id) }
                            )
                        }
                    }
                    Section(header: Text("Comment(optional)")) {
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
                if isSubmitting { ProgressView() } else { Text("Send Proposal") }
            }
            .buttonStyle(.borderedProminent)
            .disabled(
                isSubmitting || selectedIDs.isEmpty
                    || authService.currentUser == nil
            )

            Button("Cancel") { isPresented = false }
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
            "senderId": buyerID,  
            "offeredItemIDs": Array(selectedIDs),
            "note": note,
            "status": "pending",
            "timestamp": Timestamp(date: Date()),
        ]


        Firestore.firestore().collection("trade_proposals").addDocument(
            data: payload
        ) { error in
            DispatchQueue.main.async {
                self.isSubmitting = false
            }
            if let error = error {
                DispatchQueue.main.async {
                    self.toast = ("Proposal failed:\(error.localizedDescription)", true)
                }
            } else {
                DispatchQueue.main.async {
                    self.toast = ("Proposal sent successfully!", true)
                }
                
                // Create notification for the seller
                let sellerID = targetItem.sellerID
                let senderName = authService.currentUser?.name ?? "Someone"
                
                print("📤 Creating notification for seller: \(sellerID)")
                print("   Sender: \(senderName)")
                print("   Product ID: \(productID)")
                
                NotificationService.shared.createNotification(
                    userId: sellerID,
                    title: "New Trade Proposal",
                    body: "\(senderName) wants to trade with you",
                    type: .tradeProposal,
                    relatedItemId: productID
                )
                
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
                SDWebImageAsync(
                    url: URL(string: item.imageURL),
                    placeholder: Image(systemName: "photo")
                )
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
            pm.MyProducts = SampleData.items
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
            .environmentObject(ProductManager())
        }
    }
#endif
