import SwiftUI
import FirebaseStorage
import FirebaseAuth
import UIKit

struct ImageUploadButton: View {
    @Binding var selectedImageData: Data?
    var onUploadComplete: ((String) -> Void)? = nil
    
    @State private var showPicker = false
    @State private var isUploading = false
    
    var body: some View {
        ZStack {
            if isUploading {
                ProgressView()
                    .frame(width: 35, height: 35)
            } else {
                Button(action: { showPicker = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 35, height: 35)
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .sheet(isPresented: $showPicker) {
                    UIImagePickerControllerWrapper(selectedImageData: $selectedImageData) { data in
                        Task {
                            if let data {
                                await uploadToFirebaseStorage(data: data)
                            }
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

// MARK: UIImagePickerController wrapper
struct UIImagePickerControllerWrapper: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?
    var completion: (Data?) -> Void
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: UIImagePickerControllerWrapper
        init(_ parent: UIImagePickerControllerWrapper) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let data = uiImage.jpegData(compressionQuality: 0.8)
                parent.selectedImageData = data
                parent.completion(data)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}


#Preview {
    @State var sampleData: Data? = nil
    return ImageUploadButton(selectedImageData: .constant(sampleData)) { url in
        print("Uploaded URL: \(url)")
    }
}
