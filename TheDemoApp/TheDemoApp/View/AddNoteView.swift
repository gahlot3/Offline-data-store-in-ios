import SwiftUI
import PhotosUI
import AVFoundation
import Photos

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var descriptionText = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showCamera = false
    @State private var openCamera = false
    
    @State private var showPhotos = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var cameraPermissionGranted = false
    @State private var photoLibraryPermissionGranted = false
    @State private var showValidationTitle: Bool = false
    @State private var showValidationDescription: Bool = false

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    
                }.frame(height: 50)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Note Details")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .foregroundColor(Color.gray.opacity(0.7))
                    VStack{
                        HStack{
                            TextField("Title", text: $title)
                                .onChange(of: title) { newValue in
                                    // Limit to 100 characters
                                    if newValue.count > 100 {
                                        showValidationTitle = true
                                    }else{
                                        showValidationTitle = false
                                    }
                                }
                                .padding()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    showValidationTitle ? Color.red : Color.gray
                                        .opacity(0.5),
                                    lineWidth: 1
                                    
                                )
                        )
                        if showValidationTitle {
                            Text("Title must be between 5 and 100 characters.")
                                .font(.caption2)
                                .foregroundColor(.red)
                            
                        }
                    }
                    VStack{
                        HStack{
                            TextEditor(text:  $description)
                                .frame(height: 150)
                                .onChange(of: description) { newValue in
                               
                                    if newValue.count < 100 {
                                        showValidationDescription = true
                                    } else if newValue.count > 1000 {
                                        showValidationDescription = true
                                    }else{
                                        showValidationDescription = false
                                    }
                                    
                                    
                                }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    showValidationDescription ? Color.red : Color.gray
                                        .opacity(0.5),
                                    lineWidth: 1
                                )
                        )
                        if showValidationDescription {
                            Text("Description must be between 100 and 1000 characters.")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Photos")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .foregroundColor(Color.gray.opacity(0.7))
                    HStack {
                        PhotosPicker(selection: $selectedItems,
                                     maxSelectionCount: 10,
                                     matching: .images) {
                            if showPhotos {
                                
                                Label("Select Photos", systemImage: "photo.on.rectangle")
                            }else{
                                Label("Select Photos", systemImage: "photo.on.rectangle.slash")
                            }
                        }
                        Spacer()
                        Button {
                            openCamera = true
                        } label: {
                            Label("Take Photo", systemImage: "camera")
                        }
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<selectedImages.count, id: \.self) { index in
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            Button(action: { removeImage(at: index) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.red)
                                            }
                                                .padding(4),
                                            alignment: .topTrailing
                                        )
                                }
                            }
                        }
                    }
                    
                }
                .navigationTitle("Add Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveNote()
                        }
                    }
                }
                .onChange(of: selectedItems) { _ in
                    Task {
                        selectedImages = []
                        for item in selectedItems {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImages.append(image)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showCamera) {
                    ImagePicker(image: $selectedImages, sourceType: .camera)
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage)
                }
            }
            .padding(.horizontal)
            .onAppear() {
                checkAndRequestPermissions()
            }
        }
    }
    
    private func removeImage(at index: Int) {
        selectedImages.remove(at: index)
        selectedItems.remove(at: index)
    }
    
    private func saveNote() {
        // Validate title
        guard Note.validateTitle(title) else {
            showError = true
            errorMessage = "Title must be between 5 and 100 characters"
            return
        }
        
        // Validate description
        guard Note.validateDescription(description) else {
            showError = true
            errorMessage = "Description must be between 100 and 1000 characters"
            return
        }
        
        // Save images and get their URLs
        var photoUrls: [String] = []
        for image in selectedImages {
            if let url = StorageManager.shared.saveImage(image) {
                photoUrls.append(url)
            }
        }
        
        // Create and save note
        let note = Note(title: title,
                       description: description,
                       photoUrls: photoUrls)
        
        StorageManager.shared.saveNote(note)
        dismiss()
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermissionGranted = granted
                if !granted {
                    self.showError = true
                    showCamera = false
                    self.errorMessage = "Camera access is required to take photos. Please enable it in Settings."
                }else{
                    showCamera = true
                }
            }
        }
    }
    
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.photoLibraryPermissionGranted = status == .authorized
                if status != .authorized {
                    showPhotos = false
                    self.showError = true
                    self.errorMessage = "Photo library access is required to select photos. Please enable it in Settings."
                }else{
                    showPhotos = true
                }
            }
        }
    }
    
    private func checkAndRequestPermissions() {
        // Check camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            requestCameraPermission()
        case .restricted, .denied:
            showError = true
            errorMessage = "Camera access is required. Please enable it in Settings."
        case .authorized:
            cameraPermissionGranted = true
        @unknown default:
            break
        }
        
        // Check photo library permission
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            requestPhotoLibraryPermission()
        case .restricted, .denied:
            showError = true
            errorMessage = "Photo library access is required. Please enable it in Settings."
        case .authorized, .limited:
            photoLibraryPermissionGranted = true
        @unknown default:
            break
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: [UIImage]
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image.append(image)
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    AddNoteView()
}
