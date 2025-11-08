//
//  UIHelpers.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-09.
//

import SwiftUI

struct AvatarThumb: View {
    let url: String?
    init(url: String?) { self.url = url }
    var body: some View {
        Group {
            if let url, let u = URL(string: url) {
                AsyncImage(url: u) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        Color(.tertiarySystemFill)
                    }
                }
            } else {
                Color(.tertiarySystemFill)
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
        .accessibilityHidden(true)
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
