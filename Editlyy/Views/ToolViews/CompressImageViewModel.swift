import SwiftUI
import PhotosUI
import Photos
import UIKit

@MainActor
final class CompressImageViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? {
        didSet { loadImage() }
    }
    @Published var selectedImage: UIImage?
    @Published var compressedImage: UIImage?
    @Published var compressionQuality: Double = 0.5
    @Published var isCompressing = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isSaved = false
    
    @Published var originalFileSize: Int64?
    @Published var compressedFileSize: Int64?
    
    private var imageURL: URL?
    private var compressedImageURL: URL?
    
    private func loadImage() {
        guard let selectedItem = selectedItem else { return }
        isLoading = true
        
        Task {
            do {
                guard let data = try await selectedItem.loadTransferable(type: Data.self) else {
                    throw ImageError.loadFailed
                }
                
                guard let uiImage = UIImage(data: data) else {
                    throw ImageError.invalidImage
                }
                
                // Save original image temporarily
                let temporaryURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpg")
                
                try data.write(to: temporaryURL)
                self.imageURL = temporaryURL
                
                // Get original file size
                let attributes = try FileManager.default.attributesOfItem(atPath: temporaryURL.path)
                self.originalFileSize = attributes[.size] as? Int64
                
                self.selectedImage = uiImage
                
            } catch {
                showError(message: "Failed to load image: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    func compressImage() {
        guard let selectedImage = selectedImage else { return }
        isCompressing = true
        
        Task {
            do {
                // Add a small delay to show loading state
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Create compressed image data
                guard let compressedData = selectedImage.jpegData(compressionQuality: compressionQuality) else {
                    throw ImageError.compressionFailed
                }
                
                // Save compressed image temporarily
                let temporaryURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpg")
                
                try compressedData.write(to: temporaryURL)
                self.compressedImageURL = temporaryURL
                
                // Get compressed file size
                let attributes = try FileManager.default.attributesOfItem(atPath: temporaryURL.path)
                self.compressedFileSize = attributes[.size] as? Int64
                
                // Create UIImage from compressed data
                guard let compressedUIImage = UIImage(data: compressedData) else {
                    throw ImageError.invalidImage
                }
                
                // Add a small delay before showing result
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                self.compressedImage = compressedUIImage
                self.isSaved = false
                
            } catch {
                showError(message: "Failed to compress image: \(error.localizedDescription)")
            }
            
            isCompressing = false
        }
    }
    
    func saveToGallery() {
        guard let compressedImage = compressedImage else {
            showError(message: "No compressed image available")
            return
        }
        
        Task {
            do {
                let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
                
                switch status {
                case .notDetermined:
                    // İzin henüz istenmemiş, izin iste
                    let granted = await PHPhotoLibrary.requestAuthorization(for: .addOnly) == .authorized
                    if granted {
                        try await saveImage(compressedImage)
                    } else {
                        showError(message: "Permission denied to save photos")
                    }
                    
                case .restricted, .denied:
                    // İzin verilmemiş, ayarlara yönlendir
                    showError(message: "Please allow access to photos in Settings to save images")
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        await UIApplication.shared.open(settingsUrl)
                    }
                    
                case .authorized, .limited:
                    // İzin var, kaydet
                    try await saveImage(compressedImage)
                    
                @unknown default:
                    showError(message: "Unknown photo library access status")
                }
                
            } catch {
                showError(message: "Failed to save image: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveImage(_ image: UIImage) async throws {
        try await UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        isSaved = true
        showError(message: "Image saved successfully!")
    }
    
    func shareImage() {
        guard let compressedImage = compressedImage else {
            showError(message: "No compressed image available")
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [compressedImage],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    func reset() {
        selectedItem = nil
        selectedImage = nil
        compressedImage = nil
        originalFileSize = nil
        compressedFileSize = nil
        isSaved = false
        
        // Clean up temporary files
        if let imageURL = imageURL {
            try? FileManager.default.removeItem(at: imageURL)
        }
        if let compressedImageURL = compressedImageURL {
            try? FileManager.default.removeItem(at: compressedImageURL)
        }
        
        imageURL = nil
        compressedImageURL = nil
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

enum ImageError: Error {
    case loadFailed
    case invalidImage
    case compressionFailed
} 
