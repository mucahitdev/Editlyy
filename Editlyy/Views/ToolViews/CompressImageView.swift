//
//  CompressImageView.swift
//  Editlyy
//
//  Created by Mücahit Kökdemir NTT on 31.01.2025.
//

import SwiftUI
import PhotosUI

struct CompressImageView: View {
    @StateObject private var viewModel = CompressImageViewModel()
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                loadingView
            } else if let image = viewModel.selectedImage {
                if viewModel.compressedImage == nil {
                    // Original Image Preview with Slider
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                            .cornerRadius(12)
                            .matchedGeometryEffect(id: "imageView", in: animation)
                        
                        // Compression Slider
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Compression Quality: \(Int(viewModel.compressionQuality * 100))%")
                                .font(.headline)
                            
                            Slider(value: $viewModel.compressionQuality, in: 0.1...1.0)
                                .tint(.blue)
                            
                            if let originalSize = viewModel.originalFileSize {
                                Text("Original Size: \(formatFileSize(originalSize))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                } else {
                    // Compressed Image Preview
                    Image(uiImage: viewModel.compressedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .cornerRadius(12)
                        .matchedGeometryEffect(id: "imageView", in: animation)
                }
                
                if let compressedSize = viewModel.compressedFileSize {
                    Text("Compressed Size: \(formatFileSize(compressedSize))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    if viewModel.isCompressing {
                        ProgressView("Compressing...")
                            .transition(.scale.combined(with: .opacity))
                    } else if viewModel.compressedImage != nil {
                        // Actions for compressed image
                        Button(action: {
                            withAnimation {
                                viewModel.saveToGallery()
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text(viewModel.isSaved ? "Saved to Gallery" : "Save to Gallery")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isSaved ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.isSaved)
                        .transition(.move(edge: .bottom))
                        
                        Button(action: {
                            withAnimation {
                                viewModel.shareImage()
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .transition(.move(edge: .bottom))
                        
                        Button("Compress Another Image") {
                            withAnimation {
                                viewModel.reset()
                            }
                        }
                        .foregroundColor(.blue)
                        .transition(.move(edge: .bottom))
                    } else {
                        // Compress button
                        Button(action: {
                            withAnimation {
                                viewModel.compressImage()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Compress Image")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.isCompressing)
                        
                        Button("Select Different Image") {
                            withAnimation {
                                viewModel.reset()
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
            } else {
                // Empty State with Loading
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 300)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Select an image to compress")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                PhotosPicker(selection: $viewModel.selectedItem,
                           matching: .images) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("Select Image")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .navigationTitle("Compress Image")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Message", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.compressedImage)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.isCompressing)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.isSaved)
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Image...")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .frame(maxHeight: .infinity)
        .transition(.opacity)
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

#Preview {
    NavigationStack {
        CompressImageView()
    }
}
