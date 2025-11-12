//
//  PublicProfileView.swift
//  PlugTrade
//
// MARK:  Created by Shaquille O Neil on 2025-11-12.
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
    @StateObject private var productManager = ProductManager.shared
    
    
    var body: some View {
        
        VStack{
            if let url = URL(string: sellerImage), !sellerImage.isEmpty {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 120, height: 120)
                            }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray.opacity(0.6))
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
            }
            Text("\(sellerName)")
                .font(.title)
            Divider()
            Section(header: Text("Products")){
                Picker("", selection: $showsaleproducts) {
                    Text("Products for sale").tag(true)
                    Text("Products for trade").tag(false)
                }
                .pickerStyle(.segmented)
                .padding()

                if showsaleproducts {
                    PublicProductsForSale(sellerID: userID)
                        .environmentObject(productManager)
                } else {
                    PublicProductsForTrade(sellerID: userID)
                        .environmentObject(productManager)
                }
            }
        }
        .navigationTitle(sellerName.isEmpty ? "Profile" : sellerName)
        .onAppear{
            authManager.fetchSellerProfile(userID: userID){
                name, url in
                sellerName = name
                sellerImage = url
                
            }
        }
    }
}

#Preview {
    PublicProfileView(userID: "iYje6iZ2snZ9ILWzxhPeGBxAp1F2")
        
}
