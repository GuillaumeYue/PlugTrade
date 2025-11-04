//
//  ItemRowView.swift
//  PlugTrade
//
//  Created by mac on 2025-10-28.
//



import SwiftUI

struct ItemRowView: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: item.imageURL)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .overlay(Image(systemName: "photo"))
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(8)
            
            Text("$\(item.price, specifier: "%.0f")")
                .font(.headline)
                .foregroundColor(.blue)
            
            Text(item.title)
                .font(.subheadline)
                .lineLimit(2)
            
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption)
                Text(item.location)
                    .font(.caption)
            }
            .foregroundColor(.gray)
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(item: SampleData.items[0])
    }
}
