//
//  ItemRowView.swift
//  PlugTrade
//
//  Created by mac on 2025-10-28.
//



import SwiftUI

struct ItemRowView: View {
    let item: Item
    @State private var rotate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Image
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
            .cornerRadius(8)

            // MARK: - Price or Trade badge
            HStack(alignment: .center) {
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
                            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                    )
                }

                Spacer()
            }

            // MARK: - Title
            Text(item.title)
                .font(.subheadline)
                .lineLimit(2)

            // MARK: - Location
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption)
                Text(item.location)
                    .font(.caption)
            }
            .foregroundColor(.gray)
        }
        .padding([.horizontal, .bottom])
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 200, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.systemGray6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
        )
        .padding(4)

           
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(item: SampleData.items[1])
         
    }
}
