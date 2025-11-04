//
//  ListProductScreen.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-26.
//
//
//  PostItemView.swift
//  PlugTrade
//
//  Created by mac on 2025-11-03.
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
                    TextField("Title", text: $title)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
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
                    .disabled(isPosting || title.isEmpty || price.isEmpty || location.isEmpty)
                }
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
        guard let priceValue = Double(price) else {
            alertMessage = "Please enter a valid price"
            showingAlert = true
            return
        }
        
        isPosting = true
        
        productManager.addProduct(
            title: title,
            price: priceValue,
            location: location,
            category: selectedCategory,
            image: imageData
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
    }
}

struct PostItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListProductScreen()
            .environmentObject(ProductManager.shared)
    }
}

