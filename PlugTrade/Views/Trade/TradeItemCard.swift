//
//  TradeItemCard.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-09.
//

import SwiftUI

struct TradeItemCard: View {
    let item: Item
    var onPropose: () -> Void

    @State private var sellerAvatarURL: String? = nil
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var productManager: ProductManager
    @EnvironmentObject private var notificationService: NotificationService
    @State private var sendTrade = false
    

    init(item: Item, onPropose: @escaping () -> Void) {
        self.item = item
        self.onPropose = onPropose
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(destination: TradeDetailView(item: item)) {
                SDWebImageAsync(
                    url: URL(string: item.imageURL),
                    placeholder: Image(systemName: "photo")
                )
                .frame(height: 180)
                .clipped()
                .cornerRadius(16)

            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.headline)
                .lineLimit(2)

            
            HStack(spacing: 10) {
                NavigationLink(destination: PublicProfileView(userID: item.sellerID)){
                    
                    AvatarThumb(url: sellerAvatarURL)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.sellerName).font(.subheadline)
                        Text(item.location).font(.caption).foregroundColor(
                            .secondary
                        )
                    }
                }
                Spacer()
                HStack(spacing: 6) {
                    Chip(text: "For Trade")
                    Chip(text: item.category.rawValue.capitalized)
                }
            }
            Button("Send Request") {
                sendTrade = true
            }
            .buttonStyle(.borderedProminent)
            .cornerRadius(12)
            .sheet(isPresented: $sendTrade) {
                TradeProposalSheet(targetItem: item, isPresented: $sendTrade)
                    .environmentObject(authService)
                    .environmentObject(productManager)
                    .environmentObject(notificationService)
            }

            DisclosureGroup {
                let wants = item.lookingfor ?? []
                if wants.isEmpty {
                    Text("No specific needs listed")
                } else {
                    ForEach(wants, id: \.self) { want in
                        Text(want).foregroundColor(.secondary)
                    }
                }
            } label: {
                    Text("Looking For")
                
            }

           
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.blue.opacity(0.15), radius: 12)
        .onAppear {
            if sellerAvatarURL == nil{
                authService.fetchSeller(id: item.sellerID) { url in
                    sellerAvatarURL = url
                }
            }
                     
            
        }
    }
}

#if DEBUG
    struct TradeItemCard_Previews: PreviewProvider {
        static var previews: some View {
            let i =
                SampleData.items.first { $0.itemType == .forTrade }
                ?? SampleData.items[0]
            return TradeItemCard(item: i, onPropose: {})
                .environmentObject(AuthService.shared)
                .padding()
                .previewLayout(.sizeThatFits)
                .environmentObject(ProductManager.shared)
        }
    }
#endif
