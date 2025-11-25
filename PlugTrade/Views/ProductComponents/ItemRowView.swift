//
//  ItemRowView.swift
//  PlugTrade
//
// MARK:   Created Evelyne by mac on 2025-10-28.
//


//
//  ItemRowView.swift
//  PlugTrade
//

import SwiftUI
import SDWebImage

struct ItemRowView: View {
    let item: Item
    @State private var rotate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: IMAGE (using your pattern)
            SDWebImageAsync(
                url: URL(string: item.imageURL),
                placeholder: Image(systemName: "photo")
            )
            .frame(width: 200, height: 120)              
            .aspectRatio(contentMode: .fit)
            .clipped()
            .cornerRadius(8)
            
            .overlay(alignment: .bottomTrailing) {
                HStack(spacing: 16) {
                    Image(systemName: "heart")
                    Image(systemName: "message")
                    Image(systemName: "cart")
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(6)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(8)
            }
            
            // MARK: PRICE / TRADE BADGE
            HStack {
                if item.itemType == .forSale {
                    Text("$\(item.price ?? 0.0, specifier: "%.0f")")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.2.circlepath")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotate ? 360 : 0))
                            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotate)
                            .onAppear { rotate = true }

                        Text("For Trade")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.gradient)
                    )
                }
                Spacer()
            }
            
            // MARK: TITLE
            Text(item.title)
                .font(.subheadline)
                .lineLimit(2)

            // MARK: LOCATION
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption)
                Text(item.location)
                    .font(.caption)
            }
            .foregroundColor(.gray)
        }
        .padding([.horizontal, .bottom])
        .frame(width: 200, height: 230)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.systemGray6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.10), radius: 4, x: 0, y: 3)
        )
        .padding(4)
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(item: SampleData.items[1])
    }
}

