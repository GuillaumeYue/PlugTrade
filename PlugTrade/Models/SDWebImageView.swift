import SwiftUI
import SDWebImage

struct SDWebImageAsync: View {
    let url: URL?
    let placeholder: Image
    
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
            } else {
                placeholder
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear(perform: load)
    }
    
    private func load() {
        guard let url = url else { return }
        let key = url.absoluteString
        
        if let cached = ImageCache.shared.get(key){
            self.image = cached
            return
        }
        
        SDWebImageDownloader.shared.downloadImage(with: url) { (img, _, _, _) in
            if let img = img {
                DispatchQueue.main.async {
                    self.image = img
                    
                    
                    ImageCache.shared.set(key, img)
                }
            }
        }
    }
}
