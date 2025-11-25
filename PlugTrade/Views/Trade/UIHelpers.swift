//
//  UIHelpers.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-09.
//

import SwiftUI

struct AvatarThumb: View {
    let url: String?
    
    var body: some View {
        if let urlString = url, let imageURL = URL(string: urlString) {
            SDWebImageAsync(
                url: imageURL,
                placeholder: Image(systemName: "person.fill")
            )
            .frame(width: 32, height: 32)
            .clipShape(Circle())
        } else {
            // Fallback when no URL exists
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(6)
                .background(Color.blue.opacity(0.3))
                .clipShape(Circle())
        }
    }
}

struct Chip: View {
    let text: String
    init(text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.tertiarySystemBackground))
            .clipShape(Capsule())
    }
}
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    init(title: String, isSelected: Bool, onTap: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color.accentColor.opacity(0.15)
                        : Color(.secondarySystemBackground)
                )
                .foregroundColor(isSelected ? .accentColor : .primary)
                .clipShape(Capsule())
        }
        .accessibilityLabel(Text(isSelected ? "Selected: \(title)" : title))
    }
}
#if DEBUG
    struct UIHelpers_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: 16) {
                AvatarThumb(url: nil)
                Chip(text: "For Trade")
                CategoryChip(title: "Mobile", isSelected: true, onTap: {})
            }
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }
#endif
