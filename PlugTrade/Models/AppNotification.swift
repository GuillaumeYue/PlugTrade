//
//  AppNotification.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-17.
//

import Foundation
import FirebaseFirestore

enum NotificationType: String, Codable {
    case tradeProposal = "trade_proposal"
    case tradeAccepted = "trade_accepted"
    case tradeRejected = "trade_rejected"
    case message = "message"
    case other = "other"
}

struct AppNotification: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let title: String
    let body: String
    let type: NotificationType
    let relatedItemId: String?
    var isRead: Bool
    let timestamp: Date
    
    // Custom initializer for manual creation
    init(id: String? = nil, userId: String, title: String, body: String, type: NotificationType, relatedItemId: String?, isRead: Bool, timestamp: Date) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
        self.type = type
        self.relatedItemId = relatedItemId
        self.isRead = isRead
        self.timestamp = timestamp
    }
}

