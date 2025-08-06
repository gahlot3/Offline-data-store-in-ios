import SwiftUI

struct HomeView: View {
    @State private var notes: [Note] = []
    @State private var showingAddNote = false
    @StateObject private var userManager = UserManager.shared
    
    var body: some View {
        NavigationStack {
            List(notes) { note in
                NavigationLink(destination: NoteDetailView(note: note)) {
                    NoteRowView(note: note)
                }
            }
            .navigationTitle("My Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") {
                        userManager.logout()
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView()
                    .onDisappear() {
                        loadNotes()
                    }
            }
            .onAppear {
                loadNotes()
            }
        }
    }
    
    private func loadNotes() {
        notes = StorageManager.shared.getAllNotes()
    }
}

struct NoteRowView: View {
    let note: Note
    @State private var previewImage: UIImage?
    
    var body: some View {
        HStack {
            if let image = previewImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading) {
                Text(note.title)
                    .font(.headline)
                Text(note.description)
                    .font(.subheadline)
                    .lineLimit(2)
            }
        }
        .onAppear {
            if let firstPhotoUrl = note.photoUrls.first {
                previewImage = StorageManager.shared.loadImage(filename: firstPhotoUrl)
            }
        }
    }
}
