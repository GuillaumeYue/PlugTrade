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
    @State private var sendTrade = false
    

    init(item: Item, onPropose: @escaping () -> Void) {
        self.item = item
        self.onPropose = onPropose
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: item.imageURL)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(Color(.secondarySystemBackground))
                        ProgressView()
                    }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    ZStack {
                        Rectangle().fill(Color(.secondarySystemBackground))
                        Image(systemName: "photo")
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 180)
            .clipped()
            .cornerRadius(16)

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
//            Button(action: onPropose) {
//                Text("Send Request")
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//            }
//            .buttonStyle(.borderedProminent)
//            .cornerRadius(12)
            Button("Send Request"){
                sendTrade = true
            }
            .buttonStyle(.borderedProminent)
            .cornerRadius(12)
            .sheet(isPresented: $sendTrade){
                TradeProposalSheet(targetItem: item, isPresented: $sendTrade)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(18)
        .onAppear {
            
            // check the curren user
//            if let currentUser = authService.currentUser {
//                authService.fetchSeller(id: currentUser.id ?? item.sellerID) { url in
//                    sellerAvatarURL = url
//                }
//            }else {
                authService.fetchSeller(id: item.sellerID) { url in
                    sellerAvatarURL = url
                }
//            }
//            
            
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
                .environmentObject(AuthService())
                .padding()
                .previewLayout(.sizeThatFits)
                .environmentObject(ProductManager())
        }
    }
#endif
