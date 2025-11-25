# PlugTrade

An iOS trading platform app built with SwiftUI and Firebase, supporting both buying/selling and item trading functionality.

## Features

### User Authentication
- User registration and login
- Profile management
- Profile picture upload

### Product Management
- **Product Listing**: Support for listing items for sale and items for trade
- **Categories**: Mobile devices, laptops, watches, headsets, iPad, and more
- **Product Browsing**: Browse all products, filter by category, search functionality
- **Product Details**: View detailed product information, seller info, and location

### Sales Features
- Product pricing and sales
- Shopping cart functionality
- Price calculation

### Trading Features
- Item-for-item trade proposals
- Send and receive trade requests
- View trade proposal details
- Accept/reject trade proposals

### Notification System
- Real-time notification delivery
- Trade proposal notifications
- Trade status update notifications (accepted/rejected)
- Unread notification count

### Favorites
- Save favorite items
- View favorites list

### Profile Center
- View your listed products
- Manage items for sale
- Manage items for trade
- Edit profile information
- View other users' public profiles

## Tech Stack

### Frontend
- **SwiftUI** - User interface framework
- **Swift** - Programming language
- **SDWebImageSwiftUI** - Asynchronous image loading and caching

### Backend
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - Image storage

### Architecture Pattern
- **MVVM** - Model-View-ViewModel architecture
- **ObservableObject** - State management
- **EnvironmentObject** - Dependency injection

## Project Structure

```
PlugTrade/
├── Models/
│   ├── Item.swift              # Product data model
│   └── appUser.swift           # User data model
├── Services/
│   ├── AuthService.swift       # Authentication service
│   ├── ProductManager.swift    # Product management service
│   ├── FirebaseCartManager.swift # Shopping cart management
│   ├── FirebaseFavoritesManager.swift # Favorites management
│   ├── NotificationService.swift # Notification service
│   ├── Validators.swift        # Form validation
│   └── ImageCache.swift        # Image caching
├── Views/
│   ├── AuthFlow/              # Authentication flow
│   │   ├── AuthGate.swift
│   │   ├── LoginForm.swift
│   │   └── RegisterForm.swift
│   ├── MainViews/             # Main views
│   │   ├── HomeScreen.swift
│   │   ├── TabView.swift
│   │   ├── ProductsForSale.swift
│   │   ├── ProductsForTrade.swift
│   │   └── SearchScreen.swift
│   ├── ProductComponents/     # Product components
│   │   ├── DetailView.swift
│   │   ├── TradeDetailView.swift
│   │   ├── ItemRowView.swift
│   │   └── CartView.swift
│   ├── Trade/                 # Trading related
│   │   ├── TradeScreen.swift
│   │   ├── TradeProposalSheet.swift
│   │   └── TradeItemCard.swift
│   ├── Profille/              # Profile
│   │   ├── ProfileScreen.swift
│   │   ├── MyProducts.swift
│   │   └── ProfileEditView.swift
│   └── Notifications/          # Notifications
│       └── NotificationDetailSheet.swift
└── PlugTradeApp.swift         # App entry point
```

## Quick Start

### Prerequisites
- Xcode 14.0 or higher
- iOS 15.0 or higher
- Swift 5.7 or higher
- Firebase project configuration

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd PlugTrade
   ```

2. **Configure Firebase**
   - Create a new project in Firebase Console
   - Add an iOS app
   - Download `GoogleService-Info.plist`
   - Place `GoogleService-Info.plist` in the `PlugTrade/` directory

3. **Install dependencies**
   - Open `PlugTrade.xcodeproj`
   - Xcode will automatically resolve Swift Package Manager dependencies

4. **Configure Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read: if true;
         allow write: if request.auth != null && request.auth.uid == userId;
         match /cart/{itemId} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
       
       // Products collection
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null;
       }
       
       // Trade proposals collection
       match /trade_proposals/{proposalId} {
         allow create: if request.auth != null && 
           request.resource.data.senderId == request.auth.uid;
         allow read: if request.auth != null && 
           (resource.data.senderId == request.auth.uid || 
            resource.data.sellerID == request.auth.uid);
         allow update, delete: if request.auth != null && 
           (resource.data.senderId == request.auth.uid || 
            resource.data.sellerID == request.auth.uid);
       }
       
       // Notifications collection
       match /notifications/{notificationId} {
         allow create: if request.auth != null;
         allow read, update, delete: if request.auth != null && 
           resource.data.userId == request.auth.uid;
       }
     }
   }
   ```

5. **Create Firestore Index**
   - In Firebase Console, create a composite index:
     - Collection: `notifications`
     - Fields: `userId` (Ascending), `timestamp` (Descending)

6. **Run the project**
   - Select target device or simulator in Xcode
   - Press `Cmd + R` to run the app

## Configuration

### Firebase Services Configuration

The app uses the following Firebase services:

- **Authentication**: Email/password authentication
- **Firestore**: Stores user, product, trade proposal, and notification data
- **Storage**: Stores user profile pictures and product images

### Environment Variables

Ensure `GoogleService-Info.plist` is properly configured with:
- `PROJECT_ID`
- `API_KEY`
- `GCM_SENDER_ID`
- Other necessary configuration items

## Feature Descriptions

### Product Listing
Users can list new products in the "List" tab, selecting:
- Product type: For Sale or For Trade
- Product category
- Price (for sale items only)
- Product images
- Location information

### Trading Flow
1. Browse items available for trade
2. Select the item you want to trade for
3. Choose items from your own trade list to exchange
4. Send trade proposal
5. Recipient receives notification
6. Recipient can accept or reject the proposal

### Notification System
- Real-time notification listening
- Display unread notification count
- Tap notification to view details
- Support for accepting/rejecting trade proposals

## UI/UX Features

- Modern SwiftUI interface design
- Smooth navigation experience
- Real-time data updates
- Loading state indicators
- Error handling and user feedback
- Responsive layout

## Development Notes

### Code Standards
- Follow Swift official coding standards
- Use meaningful variable and function names
- Add necessary comments and documentation

### State Management
- Use `@StateObject` and `@ObservedObject` for state management
- Use `@EnvironmentObject` to share service instances
- Use `@Published` properties for reactive updates

### Async Operations
- Use `async/await` for asynchronous operations
- Ensure UI updates are executed on the main thread
- Proper error handling

## Known Issues

- Firestore composite index needs to be configured for notification functionality to work properly
- Image loading uses SDWebImage and requires network connection

## Future Plans

- [ ] Messaging/chat functionality
- [ ] Product rating system
- [ ] Trade history records
- [ ] Push notifications (APNs)
- [ ] Multi-language support
- [ ] Dark mode optimization

## Contributors

- Shaquille O Neil
- Evelyne
- Han


**Note**: This is a project under development, some features may still be in progress.
