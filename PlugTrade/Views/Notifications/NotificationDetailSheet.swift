//
//  NotificationDetailSheet.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-17.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotificationDetailSheet: View {
    let notification: AppNotification
    @Binding var isPresented: Bool
    
    @EnvironmentObject private var productManager: ProductManager
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var notificationService: NotificationService
    
    @State private var tradeProposal: TradeProposal?
    @State private var targetItem: Item?
    @State private var offeredItems: [Item] = []
    @State private var senderName: String = "Unknown User"
    @State private var isLoading = true
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var toast: (message: String, show: Bool) = ("", false)
    
    var body: some View {
        NavigationView {
            Group {
                // Show brief view for accepted/rejected notifications
                if notification.type == .tradeAccepted || notification.type == .tradeRejected {
                    briefNotificationView
                } else if notification.type == .tradeProposal {
                    // Show full proposal details for trade proposal notifications
                    proposalDetailView
                } else {
                    // Show simple view for other notification types
                    briefNotificationView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
        .toast(isPresented: $toast.show, message: toast.message)
        .onAppear {
            if notification.type == .tradeProposal {
                loadProposalDetails()
            } else {
                // For accepted/rejected notifications, mark as read immediately
                if let notificationId = notification.id {
                    notificationService.markAsRead(notificationId)
                }
            }
        }
    }
    
    private var navigationTitle: String {
        switch notification.type {
        case .tradeProposal:
            return "Trade Proposal"
        case .tradeAccepted:
            return "Proposal Accepted"
        case .tradeRejected:
            return "Proposal Rejected"
        default:
            return "Notification"
        }
    }
    
    // MARK: - Brief Notification View (for accepted/rejected)
    
    private var briefNotificationView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: iconForType)
                    .font(.system(size: 60))
                    .foregroundColor(colorForType)
                    .padding(.top, 40)
                
                // Title
                Text(notification.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Body message
                Text(notification.body)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Timestamp
                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                // Related item if available
                if let relatedItemId = notification.relatedItemId {
                    Divider()
                        .padding(.vertical)
                    
                    Text("Related Item")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    loadRelatedItemView(itemId: relatedItemId)
                }
            }
            .padding()
        }
    }
    
    @State private var relatedItem: Item?
    
    private func loadRelatedItemView(itemId: String) -> some View {
        Group {
            if let item = relatedItem {
                HStack(spacing: 12) {

                    SDWebImageAsync(
                        url: URL(string: item.imageURL),
                        placeholder: Image(systemName: "photo")
                    )
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)

                        Text(item.location)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(item.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

            } else {
                ProgressView()
                    .padding()
                    .onAppear {
                        loadRelatedItem(itemId: itemId)
                    }
            }
        }
    }

    
    private func loadRelatedItem(itemId: String) {
        let db = Firestore.firestore()
        db.collection("products").document(itemId).getDocument { snapshot, error in
            if let snapshot = snapshot, let item = try? snapshot.data(as: Item.self) {
                DispatchQueue.main.async {
                    self.relatedItem = item
                }
            }
        }
    }
    
    private var iconForType: String {
        switch notification.type {
        case .tradeAccepted:
            return "checkmark.circle.fill"
        case .tradeRejected:
            return "xmark.circle.fill"
        default:
            return "bell.fill"
        }
    }
    
    private var colorForType: Color {
        switch notification.type {
        case .tradeAccepted:
            return .green
        case .tradeRejected:
            return .red
        default:
            return .blue
        }
    }
    
    // MARK: - Proposal Detail View (for trade proposal notifications)
    
    private var proposalDetailView: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading proposal details...")
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Error")
                        .font(.headline)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else if let proposal = tradeProposal, let target = targetItem {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        headerSection(proposal: proposal)
                        
                        Divider()
                        
                        // Target Item (Your item they want)
                        targetItemSection(item: target)
                        
                        Divider()
                        
                        // Offered Items (Items they're offering)
                        offeredItemsSection(items: offeredItems)
                        
                        // Note
                        if !proposal.note.isEmpty {
                            Divider()
                            noteSection(note: proposal.note)
                        }
                        
                        // Status
                        if proposal.status != "pending" {
                            Divider()
                            statusSection(status: proposal.status)
                        }
                    }
                    .padding()
                }
                .safeAreaInset(edge: .bottom) {
                    if proposal.status == "pending" {
                        actionButtons
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private func headerSection(proposal: TradeProposal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trade Proposal")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("From: \(senderName)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(notification.timestamp, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func targetItemSection(item: Item) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Item")
                .font(.headline)
            
            HStack(spacing: 12) {

                SDWebImageAsync(
                    url: URL(string: item.imageURL),
                    placeholder: Image(systemName: "photo")
                )
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)

                    Text(item.location)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

        }
    }
    
    private func offeredItemsSection(items: [Item]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items They're Offering")
                .font(.headline)
            
            if items.isEmpty {
                Text("Loading items...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(items) { item in
                    HStack(spacing: 12) {

                        SDWebImageAsync(
                            url: URL(string: item.imageURL),
                            placeholder: Image(systemName: "photo")
                        )
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.subheadline)

                            Text(item.location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }

                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func noteSection(note: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Message")
                .font(.headline)
            Text(note)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
    
    private func statusSection(status: String) -> some View {
        HStack {
            Text("Status:")
                .font(.headline)
            Spacer()
            Text(status.capitalized)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor(for: status))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: rejectProposal) {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("Reject")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isProcessing)
            
            Button(action: acceptProposal) {
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Accept")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isProcessing)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Actions
    
    private func loadProposalDetails() {
        guard let relatedItemId = notification.relatedItemId else {
            errorMessage = "No related item found"
            isLoading = false
            return
        }
        
        // Find the trade proposal for this item
        let db = Firestore.firestore()
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in"
            isLoading = false
            return
        }
        
        // Query without orderBy to avoid index requirement
        // We'll filter and sort in memory instead
        db.collection("trade_proposals")
            .whereField("productID", isEqualTo: relatedItemId)
            .whereField("sellerID", isEqualTo: currentUserId)
            .getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error loading proposal: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Proposal not found or already processed"
                        self.isLoading = false
                    }
                    return
                }
                
                // Filter by status and sort by timestamp in memory
                let proposals = documents.compactMap { doc -> TradeProposal? in
                    let data = doc.data()
                    let status = data["status"] as? String ?? "pending"
                    
                    // Only get pending proposals
                    guard status == "pending" else { return nil }
                    
                    return TradeProposal(
                        id: doc.documentID,
                        productID: data["productID"] as? String ?? "",
                        sellerID: data["sellerID"] as? String ?? "",
                        senderId: data["senderId"] as? String ?? "",
                        offeredItemIDs: data["offeredItemIDs"] as? [String] ?? [],
                        note: data["note"] as? String ?? "",
                        status: status,
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                .sorted { $0.timestamp > $1.timestamp } // Sort by timestamp descending
                
                guard let proposal = proposals.first else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No pending proposal found"
                        self.isLoading = false
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.tradeProposal = proposal
                    self.loadSenderName(senderId: proposal.senderId)
                    self.loadItems(proposal: proposal)
                }
            }
    }
    
    private func loadSenderName(senderId: String) {
        authService.fetchSellerProfile(userID: senderId) { name, _ in
            DispatchQueue.main.async {
                self.senderName = name
            }
        }
    }
    
    private func loadItems(proposal: TradeProposal) {
        let db = Firestore.firestore()
        
        // Load target item
        db.collection("products").document(proposal.productID).getDocument { snapshot, error in
            if let snapshot = snapshot, let targetItem = try? snapshot.data(as: Item.self) {
                DispatchQueue.main.async {
                    self.targetItem = targetItem
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Could not load target item"
                    self.isLoading = false
                    return
                }
            }
            
            // Load offered items
            var loadedItems: [Item] = []
            let group = DispatchGroup()
            
            if proposal.offeredItemIDs.isEmpty {
                DispatchQueue.main.async {
                    self.offeredItems = []
                    self.isLoading = false
                }
                return
            }
            
            for itemID in proposal.offeredItemIDs {
                group.enter()
                db.collection("products").document(itemID).getDocument { snapshot, error in
                    if let snapshot = snapshot, let item = try? snapshot.data(as: Item.self) {
                        loadedItems.append(item)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.offeredItems = loadedItems
                self.isLoading = false
            }
        }
    }
    
    private func acceptProposal() {
        guard let proposal = tradeProposal else { return }
        isProcessing = true
        
        let db = Firestore.firestore()
        db.collection("trade_proposals").document(proposal.id).updateData([
            "status": "accepted"
        ]) { error in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                if let error = error {
                    self.toast = ("Error accepting proposal: \(error.localizedDescription)", true)
                } else {
                    self.toast = ("Proposal accepted!", true)
                    
                    // Create notification for sender
                    self.notificationService.createNotification(
                        userId: proposal.senderId,
                        title: "Trade Proposal Accepted",
                        body: "\(self.authService.currentUser?.name ?? "Someone") accepted your trade proposal",
                        type: .tradeAccepted,
                        relatedItemId: proposal.productID
                    )
                    
                    // Mark notification as read
                    if let notificationId = self.notification.id {
                        self.notificationService.markAsRead(notificationId)
                    }
                    
                    // Close sheet after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.isPresented = false
                    }
                }
            }
        }
    }
    
    private func rejectProposal() {
        guard let proposal = tradeProposal else { return }
        isProcessing = true
        
        let db = Firestore.firestore()
        db.collection("trade_proposals").document(proposal.id).updateData([
            "status": "rejected"
        ]) { error in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                if let error = error {
                    self.toast = ("Error rejecting proposal: \(error.localizedDescription)", true)
                } else {
                    self.toast = ("Proposal rejected", true)
                    
                    // Create notification for sender
                    self.notificationService.createNotification(
                        userId: proposal.senderId,
                        title: "Trade Proposal Rejected",
                        body: "\(self.authService.currentUser?.name ?? "Someone") rejected your trade proposal",
                        type: .tradeRejected,
                        relatedItemId: proposal.productID
                    )
                    
                    // Mark notification as read
                    if let notificationId = self.notification.id {
                        self.notificationService.markAsRead(notificationId)
                    }
                    
                    // Close sheet after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.isPresented = false
                    }
                }
            }
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "accepted":
            return .green
        case "rejected":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Trade Proposal Model

struct TradeProposal: Identifiable {
    let id: String
    let productID: String
    let sellerID: String
    let senderId: String
    let offeredItemIDs: [String]
    let note: String
    let status: String
    let timestamp: Date
}

