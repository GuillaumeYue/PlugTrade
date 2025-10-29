//
//  User.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-27.
//

import Foundation

struct AppUser: Identifiable, Codable {
    let id: String            // Firebase uid
    let email: String
    var displayName: String?
    var avatarURL: String?
    var createdAt: Date

    init(uid: String, email: String, displayName: String? = nil, avatarURL: String? = nil, createdAt: Date = Date()) {
        self.id = uid
        self.email = email
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }
}

