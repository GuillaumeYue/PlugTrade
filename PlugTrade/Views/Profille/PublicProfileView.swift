//
//  PublicProfileView.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-11-12.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PublicProfileView: View {
    let userID: String
    @ObservedObject private var authManager = AuthService.shared
    @State var sellerName: String = ""
    @State var sellerImage = ""
    @State private var showsaleproducts: Bool = true
    @StateObject private var sellerProducts = PublicSellerProducts()
    @State private var showFull: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {

            // MARK: - Profile Image
            if let url = URL(string: sellerImage), !sellerImage.isEmpty {
                
                SDWebImageAsync(
                    url: URL(string: sellerImage),
                    placeholder: Image(systemName: "person.circle.fill")
                )
                .frame(width: 120, height: 150)
                .clipShape(Circle())
                .aspectRatio(contentMode: .fit)
                .onTapGesture {showFull.toggle()}
                .fullScreenCover(isPresented: $showFull) {
                    ZStack {
                           Color.black.ignoresSafeArea()

                           SDWebImageAsync(
                               url: URL(string: sellerImage),
                               placeholder: Image(systemName: "photo")
                           )
                           .scaledToFit()
                           .onTapGesture { showFull = false }
                       }
                }
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )

            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray.opacity(0.6))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
            }

            // MARK: - Name
            Text(sellerName)
                .font(.title)
                .fontWeight(.bold)

            Divider()

            // MARK: - Product Toggle
            Section(header: Text("Products")) {
                Picker("", selection: $showsaleproducts) {
                    Text("Products for sale").tag(true)
                    Text("Products for trade").tag(false)
                }
                .pickerStyle(.segmented)

                if showsaleproducts {
                    PublicProductsForSale(fetcher: sellerProducts, sellerID: userID)
                } else {
                    PublicProductsForTrade(fetcher: sellerProducts, sellerID: userID)
                }


            }
        }
        .padding(.top, 50)
        .ignoresSafeArea(.container, edges: .top)
        .onAppear {
            authManager.fetchSellerProfile(userID: userID) { name, url in
                   sellerName = name
                   sellerImage = url
               }
            sellerProducts.load(for: userID)
        }
    }
}

// PREVIEW
#Preview {
    PublicProfileView(userID: "iYje6iZ2snZ9ILWzxhPeGBxAp1F2")
        .environmentObject(ProductManager.shared)
}
