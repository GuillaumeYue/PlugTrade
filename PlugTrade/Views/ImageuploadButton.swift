//
//  ImageUploadButton.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-28.
//

//
//  ImageUploadButton.swift
//  PlugTrade
//
//  Created by Shaquille O Neil on 2025-10-28.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseAuth

struct ImageUploadButton: View {
    @Binding var selectedImageData: Data?
    var onUploadComplete: ((String) -> Void)? = nil

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isUploading = false

    var body: some View {
        ZStack {
            if isUploading {
                ProgressView()
                    .frame(width: 35, height: 35)
            } else {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 35, height: 35)
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            await uploadToFirebaseStorage(data: data)
                        }
                    }
                }
            }
        }
    }

    private func uploadToFirebaseStorage(data: Data) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isUploading = true

        let storageRef = Storage.storage().reference()
            .child("profileImages/\(uid)_\(UUID().uuidString).jpg")

        do {
            _ = try await storageRef.putDataAsync(data)
            let downloadURL = try await storageRef.downloadURL()
            onUploadComplete?(downloadURL.absoluteString)
        } catch {
            print("Error uploading image: \(error.localizedDescription)")
        }

        isUploading = false
    }
}



#Preview {
    @State var sampleData: Data? = nil
    return ImageUploadButton(selectedImageData: .constant(sampleData))
}
