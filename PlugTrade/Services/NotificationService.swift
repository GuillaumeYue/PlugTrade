//
//  NotificationService.swift
//  PlugTrade
//
//  Created by Frostmourne on 2025-11-17.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private init() {}
    
    func startListening() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("NotificationService: No user logged in")
            return
        }
        
        print("NotificationService: Starting listener for user: \(userId)")
        
        // Remove existing listener
        listener?.remove()
        
        // Try to use indexed query first
        let query = db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
        
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                // If index error, fall back to simpler query
                if error.localizedDescription.contains("index") {
                    print("Index error, falling back to simple query")
                    self.startListeningSimple()
                    return
                }
                print("NotificationService: Error listening: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("NotificationService: No documents")
                return
            }
            
            var loadedNotifications: [AppNotification] = []
            
            for document in documents {
                do {
                    var notification = try document.data(as: AppNotification.self)
                    notification.id = document.documentID
                    loadedNotifications.append(notification)
                } catch {
                    print("❌ Error decoding notification \(document.documentID): \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.notifications = loadedNotifications
                self.unreadCount = loadedNotifications.filter { !$0.isRead }.count
                print("NotificationService: Loaded \(loadedNotifications.count) notifications, \(self.unreadCount) unread")
            }
        }
    }
    
    private func startListeningSimple() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let query = db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .limit(to: 50)
        
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("NotificationService: Error in query: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var loadedNotifications: [AppNotification] = []
            
            for document in documents {
                do {
                    var notification = try document.data(as: AppNotification.self)
                    notification.id = document.documentID
                    loadedNotifications.append(notification)
                } catch {
                    print("Error decoding notification: \(error)")
                }
            }
            
            // Sort by timestamp in memory
            loadedNotifications.sort { $0.timestamp > $1.timestamp }
            
            DispatchQueue.main.async {
                self.notifications = loadedNotifications
                self.unreadCount = loadedNotifications.filter { !$0.isRead }.count
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
        DispatchQueue.main.async {
            self.notifications = []
            self.unreadCount = 0
        }
        print("Notification listener stopped listening")
    }
    
    func createNotification(userId: String, title: String, body: String, type: NotificationType, relatedItemId: String? = nil) {
        print("Creating notification")
        print("   User ID: \(userId)")
        print("   Title: \(title)")
        print("   Type: \(type.rawValue)")
        
        var notificationDict: [String: Any] = [
            "userId": userId,
            "title": title,
            "body": body,
            "type": type.rawValue,
            "isRead": false,
            "timestamp": Timestamp(date: Date())
        ]
        
        if let relatedItemId = relatedItemId {
            notificationDict["relatedItemId"] = relatedItemId
        }
        
        db.collection("notifications").addDocument(data: notificationDict) { [weak self] error in
            if let error = error {
                print("Error creating notification: \(error.localizedDescription)")
            } else {
                print("Notification created successfully")
                // Verify it was created
                self?.verifyNotificationCreated(userId: userId, title: title)
            }
        }
    }
    
    private func verifyNotificationCreated(userId: String, title: String) {
        db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .whereField("title", isEqualTo: title)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Could not verify notification: \(error.localizedDescription)")
                } else if let docs = snapshot?.documents, !docs.isEmpty {
                    print("Notification verified successfully")
                } else {
                    print("No notification found in Firestore")
                }
            }
    }
    
    func markAsRead(_ notificationId: String) {
        db.collection("notifications").document(notificationId).updateData([
            "isRead": true
        ]) { error in
            if let error = error {
                print("Error marking notification as read: \(error.localizedDescription)")
            } else {
                print("Notification marked successfully")
            }
        }
    }
    
    func markAllAsRead() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        let unreadNotifications = notifications.filter { !$0.isRead }
        
        for notification in unreadNotifications {
            guard let id = notification.id else { continue }
            let ref = db.collection("notifications").document(id)
            batch.updateData(["isRead": true], forDocument: ref)
        }
        
        batch.commit { error in
            if let error = error {
                print("Error marking all as read: \(error.localizedDescription)")
            } else {
                print("✅ All notifications marked successfully")
            }
        }
    }
    
    func fetchNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var loadedNotifications: [AppNotification] = []
                for document in documents {
                    do {
                        var notification = try document.data(as: AppNotification.self)
                        notification.id = document.documentID
                        loadedNotifications.append(notification)
                    } catch {
                        print("Error decoding: \(error)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.notifications = loadedNotifications
                    self.unreadCount = loadedNotifications.filter { !$0.isRead }.count
                }
            }
    }
}

