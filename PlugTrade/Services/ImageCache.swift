//
//  ImageCache.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-23.
//

import UIKit
import Foundation

final class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private var cache: [String: UIImage] = [:]

    func set(_ url: String, _ image: UIImage) {
        cache[url] = image
    }

    func get(_ url: String) -> UIImage? {
        return cache[url]
    }
}
