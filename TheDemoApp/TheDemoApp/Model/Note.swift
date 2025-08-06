import Foundation
import UIKit

struct Note: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var photoUrls: [String]
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, description: String, photoUrls: [String] = [], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.photoUrls = photoUrls
        self.createdAt = createdAt
    }
    
    static func validateTitle(_ title: String) -> Bool {
        return title.count >= 5 && title.count <= 100
    }
    
    static func validateDescription(_ description: String) -> Bool {
        return description.count >= 100 && description.count <= 1000
    }
}

// Storage Manager for handling local persistence
class StorageManager {
    static let shared = StorageManager()
    private let userDefaultsKey = "savedNotes"
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func saveNote(_ note: Note) {
        var notes = getAllNotes()
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        } else {
            notes.append(note)
        }
        saveNotes(notes)
    }
    
    func getAllNotes() -> [Note] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let notes = try? JSONDecoder().decode([Note].self, from: data) else {
            return []
        }
        return notes
    }
    
    func deleteNote(_ note: Note) {
        var notes = getAllNotes()
        notes.removeAll { $0.id == note.id }
        saveNotes(notes)
        
        // Delete associated images
        for photoUrl in note.photoUrls {
            deleteImage(at: photoUrl)
        }
    }
    
    private func saveNotes(_ notes: [Note]) {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func saveImage(_ image: UIImage) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
            return filename
        }
        return nil
    }
    
    func loadImage(filename: String) -> UIImage? {
        let fileURL = documentsPath.appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private func deleteImage(at filename: String) {
        let fileURL = documentsPath.appendingPathComponent(filename)
        try? fileManager.removeItem(at: fileURL)
    }
}