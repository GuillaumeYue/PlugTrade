//
//  SearchScreen.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//

//
//  ProductView.swift
//  PlugTrade
//
//  Created by mac on 2025-10-28.
//



import SwiftUI

struct SearchScreen: View {
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
        NavigationStack {
            VStack(spacing: 0) {
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
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(filteredItems) { item in
                                NavigationLink(destination: DetailView(item: item)) {
                                    ItemRowView(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Browse")
            .searchable(text: $searchText, prompt: "Search products")
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        SearchScreen()
            .environmentObject(ProductManager.shared)
    }
}
