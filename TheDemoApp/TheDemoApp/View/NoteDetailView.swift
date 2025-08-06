import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @State private var images: [UIImage] = []
    @State private var currentImageIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !images.isEmpty {
                    TabView(selection: $currentImageIndex) {
                        ForEach(0..<images.count, id: \.self) { index in
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFit()
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 300)
                    
                    // Image counter
                    if images.count > 1 {
                        Text("\(currentImageIndex + 1) / \(images.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(note.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(note.description)
                        .font(.body)
                    
                    Text("Created: \(formattedDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadImages()
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: note.createdAt)
    }
    
    private func loadImages() {
        images = note.photoUrls.compactMap { url in
            StorageManager.shared.loadImage(filename: url)
        }
    }
}