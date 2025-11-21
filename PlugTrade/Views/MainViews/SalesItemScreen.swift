//
//  SearchScreen.swift
//  PlugTrade
//
//  MARK: Created by Shaquille O Neil on 2025-10-26.
//

//
//  ProductView.swift
//  PlugTrade
//
//  MARK: Created by Evelyne mac on 2025-10-28.
//



import SwiftUI
import SDWebImageSwiftUI

struct SalesItemScreen: View {
    @EnvironmentObject var productManager: ProductManager
    @State private var selectedCategory: Category = .all
    @State private var searchText = ""
    
    var filteredItems: [Item] {
        var items = productManager.items
        
        if selectedCategory != .all {
            items = items.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            items = items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        return items
    }
    
    var body: some View {
        let circleBackgroundLayout: [(Color, CGFloat, CGFloat, CGFloat)] = [
            (.green.opacity(0.55), 260, -210, -490),
            (.purple.opacity(0.20), 160,  140, -280),
            (.blue.opacity(0.18),   120, -140, -120),
            (.red.opacity(0.15),   100, -180,  180),
            (.green.opacity(0.18),  150,  160,  280),
            (.orange.opacity(0.15), 130, -100,  300)
        ]
        NavigationStack {
            ZStack{
                
                LinearGradient(
                    colors: [Color.white, Color.gray.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.container, edges: .top)
                
                
                ForEach(0..<circleBackgroundLayout.count, id: \.self) { i in
                    let circle = circleBackgroundLayout[i]
                    Circle()
                        .fill(circle.0)
                        .frame(width: circle.1, height: circle.1)
                        .offset(x: circle.2, y: circle.3)
                        .ignoresSafeArea(.container, edges: .top)
                }
                

                VStack(spacing: 0) {
                    HStack {
                        Text("Sales")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.leading)
                        Spacer()
                    }
                    .padding(.top, 8)
                    

                    searchBar

                    
                    // Category Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Category.allCases, id: \.self) { category in
                                Button(category.rawValue.capitalized) {
                                    selectedCategory = category
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(20)
                            }
                        }
                        .padding()
                    }
                    
                    // States
                    if productManager.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if filteredItems.isEmpty {
                        Spacer()
                        Text("No items found")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        
                        // RESULTS GRID
                        ScrollView {
                            LazyVStack(spacing: 14){
                                ForEach(filteredItems.filter {$0.itemType == .forSale}) { item in
                                    NavigationLink(destination: {
                                        DetailView(item: item)
                                    }) {
                                        SalesProductCard(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            } .padding(.horizontal)
                                .padding(.top, 6)
                        }
                    }
                }
                .navigationTitle("")
                .navigationBarHidden(true)

                
            }
           
        }
    }
    
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            TextField("Search Devices", text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").imageScale(.medium)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(12)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
    }
}



#Preview {
    SalesItemScreen()
        .environmentObject(ProductManager())
        .environmentObject(AuthService())
}
