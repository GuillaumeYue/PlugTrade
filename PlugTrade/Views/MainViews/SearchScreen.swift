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
import SDWebImage

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
                        LazyVGrid(columns: [
                            GridItem(.fixed(190), spacing: 16),
                            GridItem(.fixed(190), spacing: 16)
                        ]) {
                            
                            ForEach(filteredItems) { item in
                                NavigationLink(destination: {
                                    if item.itemType == .forTrade {
                                        TradeItemCard(item: item, onPropose: {})
                                    } else {
                                        DetailView(item: item)
                                    }
                                }) {
                                    ItemRowView(item: item)      // ← now uses SDWebImageAsync
                                        .aspectRatio(0.8, contentMode: .fit)
                                }
                                .buttonStyle(.plain)
                            }
                        }
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
            .environmentObject(ProductManager())
    }
}
