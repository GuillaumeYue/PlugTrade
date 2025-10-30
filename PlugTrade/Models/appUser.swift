//
//  User.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-27.
//

import Foundation
import FirebaseFirestore

struct appUser: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var profilePictureURL: String?
    
}
