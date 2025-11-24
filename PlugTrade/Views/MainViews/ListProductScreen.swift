
//
//  PostItemView.swift
//  PlugTrade
//
// MARK:   Created by Evelyne mac on 2025-11-03.
//

import SwiftUI
import PhotosUI

struct ListProductScreen: View {
    @EnvironmentObject var productManager: ProductManager
    @State private var title = ""
    @State private var price = ""
    @State private var location = ""
    @State private var selectedCategory: Category = .mobile
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var quantity = ""
    @State private var lookingfor = ""
    @State private var selectedType: ItemTypeEnum = .forSale
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isPosting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Image")) {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Tap to select image")
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Section(header: Text("Product Details")) {
                    // MARK:  added by SNEIL
                    Picker("Transaction Type", selection:
                            $selectedType){
                        ForEach(ItemTypeEnum.allCases, id: \.self){
                            itemType in
                            Text(itemType.rawValue.capitalized).tag(itemType)
                        }
                    }
                    // MARK: end
                    TextField("Title", text: $title)
                    
                    // MARK: SNEIL
                    if selectedType == .forSale {
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                    }
                    if selectedType == .forTrade {
                        TextField("Looking For (comma separated)", text: $lookingfor)
                            .onChange(of: lookingfor) { newValue in
                                let parts = newValue.split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces)}
                                    .filter { !$0.isEmpty }
                                
                          if parts.count > 3 {
                              let limit = parts.prefix(3).joined(separator: ", ")
                              lookingfor = limit
                              alertMessage = "Please enter no more than 3 items"
                              showingAlert = true
                                    
                                }
                            }
                    }
                    // MARK: end of adjustment
                    
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    
                    TextField("Location", text: $location)
                    
                   
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Category.allCases.filter { $0 != .all }, id: \.self) { category in
                            Text(category.rawValue.capitalized).tag(category)
                        }
                    }
                }
                
                Section {
                    Button(action: postItem) {
                        if isPosting {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Posting...")
                                    .padding(.leading, 8)
                                Spacer()
                            }
                        } else {
                            HStack {
                                Spacer()
                                Text("Post Item")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                    }
                    .font(.headline)
                    .frame(width: 350, height: 50 )
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .listRowBackground(Color.clear)
                    .disabled(
                        // MARK: adjusted by S.Neil
                        selectedType == .forSale
                           ? (isPosting || title.isEmpty || price.isEmpty || location.isEmpty || quantity.isEmpty)
                       
                        : (isPosting || title.isEmpty ||  location.isEmpty || quantity.isEmpty))
                    // MARK: end of adjustment
                }.frame(width: 350, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .scrollContentBackground(.hidden)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
                            )
            }
            .navigationTitle("Post New Item")
            .alert("Post Status", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        clearForm()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: selectedImage) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }
    
    private func postItem() {
        
        
        // Turn the text into an array
        var lookingForArray = lookingfor
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        if lookingForArray.count > 3 {
            lookingForArray = Array(lookingForArray.prefix(3))
            alertMessage = "You can only add up to 3 items in 'Looking For'. Extra items were removed."
            showingAlert = true
        }

        
        
        if selectedType == .forSale, price.isEmpty {
            alertMessage = "Please enter a valid Price"
            showingAlert = true
            return
            
        }
        
      
       
        guard let quantityValue = Int(quantity) else {
            alertMessage = "Please enter a valid quantity"
            showingAlert = true
            return
        }
        
        isPosting = true
        
        let priceValue = Double(price) ?? 0.0
        
        productManager.addProduct(
            title: title,
            price: priceValue,
            location: location,
            category: selectedCategory,
            image: imageData,
            quantity: quantityValue,
            lookingFor: lookingForArray,
            itemType: selectedType
        ) { result in
            isPosting = false
            switch result {
            case .success:
                alertMessage = "Item posted successfully!"
                showingAlert = true
            case .failure(let error):
                alertMessage = "Failed to post item: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func clearForm() {
        title = ""
        price = ""
        location = ""
        selectedCategory = .mobile
        selectedImage = nil
        imageData = nil
        quantity = ""
        selectedType = .forSale
    }
}

struct PostItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListProductScreen()
            .environmentObject(ProductManager.shared)
    }
}

